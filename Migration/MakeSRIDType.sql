/* -------------------------------------------------------------------------- */
/* Make SRIDTYPE data.
/* File: MakeSRIDType.sql
/* -------------------------------------------------------------------------- */

DELETE FROM SRIDNAMESPACE;

INSERT INTO SRIDNAMESPACE (NAMESPACE, BESKRIVELSE) VALUES ('DK',
    'SDFE register over danske systemer');
INSERT INTO SRIDNAMESPACE (NAMESPACE, BESKRIVELSE) VALUES ('EPSG',
    'IOGP Geodetic Parameter Registry');
INSERT INTO SRIDNAMESPACE (NAMESPACE, BESKRIVELSE) VALUES ('FO',
    'SDFE register over færøske systemer');
INSERT INTO SRIDNAMESPACE (NAMESPACE, BESKRIVELSE) VALUES ('GL',
    'SDFE register over grønlandske systemer');
INSERT INTO SRIDNAMESPACE (NAMESPACE, BESKRIVELSE) VALUES ('NKG',
    'Nordisk Kommission for Geodæsi register over nordisk/baltiske systemer');
INSERT INTO SRIDNAMESPACE (NAMESPACE, BESKRIVELSE) VALUES ('TS',
    'SDFE register over tidsrækker');

DELETE FROM SRIDTYPE;

/* (Pseudo)globale systemer */
INSERT INTO SRIDTYPE (SRIDID, SRID, BESKRIVELSE, X, Y) VALUES (FLOOR(dbms_random.value(1,1E9)), 'EPSG:4326',
    'Geografiske koordinater 2D: WGS84', 'Længdegrad [decimalgrader]', 'Breddegrad [decimalgrader]');
INSERT INTO SRIDTYPE (SRIDID, SRID, BESKRIVELSE, X, Y) VALUES (FLOOR(dbms_random.value(1,1E9)), 'EPSG:4258',
    'Geografiske koordinater 2D: ETRS89', 'Længdegrad [decimalgrader]', 'Breddegrad [decimalgrader]');
INSERT INTO SRIDTYPE (SRIDID, SRID, BESKRIVELSE, X, Y, Z) VALUES (FLOOR(dbms_random.value(1,1E9)), 'EPSG:4937',
    'Geografiske koordinater 3D: ETRS89', 'Længdegrad [decimalgrader]', 'Breddegrad [decimalgrader]','Ellipsoidehøjde [m]');
INSERT INTO SRIDTYPE (SRIDID, SRID, BESKRIVELSE, X, Y, Z) VALUES (FLOOR(dbms_random.value(1,1E9)), 'EPSG:4936',
    'Geocentrisk kartesiske koordinater 3D: ETRS89', 'X [m]', 'Y [m]', 'Z [m]');
INSERT INTO SRIDTYPE (SRIDID, SRID, BESKRIVELSE, X, Y) VALUES (FLOOR(dbms_random.value(1,1E9)), 'EPSG:4230',
    'Geografiske koordinater 2D: ED50', 'Længdegrad [decimalgrader]', 'Breddegrad [decimalgrader]');
INSERT INTO SRIDTYPE (SRIDID, SRID, BESKRIVELSE, X, Y) VALUES (FLOOR(dbms_random.value(1,1E9)), 'EPSG:4231',
    'Geografiske koordinater 2D: ED87', 'Længdegrad [decimalgrader]', 'Breddegrad [decimalgrader]');
INSERT INTO SRIDTYPE (SRIDID, SRID, BESKRIVELSE, Z) VALUES (FLOOR(dbms_random.value(1,1E9)), 'EPSG:5714',
    'Kotesystem: Lokal middelvandstand', 'Kote [m]');

/* Danske systemer */
INSERT INTO SRIDTYPE (SRIDID, SRID, BESKRIVELSE, Z) VALUES (FLOOR(dbms_random.value(1,1E9)), 'EPSG:5799',
    'Kotesystem: Dansk Vertikal Reference 1990', 'Kote [m]');
INSERT INTO SRIDTYPE (SRIDID, SRID, BESKRIVELSE, Z) VALUES (FLOOR(dbms_random.value(1,1E9)), 'DK:HPOT_DVR90',
    'Kotesystem: Geopotentialhøjder DVR90', 'Geopotentialhøjde');
INSERT INTO SRIDTYPE (SRIDID, SRID, BESKRIVELSE, Z) VALUES (FLOOR(dbms_random.value(1,1E9)), 'EPSG:5733',
    'Kotesystem: Dansk Normal Nul', 'Kote [m]');
INSERT INTO SRIDTYPE (SRIDID, SRID, BESKRIVELSE, Z) VALUES (FLOOR(dbms_random.value(1,1E9)), 'DK:GI44',
    'Kotesystem: Dansk Normal Nul, Sjælland', 'Kote [m]');
INSERT INTO SRIDTYPE (SRIDID, SRID, BESKRIVELSE, Z) VALUES (FLOOR(dbms_random.value(1,1E9)), 'DK:GM91',
    'Kotesystem: Dansk Normal Nul, Jylland', 'Kote [m]');
INSERT INTO SRIDTYPE (SRIDID, SRID, BESKRIVELSE, Z) VALUES (FLOOR(dbms_random.value(1,1E9)), 'DK:KN44',
    'Kotesystem: Københavns nul 1944','Kote [m]');
INSERT INTO SRIDTYPE (SRIDID, SRID, BESKRIVELSE, X, Y) VALUES (FLOOR(dbms_random.value(1,1E9)), 'EPSG:25832',
    'Projicerede koordinater 2D: UTM zone 32, ETRS89','Easting [m]', 'Northing [m]');
INSERT INTO SRIDTYPE (SRIDID, SRID, BESKRIVELSE, X, Y) VALUES (FLOOR(dbms_random.value(1,1E9)), 'EPSG:23032',
    'Projicerede koordinater 2D: UTM zone 32, ED50','Easting [m]', 'Northing [m]');
INSERT INTO SRIDTYPE (SRIDID, SRID, BESKRIVELSE, X, Y) VALUES (FLOOR(dbms_random.value(1,1E9)), 'EPSG:23033',
    'Projicerede koordinater 2D: UTM zone 33, ED50','Easting [m]', 'Northing [m]');
INSERT INTO SRIDTYPE (SRIDID, SRID, BESKRIVELSE, X, Y) VALUES (FLOOR(dbms_random.value(1,1E9)), 'DK:GS',
    'Projicerede koordinater 2D: Generalstabens Konformt Koniske System','Easting [m]', 'Northing [m]');
INSERT INTO SRIDTYPE (SRIDID, SRID, BESKRIVELSE, X, Y) VALUES (FLOOR(dbms_random.value(1,1E9)), 'DK:GSB',
    'Projicerede koordinater 2D: Generalstabens Konformt Koniske System Bornholm','Easting [m]', 'Northing [m]');
INSERT INTO SRIDTYPE (SRIDID, SRID, BESKRIVELSE, X, Y) VALUES (FLOOR(dbms_random.value(1,1E9)), 'DK:KK',
    'Projicerede koordinater 2D: Københavns Kommunes System','Easting [m]', 'Northing [m]');
INSERT INTO SRIDTYPE (SRIDID, SRID, BESKRIVELSE, X, Y) VALUES (FLOOR(dbms_random.value(1,1E9)), 'DK:OS',
    'Projicerede koordinater 2D: System Ostenfeld','Easting [m]', 'Northing [m]');
INSERT INTO SRIDTYPE (SRIDID, SRID, BESKRIVELSE, X, Y) VALUES (FLOOR(dbms_random.value(1,1E9)), 'DK:S34J',
    'Projicerede koordinater 2D: System 34 Jylland','Westing [m]', 'Northing [m]');
INSERT INTO SRIDTYPE (SRIDID, SRID, BESKRIVELSE, X, Y) VALUES (FLOOR(dbms_random.value(1,1E9)), 'DK:S34S',
    'Projicerede koordinater 2D: System 34 Sjælland','Westing [m]', 'Northing [m]');
INSERT INTO SRIDTYPE (SRIDID, SRID, BESKRIVELSE, X, Y) VALUES (FLOOR(dbms_random.value(1,1E9)), 'DK:S45B',
    'Projicerede koordinater 2D: System 45 Bornholm', 'Westing [m]', 'Northing [m]');
INSERT INTO SRIDTYPE (SRIDID, SRID, BESKRIVELSE, X, Y) VALUES (FLOOR(dbms_random.value(1,1E9)), 'DK:SB',
    'Projicerede koordinater 2D: System Storebælt', 'Westing [m]', 'Northing [m]');

/* Færøske systemer */
INSERT INTO SRIDTYPE (SRIDID, SRID, BESKRIVELSE, Z) VALUES (FLOOR(dbms_random.value(1,1E9)), 'EPSG:5317',
    'Kotesystem: Færøsk Vertikal Reference 2009', 'Kote [m]');

/* Grønlandske systemer */
INSERT INTO SRIDTYPE (SRIDID, SRID, BESKRIVELSE, X, Y) VALUES (FLOOR(dbms_random.value(1,1E9)), 'EPSG:4747',
    'Geografiske koordinater 2D: GR96', 'Længdegrad [decimalgrader]', 'Breddegrad [decimalgrader]');
INSERT INTO SRIDTYPE (SRIDID, SRID, BESKRIVELSE, X, Y, Z) VALUES (FLOOR(dbms_random.value(1,1E9)), 'EPSG:4909',
    'Geografiske koordinater 3D: GR96', 'Længdegrad [decimalgrader]', 'Breddegrad [decimalgrader]', 'Ellipsoidehøjde [m]');
INSERT INTO SRIDTYPE (SRIDID, SRID, BESKRIVELSE, X, Y) VALUES (FLOOR(dbms_random.value(1,1E9)), 'GL:NAD83G',
    'Geografiske koordinater 2D: NAD83G (DEPRECATED)', 'Længdegrad [decimalgrader]', 'Breddegrad [decimalgrader]');

/* Tidsrækker */
INSERT INTO SRIDTYPE (SRIDID, SRID, BESKRIVELSE, Z) VALUES (FLOOR(dbms_random.value(1,1E9)), 'TS:LRL',
    'Vandstandsbrætsnettilknytning', 'Kote [m]');

-- TS:81XXX derived from table ts_dvr90(JNR_BSIDE)
INSERT INTO SRIDTYPE (BESKRIVELSE, SRID, SRIDID, Z)
SELECT DISTINCT ('Lokalt højdesystem for tidsserie over Jessenpunkt ' || ts.JNR_BSIDE), 'TS:' || ts.JNR_BSIDE, FLOOR(dbms_random.value(1,1E9)),  'Kote [m]'
FROM (SELECT JNR_BSIDE, COUNT(*) FROM ts_dvr90@refgeo WHERE JNR_BSIDE BETWEEN 81000 AND 81999 GROUP BY JNR_BSIDE) ts
;

-- TS:XXXX  derived from table ts_euref89(REFNR->GNSS or landsnr)
INSERT INTO SRIDTYPE (BESKRIVELSE, SRID, SRIDID, X, Y, Z)
SELECT 'ETRS89 tidsserie over ' || REPLACE(NVL(gnss.IDENT, landsnr.IDENT), ' ', '_'), 'TS:' || REPLACE(NVL(gnss.IDENT, landsnr.IDENT), ' ', '_'), FLOOR(dbms_random.value(1,1E9)),
'X [m]','Y [m]','Z [m]'
FROM (SELECT DISTINCT REFNR FROM ts_euref89@refgeo) ts
LEFT JOIN refadm.REFNR_IDENT@refgeo gnss ON ts.REFNR = gnss.REFNR AND gnss.IDENT_TYPE = 'GNSS'
LEFT JOIN refadm.REFNR_IDENT@refgeo landsnr ON ts.REFNR = landsnr.REFNR AND landsnr.IDENT_TYPE = 'landsnr'
;

-- Set SRIDID to equal OBJECTID
UPDATE SRIDTYPE SET SRIDID = OBJECTID;

COMMIT;
