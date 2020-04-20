import uuid
from pathlib import Path

import sqlalchemy
from sqlalchemy.orm import aliased
from sqlalchemy.orm.exc import NoResultFound
import click

import fire.cli
from fire.cli import firedb
import fire.api
from fire.api.model import (
    Punkt,
    PunktInformation,
    PunktInformationType,
    Sag,
    Sagsinfo,
    Sagsevent,
    SagseventInfo,
)

POINT_FILE = Path(__file__).parents[0] / Path("definerende_dvr90_punkter.txt")
ATTRIBUT = "NET:DVR90"

def get_punkt(ident: str) -> str:
    """
    Vis al tilgængelig information om et fikspunkt

    IDENT kan være enhver form for navn et punkt er kendt som, blandt andet
    GNSS stationsnummer, G.I.-nummer, refnr, landsnummer osv.

    Søgningen er versalfølsom.
    """
    pi = aliased(PunktInformation)
    pit = aliased(PunktInformationType)

    punktinfo = (
        firedb.session.query(pi)
        .filter(pit.name.startswith("IDENT:"), pi.tekst == ident)
        .all()
    )
    n = len(punktinfo)
    if n == 0:
        raise NoResultFound

    punkt = punktinfo[0].punkt

    return punkt


sagsbeskrivelse = f"""Registrering af punkter der indgik i den oprindelige DVR90-udjævning.

Punkterne markeres med {ATTRIBUT}.

Se "Klaus Schmidt, 2000, The Danish height system DVR90" for yderligere information om udjævningen.
"""


def main():

    firedb.indset_punktinformationtype(
        PunktInformationType(
            name=ATTRIBUT,
            anvendelse=fire.api.model.PunktInformationTypeAnvendelse.FLAG,
            beskrivelse="Punkter i den oprindelige DVR90-udjævning",
        )
    )
    infotype = firedb.hent_punktinformationtype(ATTRIBUT)

    sagsinfo = Sagsinfo(
        aktiv="true", behandler="Kristian Evers", beskrivelse=sagsbeskrivelse
    )
    sagid = str(uuid.uuid4())
    firedb.indset_sag(Sag(id=sagid, sagsinfos=[sagsinfo]))
    sag =  firedb.hent_sag(sagid)


    with open(POINT_FILE) as f:
        punkter = [punkt.strip() for punkt in f.readlines()]

        punktinformationer = []
        # interaktion med databasen er pokkers langsomt, vis fremdrift
        with click.progressbar(punkter, label="Punkter") as punkter_progress:
            for ident in punkter_progress:
                try:
                    punkt = get_punkt(ident)
                except sqlalchemy.orm.exc.NoResultFound:
                    print(f"Ident ikke fundet: {ident}")
                    continue

                pi = PunktInformation(infotype=infotype, punkt=punkt)
                punktinformationer.append(pi)

    sagseventinfo = SagseventInfo(beskrivelse=f"Indsættelse af {ATTRIBUT} attibutter")
    sagsevent = Sagsevent(
        id=str(uuid.uuid4()),
        sag=sag,
        eventtype=fire.api.model.EventType.PUNKTINFO_TILFOEJET,
        sagseventinfos=[sagseventinfo],
        punktinformationer=punktinformationer,
    )
    firedb.indset_sagsevent(sagsevent)

if __name__ == "__main__":
    main()
