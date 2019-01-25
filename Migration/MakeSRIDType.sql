/* -------------------------------------------------------------------------- */
/* Make SRIDTYPE data.
/* File: MakeSRIDType.sql
/* -------------------------------------------------------------------------- */

/*
AFKLARINGER:
ikke tilladte namespaces er anvendt i ca. 10 stk - se nedenfor.
*/

DELETE FROM SRIDNAMESPACE;

INSERT INTO SRIDNAMESPACE (NAMESPACE, BESKRIVELSE) VALUES ('DK',
    'SDFE register over danske systemer')
INSERT INTO SRIDNAMESPACE (NAMESPACE, BESKRIVELSE) VALUES ('EPSG',
    'IOGP Geodetic Parameter Registry')
INSERT INTO SRIDNAMESPACE (NAMESPACE, BESKRIVELSE) VALUES ('FO',
    'SDFE register over færøske systemer')
INSERT INTO SRIDNAMESPACE (NAMESPACE, BESKRIVELSE) VALUES ('GL',
    'SDFE register over grønlandske systemer')
INSERT INTO SRIDNAMESPACE (NAMESPACE, BESKRIVELSE) VALUES ('NKG',
    'Nordisk Kommission for Geodæsi register over nordisk/baltiske systemer')
INSERT INTO SRIDNAMESPACE (NAMESPACE, BESKRIVELSE) VALUES ('TS',
    'SDFE register over tidsrækker')


DELETE FROM SRIDTYPE;

/* (Pseudo)globale systemer */
INSERT INTO SRIDTYPE (SRID, BESKRIVELSE) VALUES ('EPSG:4326',
    'Geografiske koordinater 2D: WGS84')
INSERT INTO SRIDTYPE (SRID, BESKRIVELSE) VALUES ('EPSG:4258',
    'Geografiske koordinater 2D: ETRS89')
INSERT INTO SRIDTYPE (SRID, BESKRIVELSE) VALUES ('EPSG:4937',
    'Geografiske koordinater 3D: ETRS89')
INSERT INTO SRIDTYPE (SRID, BESKRIVELSE) VALUES ('EPSG:4936',
    'Geocentrisk kartesiske koordinater 3D: ETRS89')

INSERT INTO SRIDTYPE (SRID, BESKRIVELSE) VALUES ('EPSG:4230',
    'Geografiske koordinater 2D: ED50')
INSERT INTO SRIDTYPE (SRID, BESKRIVELSE) VALUES ('EPSG:4231',
    'Geografiske koordinater 2D: ED87')

INSERT INTO SRIDTYPE (SRID, BESKRIVELSE) VALUES ('EPSG:5714',   /* Was: LOC:MSL */
    'Kotesystem: Lokal middelvandstand')



/* Danske systemer */

INSERT INTO SRIDTYPE (SRID, BESKRIVELSE) VALUES ('EPSG:5799',
    'Kotesystem: Dansk Vertikal Reference 1990')
INSERT INTO SRIDTYPE (SRID, BESKRIVELSE) VALUES ('DK:HPOT_DVR90',
    'Kotesystem: Geopotentialhøjder DVR90'

INSERT INTO SRIDTYPE (SRID, BESKRIVELSE) VALUES ('EPSG:5733',
    'Kotesystem: Dansk Normal Nul')
INSERT INTO SRIDTYPE (SRID, BESKRIVELSE) VALUES ('DK:GI44',
    'Kotesystem: Dansk Normal Nul, Sjælland')
INSERT INTO SRIDTYPE (SRID, BESKRIVELSE) VALUES ('DK:GM91',
    'Kotesystem: Dansk Normal Nul, Jylland')
INSERT INTO SRIDTYPE (SRID, BESKRIVELSE) VALUES ('DK:KN44',
    'Kotesystem: Københavns nul 1944')


INSERT INTO SRIDTYPE (SRID, BESKRIVELSE) VALUES ('EPSG:25832',
    'Projicerede koordinater 2D: UTM zone 32, ETRS89')
INSERT INTO SRIDTYPE (SRID, BESKRIVELSE) VALUES ('EPSG:23032',
    'Projicerede koordinater 2D: UTM zone 32, ED50')
INSERT INTO SRIDTYPE (SRID, BESKRIVELSE) VALUES ('EPSG:23033',
    'Projicerede koordinater 2D: UTM zone 33, ED50')

INSERT INTO SRIDTYPE (SRID, BESKRIVELSE) VALUES ('DK:GS',
    'Projicerede koordinater 2D: Generalstabens Konformt Koniske System')
INSERT INTO SRIDTYPE (SRID, BESKRIVELSE) VALUES ('DK:GSB',
    'Projicerede koordinater 2D: Generalstabens Konformt Koniske System Bornholm')

INSERT INTO SRIDTYPE (SRID, BESKRIVELSE) VALUES ('DK:KK',
    'Projicerede koordinater 2D: Københavns Kommunes System')

INSERT INTO SRIDTYPE (SRID, BESKRIVELSE) VALUES ('DK:OS',
    'Projicerede koordinater 2D: System Ostenfeld')
INSERT INTO SRIDTYPE (SRID, BESKRIVELSE) VALUES ('DK:S34J',
    'Projicerede koordinater 2D: System 34 Jylland')
INSERT INTO SRIDTYPE (SRID, BESKRIVELSE) VALUES ('DK:S34S',
    'Projicerede koordinater 2D: System 34 Sjælland')
INSERT INTO SRIDTYPE (SRID, BESKRIVELSE) VALUES ('DK:S45B',
    'Projicerede koordinater 2D: System 45 Bornholm')
INSERT INTO SRIDTYPE (SRID, BESKRIVELSE) VALUES ('DK:SB',
    'Projicerede koordinater 2D: System Storebælt')


/* Færøske systemer */

INSERT INTO SRIDTYPE (SRID, BESKRIVELSE) VALUES ('EPSG:5317',
    'Kotesystem: Færøsk Vertikal Reference 2009')


/* Grønlandske systemer */

INSERT INTO SRIDTYPE (SRID, BESKRIVELSE) VALUES ('EPSG:4747',
    'Geografiske koordinater 2D: GR96')
INSERT INTO SRIDTYPE (SRID, BESKRIVELSE) VALUES ('EPSG:4909',
    'Geografiske koordinater 3D: GR96')


/* Tidsrækker */

INSERT INTO SRIDTYPE (SRID, BESKRIVELSE) VALUES ('TS:LRL',
    'Vandstandsbrætsnettilknytning')

INSERT INTO SRIDTYPE (SRID, BESKRIVELSE)
SELECT 'TS:' || IDENT FROM refadm.REFNR_IDENT@refgeo WHERE IDENT_TYPE = 'jessen';

COMMIT;