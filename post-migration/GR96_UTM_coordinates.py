"""

Transformer GR96 koordinater til GR96/UTM24 og indsæt i databasen.
Formålet er at undgå brug af Oracles fejlbehæftede transvers mercator
projektion (den yder dårligt når koordinater ligger uden for zonen).

2D og 3D GR96 koordinater vrides begge ind i et 2D UTM24 format (EPSG:3184),
da det primære formål er at levere easting og northing i Udstillingsmodellen,
sålænge den lever.

"""
import uuid
from functools import wraps
from time import time
import timeit
import datetime

from pyproj import Transformer, transform
import sqlalchemy
from sqlalchemy import and_, or_
from sqlalchemy.orm import aliased
from sqlalchemy.orm.exc import NoResultFound
import click

import fire.cli
from fire.cli import firedb
import fire.api
from fire.api.model import (
    Artskode,
    Punkt,
    PunktInformation,
    PunktInformationType,
    Sag,
    Sagsinfo,
    Sagsevent,
    SagseventInfo,
    Koordinat,
    Srid,
    Point,
    GeometriObjekt,
)


def measure(func):
    @wraps(func)
    def _time_it(*args, **kwargs):
        start = int(round(time() * 1000))
        try:
            return func(*args, **kwargs)
        finally:
            end_ = int(round(time() * 1000)) - start
            print(f"Total execution time: {end_ if end_ > 0 else 0} ms")

    return _time_it


#@measure
def convert_coordinates(epsg_code):
    from_srid = firedb.hent_srid(epsg_code)
    try:
        # tilføjet i Migration/MakeSRIDType.sql, men inkluderet her for en sikkerheds skyld
        to_srid = firedb.hent_srid("EPSG:3184")
    except:
        new_srid = Srid(
            beskrivelse="Projicerede koordinater 2D: UTM Zone 24, GR96",
            x="Easting [m]",
            y="Northing [m]",
            name="EPSG:3184",
        )
        firedb.indset_srid(new_srid)
    finally:
        to_srid = firedb.hent_srid("EPSG:3184")

    koordinater = (
        firedb.session.query(Koordinat)
        .filter(
            and_(
                Koordinat.sridid == from_srid.sridid, Koordinat._registreringtil == None
            )
        )
        .all()
    )

    nye_koordinater = []
    oracle_killer = Transformer.from_crs(epsg_code, "EPSG:3184")
    with click.progressbar(
        koordinater,
        label=f"Transforming {epsg_code} coordinates",
        length=len(koordinater),
    ) as koord:
        for koordinat in koord:
            utm = oracle_killer.transform(koordinat.y, koordinat.x)
            utm_koordinat = Koordinat(
                srid=to_srid,
                sx=koordinat.sx,
                sy=koordinat.sy,
                # vi beholder samme tidspunkt for ikke at få det til at se
                # ud som om koordinaten er nyere, og dermed bedre
                t=koordinat.t,
                transformeret="true",
                x=utm[0],
                y=utm[1],
                punkt=koordinat.punkt,
                artskode=Artskode.TRANSFORMERET,
            )
            nye_koordinater.append(utm_koordinat)

    return nye_koordinater

def convert_heights():
    """Skab UTM koordinater for grønlandske højdefikspunkter.

    Der tilføjes kun UTM koordinater hvis ikke fikspunktet i forvejen har tilknyttet
    en UTM koordinater. Da der for mange højdefikspunkter ikke findes en plankoordinat
    benyttes dens lokationskoordinat.
    """
    UTM24 = firedb.hent_srid("EPSG:3184")
    region_gl = firedb.hent_punktinformationtype("REGION:GL")

    punkt_kandidater = (
        firedb.session.query(Punkt)
        .join(PunktInformation)
        .filter(
            PunktInformation.infotypeid == region_gl.infotypeid
        ).all()
    )

    oracle_killer = Transformer.from_crs("EPSG:4326", "EPSG:3184")
    nye_koordinater = []
    with click.progressbar(
        punkt_kandidater,
        label=f"Transforming WGS84 coordinates",
        length=len(punkt_kandidater),
    ) as punkter:
        for punkt in punkter:
            needs_transformation = True
            for koordinat in punkt.koordinater:
                if koordinat.sridid == UTM24.sridid:
                    needs_transformation = False # punktet har en UTM koordinat, videre
                    break
            if not needs_transformation:
                continue

            try:
                (lon, lat) = punkt.geometriobjekter[0].geometri._geom['coordinates']
            except IndexError:
                continue # Der findes ikke en lokationskoordinat, videre

            utm = oracle_killer.transform(lat, lon)
            utm_koordinat = Koordinat(
                srid=UTM24,
                sx=999,
                sy=999,
                # Vi bruger punktets oprettelsesdato for ikke at få koordinaten
                # til at se nyere og bedre ud end den er
                t=punkt.registreringfra,
                transformeret="true",
                x=utm[0],
                y=utm[1],
                punkt=punkt,
                artskode=Artskode.TRANSFORMERET,
            )
            nye_koordinater.append(utm_koordinat)

    return nye_koordinater

def add_coordinates(sag, koordinater, beskrivelse):
    """
    Tilføj koordinater og dertilhørende sagsevent til sag
    """
    sagseventinfo = SagseventInfo(beskrivelse=beskrivelse)
    sagsevent = Sagsevent(
        id=str(uuid.uuid4()),
        sag=sag,
        eventtype=fire.api.model.KOORDINAT_BEREGNET,
        sagseventinfos=[sagseventinfo],
        koordinater=koordinater,
    )
    print("add_coordinates: " + beskrivelse)
    firedb.indset_sagsevent(sagsevent)

def main():
    sagsbeskrivelse = """Indsættelse af GR96/UTM24 koordinater.

Koordinaterne indsættes i FIRE i forbindelse med migrering fra
REFGEO til FIRE. Det er nødvendigt at indsætte projicerede
koordinater fordi Oracle databasens UTM transformation ikke
er pålidelig uden for den givne UTM zone. Dette er et problem
i forbindelse med udstillingsmodellen, hvor modellen kræver
at der stilles UTM northing og easting koordinater til rådighed.
Da Oracle ikke kan beregne disse koordinater troværdigt gør vi
det i stedet her med PROJ som motor. PROJ 6.3.1 benyttes.

Tidsstemplet på de transformerede koordinater sættes til
det aktuelle tidspunkt ved indsættelse, og den oprindelige
koordinats tidsstempel føres ikke med til de nye
transformerede koordinater.
"""

    # Undgå at oprette tonsvis af sager i test-fasen.
    # Hvis sagen findes genbruges den, hvis ikke
    # oprettes den.
    sagid = "6baaf540-3e8a-41b1-ae61-b785adf9687c"
    try:
        sag = firedb.hent_sag(sagid)
    except:
        sagsinfo = Sagsinfo(
            aktiv="true", behandler="Kristian Evers", beskrivelse=sagsbeskrivelse
        )
        firedb.indset_sag(Sag(id=sagid, sagsinfos=[sagsinfo]))
    finally:
        sag = firedb.hent_sag(sagid)

    utm24_2d = convert_coordinates("EPSG:4747")
    add_coordinates(sag, utm24_2d, "Indsættelse af koordinater transformeret fra GR96 2D")
    utm24_3d = convert_coordinates("EPSG:4909")
    add_coordinates(sag, utm24_3d, "Indsættelse af koordinater transformeret fra GR96 3D")
    utm24_the_rest = convert_heights()
    add_coordinates(sag, utm24_the_rest, "Indsættelse af koordinater transformeret fra WGS84 (lokationskoordinater)")


if __name__ == "__main__":
    main()
