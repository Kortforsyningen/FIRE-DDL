﻿/* -------------------------------------------------------------------------- */
/* Make SRIDTYPE data. 
/* File: MakeSRIDType.sql   
/* -------------------------------------------------------------------------- */

/*
AFKLARINGER:
ikke tilladte namespaces er anvendt i ca. 10 stk - se nedenfor.
*/

DELETE FROM SRIDNAMESPACE;

INSERT INTO SRIDNAMESPACE (BESKRIVELSE, NAMESPACE) VALUES ('Ingen beskrivelse','DK');
INSERT INTO SRIDNAMESPACE (BESKRIVELSE, NAMESPACE) VALUES ('Ingen beskrivelse','EPSG');
INSERT INTO SRIDNAMESPACE (BESKRIVELSE, NAMESPACE) VALUES ('Ingen beskrivelse','FO');
INSERT INTO SRIDNAMESPACE (BESKRIVELSE, NAMESPACE) VALUES ('Ingen beskrivelse','GL');
INSERT INTO SRIDNAMESPACE (BESKRIVELSE, NAMESPACE) VALUES ('Ingen beskrivelse','LOC');
INSERT INTO SRIDNAMESPACE (BESKRIVELSE, NAMESPACE) VALUES ('Ingen beskrivelse','NKG');
INSERT INTO SRIDNAMESPACE (BESKRIVELSE, NAMESPACE) VALUES ('Ingen beskrivelse','TS');

DELETE FROM SRIDTYPE;

INSERT INTO SRIDTYPE (SRIDID, BESKRIVELSE, SRID) VALUES (FLOOR(dbms_random.value(1,1E9)), 'Ingen beskrivelse','EPSG:4909');
INSERT INTO SRIDTYPE (SRIDID, BESKRIVELSE, SRID) VALUES (FLOOR(dbms_random.value(1,1E9)), 'Ingen beskrivelse','EPSG:5317');
INSERT INTO SRIDTYPE (SRIDID, BESKRIVELSE, SRID) VALUES (FLOOR(dbms_random.value(1,1E9)), 'Ingen beskrivelse','EPSG:5799');
INSERT INTO SRIDTYPE (SRIDID, BESKRIVELSE, SRID) VALUES (FLOOR(dbms_random.value(1,1E9)), 'Ingen beskrivelse','DK:DVR90');
INSERT INTO SRIDTYPE (SRIDID, BESKRIVELSE, SRID) VALUES (FLOOR(dbms_random.value(1,1E9)), 'Ingen beskrivelse','EPSG:4937');
INSERT INTO SRIDTYPE (SRIDID, BESKRIVELSE, SRID) VALUES (FLOOR(dbms_random.value(1,1E9)), 'Ingen beskrivelse','EPSG:4747');
INSERT INTO SRIDTYPE (SRIDID, BESKRIVELSE, SRID) VALUES (FLOOR(dbms_random.value(1,1E9)), 'Ingen beskrivelse','FO:FVR09');
INSERT INTO SRIDTYPE (SRIDID, BESKRIVELSE, SRID) VALUES (FLOOR(dbms_random.value(1,1E9)), 'Ingen beskrivelse','EPSG:4230');
INSERT INTO SRIDTYPE (SRIDID, BESKRIVELSE, SRID) VALUES (FLOOR(dbms_random.value(1,1E9)), 'Ingen beskrivelse','EPSG:4231');
INSERT INTO SRIDTYPE (SRIDID, BESKRIVELSE, SRID) VALUES (FLOOR(dbms_random.value(1,1E9)), 'Ingen beskrivelse','EPSG:4258');
INSERT INTO SRIDTYPE (SRIDID, BESKRIVELSE, SRID) VALUES (FLOOR(dbms_random.value(1,1E9)), 'Ingen beskrivelse','EPSG:4747');
INSERT INTO SRIDTYPE (SRIDID, BESKRIVELSE, SRID) VALUES (FLOOR(dbms_random.value(1,1E9)), 'Ingen beskrivelse','GL:4747');
INSERT INTO SRIDTYPE (SRIDID, BESKRIVELSE, SRID) VALUES (FLOOR(dbms_random.value(1,1E9)), 'Ingen beskrivelse','LOC:GI44');
INSERT INTO SRIDTYPE (SRIDID, BESKRIVELSE, SRID) VALUES (FLOOR(dbms_random.value(1,1E9)), 'Ingen beskrivelse','LOC:GM91');
INSERT INTO SRIDTYPE (SRIDID, BESKRIVELSE, SRID) VALUES (FLOOR(dbms_random.value(1,1E9)), 'Ingen beskrivelse','DK:GS');
INSERT INTO SRIDTYPE (SRIDID, BESKRIVELSE, SRID) VALUES (FLOOR(dbms_random.value(1,1E9)), 'Ingen beskrivelse','DK:GSB');
INSERT INTO SRIDTYPE (SRIDID, BESKRIVELSE, SRID) VALUES (FLOOR(dbms_random.value(1,1E9)), 'Ingen beskrivelse','LOC:HPOT_DRV90');
INSERT INTO SRIDTYPE (SRIDID, BESKRIVELSE, SRID) VALUES (FLOOR(dbms_random.value(1,1E9)), 'Ingen beskrivelse','DK:KK');
INSERT INTO SRIDTYPE (SRIDID, BESKRIVELSE, SRID) VALUES (FLOOR(dbms_random.value(1,1E9)), 'Ingen beskrivelse','LOC:KN44');
INSERT INTO SRIDTYPE (SRIDID, BESKRIVELSE, SRID) VALUES (FLOOR(dbms_random.value(1,1E9)), 'Ingen beskrivelse','EPSG:4326');
INSERT INTO SRIDTYPE (SRIDID, BESKRIVELSE, SRID) VALUES (FLOOR(dbms_random.value(1,1E9)), 'Ingen beskrivelse','LOC:MSL');
INSERT INTO SRIDTYPE (SRIDID, BESKRIVELSE, SRID) VALUES (FLOOR(dbms_random.value(1,1E9)), 'Ingen beskrivelse','DK:OS');
INSERT INTO SRIDTYPE (SRIDID, BESKRIVELSE, SRID) VALUES (FLOOR(dbms_random.value(1,1E9)), 'Ingen beskrivelse','DK:S34J');
INSERT INTO SRIDTYPE (SRIDID, BESKRIVELSE, SRID) VALUES (FLOOR(dbms_random.value(1,1E9)), 'Ingen beskrivelse','DK:S34S');
INSERT INTO SRIDTYPE (SRIDID, BESKRIVELSE, SRID) VALUES (FLOOR(dbms_random.value(1,1E9)), 'Ingen beskrivelse','DK:S45B');
INSERT INTO SRIDTYPE (SRIDID, BESKRIVELSE, SRID) VALUES (FLOOR(dbms_random.value(1,1E9)), 'Ingen beskrivelse','DK:SB');
INSERT INTO SRIDTYPE (SRIDID, BESKRIVELSE, SRID) VALUES (FLOOR(dbms_random.value(1,1E9)), 'Ingen beskrivelse','EPSG:4936');
INSERT INTO SRIDTYPE (SRIDID, BESKRIVELSE, SRID) VALUES (FLOOR(dbms_random.value(1,1E9)), 'Ingen beskrivelse','TS:LRL');
INSERT INTO SRIDTYPE (SRIDID, BESKRIVELSE, SRID) VALUES (FLOOR(dbms_random.value(1,1E9)), 'Ingen beskrivelse','EPSG:25832');
INSERT INTO SRIDTYPE (SRIDID, BESKRIVELSE, SRID) VALUES (FLOOR(dbms_random.value(1,1E9)), 'Ingen beskrivelse','EPSG:23032');
INSERT INTO SRIDTYPE (SRIDID, BESKRIVELSE, SRID) VALUES (FLOOR(dbms_random.value(1,1E9)), 'Ingen beskrivelse','EPSG:23033');

-- TS:81XXX derived from table ts_dvr90(JNR_BSIDE)
INSERT INTO SRIDTYPE (BESKRIVELSE, SRID, SRIDID)
SELECT DISTINCT ('Lokalt højdesystem for tidsserie over Jessenpunkt ' || ts.JNR_BSIDE), 'TS:' || ts.JNR_BSIDE, FLOOR(dbms_random.value(1,1E9)) 
FROM (SELECT JNR_BSIDE, COUNT(*) FROM ts_dvr90@refgeo WHERE JNR_BSIDE BETWEEN 81000 AND 81999 GROUP BY JNR_BSIDE) ts
;

-- TS:XXXX  derived from table ts_euref89(REFNR->GNSS or landsnr)
INSERT INTO SRIDTYPE (BESKRIVELSE, SRID, SRIDID)
SELECT 'ETRS89 tidsserie over ' || REPLACE(NVL(gnss.IDENT, landsnr.IDENT), ' ', '_'), 'TS:' || REPLACE(NVL(gnss.IDENT, landsnr.IDENT), ' ', '_'), FLOOR(dbms_random.value(1,1E9)) 
FROM (SELECT DISTINCT REFNR FROM ts_euref89@refgeo) ts 
LEFT JOIN refadm.REFNR_IDENT@refgeo gnss ON ts.REFNR = gnss.REFNR AND gnss.IDENT_TYPE = 'GNSS' 
LEFT JOIN refadm.REFNR_IDENT@refgeo landsnr ON ts.REFNR = landsnr.REFNR AND landsnr.IDENT_TYPE = 'landsnr' 
;

-- Set SRIDID to equal OBJECTID - just a hack to make it unique 
UPDATE SRIDTYPE SET SRIDID = OBEJCTID;

COMMIT;