"""
Før dette script er kørt databasen opdateret med nedenstående,
for at omgå problemer der har sin rod i at Oracle tolker '' som NULL.
Derfor ændres alle tomme stregne til ' '

ALTER TRIGGER punktinfo_biu_trg DISABLE;

UPDATE punktinfo
SET tekst = ' '
WHERE objektid in (
  SELECT pi.objektid FROM punktinfo pi
  JOIN punktinfotype pit ON pit.infotypeid=pi.infotypeid
  WHERE pit.anvendelse='TEKST' and pi.tekst is NULL and pi.sagseventtilid IS NULL
);

COMMIT;

ALTER TRIGGER punktinfo_biu_trg ENABLE;
"""

from sqlalchemy.sql import text
from sqlalchemy.orm.exc import NoResultFound

from fire import uuid
import fire.cli
from fire.cli import firedb
import fire.api
from fire.api.model import (
    Sag,
    Sagsinfo,
    Sagsevent,
    SagseventInfo,
    EventType,
)

# Sagshåndtering
sagsbeskrivelse = "Luk alle punkter fra REFGEO hvor MV_STATUS=-1"
sagsinfo = Sagsinfo(
    aktiv="true", behandler="Kristian Evers", beskrivelse=sagsbeskrivelse
)
sagid = "af190b61-190b-413f-ba4d-432ecaca18d2"

try:
    sag = firedb.hent_sag(sagid)
except NoResultFound:
    sag = Sag(id=sagid, sagsinfos=[sagsinfo])
    firedb.indset_sag(sag)

sagsevent = Sagsevent(
    sag=sag,
    sagseventinfos=[
        SagseventInfo(beskrivelse="Lukning af punkter med REFGEO MV_STATUS=-1")
    ],
    id=uuid(),
    eventtype=EventType.PUNKT_NEDLAGT,
)

# Udtræk punkter
statement = text(
    """
SELECT p.id FROM hvd_ref@refgeo hr
JOIN conv_punkt cp ON hr.refnr=cp.refnr
JOIN punkt p ON cp.id=p.id
WHERE hr.mv_status=-1
"""
)

refnumre = firedb.session.execute(statement)
punktider = [refnr[0] for refnr in refnumre]
print("punktider hentet")
punkter = firedb.hent_punkt_liste(punktider)
print("punkter hentet")

# Luk punkter
for punkt in punkter:
    firedb.luk_punkt(punkt, sagsevent, commit=False)
print("punkter lukket")

firedb.indset_sagsevent(sagsevent)
print("sagsevent indsat!")