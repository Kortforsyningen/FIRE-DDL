"""

Indsæt punktinfo-attributter, der registerer hvilke
punkter der er fundamentalpunkter i diverse
referencesystemer. Eksempelvis for G.M.902:

ATTR:fundamentalpunkt - EPSG:5799

"""
import uuid

import sqlalchemy
from sqlalchemy.orm import aliased
from sqlalchemy.orm.exc import NoResultFound

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

PUNKTER = {
    'EPSG:5799': ['G.M.902'], # DVR90
    'EPSG:4258': # ETRS89 2D
        ['MYGD', 'HVIG', 'TYVH', 'STAG', 'VAEG', 'BUDD',
         'FO  ARGI', 'FO  KLAK', 'FO  SORV', 'FO  TORH', 'FO  TVOR'],
    'EPSG:4937': # ETRS89 3D
        ['MYGD', 'HVIG', 'TYVH', 'STAG', 'VAEG', 'BUDD',
         'FO  ARGI', 'FO  KLAK', 'FO  SORV', 'FO  TORH', 'FO  TVOR'],
    'EPSG:4936': # ETRS89 Kartesisk
        ['MYGD', 'HVIG', 'TYVH', 'STAG', 'VAEG', 'BUDD',
         'FO  ARGI', 'FO  KLAK', 'FO  SORV', 'FO  TORH', 'FO  TVOR'],
    'EPSG:5733': ['G.M.902'],
    'DK:GI44': ['G.M.902'],
    'DK:GM91': ['G.M.902'],
    'DK:KN44': ['G.M.902'],
    'EPSG:4909': ['GL  UAK1', 'GL  GOH1', 'GL  JAV1', 'GL  JUV1'], # GR96
    'EPSG:4747': ['GL  UAK1', 'GL  GOH1', 'GL  JAV1', 'GL  JUV1'], # GR96
    'EPSG:5317': ['FO  K-87-09037'] # FVR2009
}

ATTRIBUT = "ATTR:fundamentalpunkt"
sagsbeskrivelse = f"""Registrering af punkter der er fundamentalpunkter i et eller flere referencesystemer.

Punkterne markeres med {ATTRIBUT}, hvor teksten sættes til koden for det referencesystem punktet er fundamental punkt i.

Indsat i forbindelse med migrering fra REFGEO til FIRE.
"""


def main():
    infotype = firedb.hent_punktinformationtype(ATTRIBUT)
    if infotype is None:
        firedb.indset_punktinformationtype(
            PunktInformationType(
                name=ATTRIBUT,
                anvendelse=fire.api.model.PunktInformationTypeAnvendelse.TEKST,
                beskrivelse="Fundamentalpunkt i referencesystemet angivet i TEKST",
            )
        )
        infotype = firedb.hent_punktinformationtype(ATTRIBUT)

    print(infotype)

    sagsinfo = Sagsinfo(
        aktiv="true",
        behandler="Kristian Evers",
        beskrivelse=sagsbeskrivelse
    )
    sagid = str(uuid.uuid4())
    firedb.indset_sag(Sag(id=sagid, sagsinfos=[sagsinfo]))
    sag =  firedb.hent_sag(sagid)

    punktinformationer =  []

    for srid, identer in PUNKTER.items():
        for ident in identer:
            try:
                punkt = firedb.hent_punkt(ident)
            except NoResultFound:
                print(f'fejl: {ident}')
                continue
            pi = PunktInformation(infotype=infotype, punkt=punkt, tekst=srid)
            punktinformationer.append(pi)

    sagseventinfo = SagseventInfo(beskrivelse=f"Indsættelse af {ATTRIBUT} attributter")
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
