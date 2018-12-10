/* -------------------------------------------------------------------------- */
/* Make PUNKTINFO data (with namespace SKITSE).
/* Data is found in REFGEO tables SKITSE and FIRE_SKITSER that was created by  
/* Kristian Evers specifically for migration purposes. 
/* File: MakePunktInfoSKITSE.sql   
/* -------------------------------------------------------------------------- */
/*
SPØRGSMÅL
*/

DELETE FROM PUNKTINFO WHERE INFOTYPE LIKE 'SKITSE:%';

-- SKITSE:sti
INSERT INTO PUNKTINFO (REGISTRERINGFRA, REGISTRERINGTIL, INFOTYPE, TEKST, SAGSEVENTID, PUNKTID)
SELECT 
    fs.IN_DATE AS REGISTRERINGFRA,
    ts.IN_DATE AS REGISTRERINGTIL,
    'SKITSE:sti' AS INFOTYPE,
    imgs.FILEPATH AS TEKST,
    '15101d43-ac91-4c7c-9e58-c7a0b5367910' AS SAGSEVENTID,
    conv.ID AS PUNKTID
FROM PUNKT p
INNER JOIN CONV_PUNKT conv ON p.ID = conv.ID
INNER JOIN SKITSE@refgeo fs ON fs.REFNR = conv.REFNR
INNER JOIN refadm.FIRE_SKITSER@refgeo imgs ON fs.REFNR = imgs.REFNR AND fs.VERSNR = imgs.VERSNR
LEFT JOIN SKITSE@refgeo ts ON ts.REFNR = fs.REFNR AND ts.VERSNR = (fs.VERSNR+1)
;

-- SKITSE:md5
INSERT INTO PUNKTINFO (REGISTRERINGFRA, REGISTRERINGTIL, INFOTYPE, TEKST, SAGSEVENTID, PUNKTID)
SELECT 
    fs.IN_DATE AS REGISTRERINGFRA,
    ts.IN_DATE AS REGISTRERINGTIL,
    'SKITSE:md5' AS INFOTYPE,
    imgs.MD5 AS TEKST,
    '15101d43-ac91-4c7c-9e58-c7a0b5367910' AS SAGSEVENTID,
    conv.ID AS PUNKTID
FROM PUNKT p
INNER JOIN CONV_PUNKT conv ON p.ID = conv.ID
INNER JOIN SKITSE@refgeo fs ON fs.REFNR = conv.REFNR
INNER JOIN refadm.FIRE_SKITSER@refgeo imgs ON fs.REFNR = imgs.REFNR AND fs.VERSNR = imgs.VERSNR
LEFT JOIN SKITSE@refgeo ts ON ts.REFNR = fs.REFNR AND ts.VERSNR = (fs.VERSNR+1)
;


COMMIT;