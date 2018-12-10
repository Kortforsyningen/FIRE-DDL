/* -------------------------------------------------------------------------- */
/* Make PUNKTINFO data (with namespace REGION).
/* Data is found in REFGEO tables HVD_REF and RGN_TABLE 
/* File: MakePunktInfoREGION.sql   
/* -------------------------------------------------------------------------- */
/*
SPØRGSMÅL
*/

DELETE FROM PUNKTINFO WHERE INFOTYPE LIKE 'REGION:%';

-- REGION:xxx
INSERT INTO PUNKTINFO (REGISTRERINGFRA, REGISTRERINGTIL, INFOTYPE, SAGSEVENTID, PUNKTID)
SELECT 
    p.REGISTRERINGFRA AS REGISTRERINGFRA,
    NULL AS REGISTRERINGTIL,
    'REGION:' || r.RGN_PRFX  AS INFOTYPE,
    '15101d43-ac91-4c7c-9e58-c7a0b5367910' AS SAGSEVENTID,
    conv.ID AS PUNKTID
FROM PUNKT p
INNER JOIN CONV_PUNKT conv ON p.ID = conv.ID
INNER JOIN HVD_REF@refgeo href ON href.REFNR = conv.REFNR
INNER JOIN RGN_TABLE@refgeo r ON href.RGN = r.RGN_NO
;

COMMIT;