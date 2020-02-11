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
from sqlalchemy import and_
from sqlalchemy.orm import aliased
from sqlalchemy.orm.exc import NoResultFound
import click

import firecli
from firecli import firedb
import fireapi
from fireapi.model import (
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
                sz=koordinat.sx,
                t=datetime.datetime.now(),  # Vi indsætter beregningstidspunktet
                transformeret="true",
                x=utm[0],
                y=utm[1],
                z=koordinat.z,
                punkt=koordinat.punkt,
                artskode=Artskode.TRANSFORMERET,
            )
            nye_koordinater.append(utm_koordinat)

    return nye_koordinater


def main():
    sagsbeskrivelse = """Indsættelse af GR96/UTM24 koordinater.

Koordinaterne indsættes i FIRE i forbindelse med migrering fra
REFGEO til FIRE. Det er nødvendigt at indsætte projicerede
koordinater fordi Oracle databasens UTM transformation ikke
er pålidelig uden for den givne UTM zone. Dette er et problem
i forbindelse med udstillingsmodellen, hvor modellen kræver
at der stilles UTM northing og easting koordinater til rådighed.
Da Oracle ikke kan beregne disse koordinater troværdigt gør vi
det i stedet her med PROJ som motor. PROJ 6.3.0 benyttes.

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
    utm24_3d = convert_coordinates("EPSG:4909")

    nye_koordinater = utm24_2d
    nye_koordinater.extend(utm24_3d)

    sagseventinfo = SagseventInfo(beskrivelse=f"Indsættelse af GR96/UTM24 koordinater")
    sagsevent = Sagsevent(
        id=str(uuid.uuid4()),
        sag=sag,
        eventtype=fireapi.model.EventType.KOORDINAT_BEREGNET,
        sagseventinfos=[sagseventinfo],
        koordinater=nye_koordinater,
    )
    firedb.indset_sagsevent(sagsevent)


if __name__ == "__main__":
    main()
