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

INSERT INTO SRIDTYPE (BESKRIVELSE, SRID) VALUES ('Ingen beskrivelse','DK:DVR90');
INSERT INTO SRIDTYPE (BESKRIVELSE, SRID) VALUES ('Ingen beskrivelse','EPSG:4937');
INSERT INTO SRIDTYPE (BESKRIVELSE, SRID) VALUES ('Ingen beskrivelse','EPSG:4747');
INSERT INTO SRIDTYPE (BESKRIVELSE, SRID) VALUES ('Ingen beskrivelse','FO:FVR09');
INSERT INTO SRIDTYPE (BESKRIVELSE, SRID) VALUES ('Ingen beskrivelse','EPSG:4230');
INSERT INTO SRIDTYPE (BESKRIVELSE, SRID) VALUES ('Ingen beskrivelse','EPSG:4231');
INSERT INTO SRIDTYPE (BESKRIVELSE, SRID) VALUES ('Ingen beskrivelse','EPSG:4258');
INSERT INTO SRIDTYPE (BESKRIVELSE, SRID) VALUES ('Ingen beskrivelse','EPSG:4747');
INSERT INTO SRIDTYPE (BESKRIVELSE, SRID) VALUES ('Ingen beskrivelse','GL:4747');
INSERT INTO SRIDTYPE (BESKRIVELSE, SRID) VALUES ('Ingen beskrivelse','LOC:GI44');
INSERT INTO SRIDTYPE (BESKRIVELSE, SRID) VALUES ('Ingen beskrivelse','LOC:GM91');
INSERT INTO SRIDTYPE (BESKRIVELSE, SRID) VALUES ('Ingen beskrivelse','DK:GS');
INSERT INTO SRIDTYPE (BESKRIVELSE, SRID) VALUES ('Ingen beskrivelse','DK:GSB');
INSERT INTO SRIDTYPE (BESKRIVELSE, SRID) VALUES ('Ingen beskrivelse','LOC:HPOT_DRV90');
INSERT INTO SRIDTYPE (BESKRIVELSE, SRID) VALUES ('Ingen beskrivelse','DK:KK');
INSERT INTO SRIDTYPE (BESKRIVELSE, SRID) VALUES ('Ingen beskrivelse','LOC:KN44');
INSERT INTO SRIDTYPE (BESKRIVELSE, SRID) VALUES ('Ingen beskrivelse','EPSG:4326');
INSERT INTO SRIDTYPE (BESKRIVELSE, SRID) VALUES ('Ingen beskrivelse','LOC:MSL');
INSERT INTO SRIDTYPE (BESKRIVELSE, SRID) VALUES ('Ingen beskrivelse','DK:OS');
INSERT INTO SRIDTYPE (BESKRIVELSE, SRID) VALUES ('Ingen beskrivelse','DK:S34J');
INSERT INTO SRIDTYPE (BESKRIVELSE, SRID) VALUES ('Ingen beskrivelse','DK:S34S');
INSERT INTO SRIDTYPE (BESKRIVELSE, SRID) VALUES ('Ingen beskrivelse','DK:S45B');
INSERT INTO SRIDTYPE (BESKRIVELSE, SRID) VALUES ('Ingen beskrivelse','DK:SB');
INSERT INTO SRIDTYPE (BESKRIVELSE, SRID) VALUES ('Ingen beskrivelse','EPSG:4936');
INSERT INTO SRIDTYPE (BESKRIVELSE, SRID) VALUES ('Ingen beskrivelse','TS:LRL');
INSERT INTO SRIDTYPE (BESKRIVELSE, SRID) VALUES ('Ingen beskrivelse','EPSG:25832');
INSERT INTO SRIDTYPE (BESKRIVELSE, SRID) VALUES ('Ingen beskrivelse','EPSG:23032');
INSERT INTO SRIDTYPE (BESKRIVELSE, SRID) VALUES ('Ingen beskrivelse','EPSG:23033');

INSERT INTO SRIDTYPE (BESKRIVELSE, SRID)
SELECT 'Ingen beskrivelse','TS:' || IDENT FROM refadm.REFNR_IDENT@refgeo WHERE IDENT_TYPE = 'jessen';

COMMIT;