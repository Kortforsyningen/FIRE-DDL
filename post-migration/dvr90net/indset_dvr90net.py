import uuid

import sqlalchemy
from sqlalchemy.orm import aliased
from sqlalchemy.orm.exc import NoResultFound

import click

import firecli
from firecli import firedb
import fireapi
from fireapi.model import (
    Punkt,
    PunktInformation,
    PunktInformationType,
    Sag,
    Sagsinfo,
    Sagsevent,
    SagseventInfo,
)

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
        firedb.session.query(pi).filter(pit.name.startswith("IDENT:"), pi.tekst == ident).all()
    )
    n = len(punktinfo)
    if n == 0:
        raise NoResultFound

    punkt = punktinfo[0].punkt

    return punkt


sagsbeskrivelse ="""Registrering af punkter der indgik i den oprindelige DVR90-udjævning.

Punkterne markeres med NET:DVR90.

Se "Klaus Schmidt, 2000, The Danish height system DVR90" for yderligere information om udjævningen.
"""

def main():
    with open("definerende_dvr90_punkter.txt") as f:
        punkter = [punkt.strip() for punkt in f.readlines()]

        sagsinfo = fireapi.model.Sagsinfo(
            aktiv="true",
            behandler="Kristian Evers",
            beskrivelse=sagsbeskrivelse,
        )
        sag = Sag(id=str(uuid.uuid4()), sagsinfos=[sagsinfo])

        sagseventinfo = SagseventInfo(
            beskrivelse="Indsættelse af NET:DVR90 attibutter"
        )

        infotype = PunktInformationType(
            name="NET:TEST",
            infotypeid=370, # manuelt bestemt, sættes ikke automatisk
            anvendelse=fireapi.model.PunktInformationTypeAnvendelse.FLAG,
            beskrivelse="Punkter i den oprindelige DVR90-udjævning",
        )

        punktinformationer = []
        # interaktion med databasen er pokkers langsomt, vis fremdrift
        with click.progressbar(punkter, label="Punkter") as punkter_progress:
            for ident in punkter_progress:
                try:
                    punkt = get_punkt(ident)
                except sqlalchemy.orm.exc.NoResultFound:
                    print(f"Ident ikke fundet: {ident}")
                    continue

                pi = PunktInformation(
                    infotype=infotype,
                    punkt=punkt,
                )
                punktinformationer.append(pi)

        sagsevent = Sagsevent(
            id=str(uuid.uuid4()),
            sag=sag,
            eventtype=fireapi.model.EventType.PUNKTINFO_TILFOEJET,
            sagseventinfos=[sagseventinfo],
            punktinformationer=punktinformationer,
        )

        firedb.indset_sag(sag)

if __name__ == '__main__':
    main()