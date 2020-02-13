﻿/* -------------------------------------------------------------------------- */
/* Make PUNKTINFO data (with namespace ATTR).
/* Data is found in REFGEO tables ADGANG, QUICKSTNINFORM and HVD_REF
/* File: MakePunktInfoATTR.sql
/* -------------------------------------------------------------------------- */
/*
SPØRGSMÅL
*/

DELETE FROM PUNKTINFO WHERE INFOTYPEID IN (SELECT INFOTYPEID FROM PUNKTINFOTYPE WHERE INFOTYPE LIKE 'ATTR:%');

-- ATTR:restricted
INSERT INTO PUNKTINFO (REGISTRERINGFRA, REGISTRERINGTIL, INFOTYPEID, SAGSEVENTFRAID, PUNKTID)
SELECT
    adgf.IN_DATE AS REGISTRERINGFRA,
    adgt.IN_DATE AS REGISTRERINGTIL,
    (SELECT INFOTYPEID FROM PUNKTINFOTYPE WHERE INFOTYPE = 'ATTR:restricted' AND ROWNUM <= 1) AS INFOTYPEID,
    '15101d43-ac91-4c7c-9e58-c7a0b5367910' AS SAGSEVENTFRAID,
    conv.ID AS PUNKTID
FROM PUNKT p
INNER JOIN CONV_PUNKT conv ON p.ID = conv.ID
INNER JOIN ADGANG@refgeo adgf ON adgf.REFNR = conv.REFNR AND adgf.TILGANG = 1
LEFT JOIN ADGANG@refgeo adgt ON adgf.REFNR = adgt.REFNR AND (adgf.VERSNR+1) = adgt.VERSNR AND adgt.TILGANG = 1
;

-- ATTR:tabtgået
INSERT INTO PUNKTINFO (REGISTRERINGFRA, REGISTRERINGTIL, INFOTYPEID, SAGSEVENTFRAID, PUNKTID)
SELECT
    p.REGISTRERINGFRA AS REGISTRERINGFRA,
    NULL AS REGISTRERINGTIL,
    (SELECT INFOTYPEID FROM PUNKTINFOTYPE WHERE INFOTYPE = 'ATTR:tabtgået' AND ROWNUM <= 1) AS INFOTYPEID,
    '15101d43-ac91-4c7c-9e58-c7a0b5367910' AS SAGSEVENTFRAID,
    conv.ID AS PUNKTID
FROM PUNKT p
INNER JOIN CONV_PUNKT conv ON p.ID = conv.ID
INNER JOIN QUICKSTNINFORM@refgeo q ON q.REFNR = conv.REFNR AND q.T_MARK = 1
;

-- ATTR:ekstern
INSERT INTO PUNKTINFO (REGISTRERINGFRA, REGISTRERINGTIL, INFOTYPEID, SAGSEVENTFRAID, PUNKTID)
SELECT
    p.REGISTRERINGFRA AS REGISTRERINGFRA,
    NULL AS REGISTRERINGTIL,
    (SELECT INFOTYPEID FROM PUNKTINFOTYPE WHERE INFOTYPE = 'ATTR:ekstern' AND ROWNUM <= 1) AS INFOTYPEID,
    '15101d43-ac91-4c7c-9e58-c7a0b5367910' AS SAGSEVENTFRAID,
    conv.ID AS PUNKTID
FROM PUNKT p
INNER JOIN CONV_PUNKT conv ON p.ID = conv.ID
INNER JOIN QUICKSTNINFORM@refgeo q ON q.REFNR = conv.REFNR AND q.E_MARK = 1
;

-- ATTR:vandstandsmåler
INSERT INTO PUNKTINFO (REGISTRERINGFRA, REGISTRERINGTIL, INFOTYPEID, SAGSEVENTFRAID, PUNKTID)
SELECT
    p.REGISTRERINGFRA AS REGISTRERINGFRA,
    NULL AS REGISTRERINGTIL,
    (SELECT INFOTYPEID FROM PUNKTINFOTYPE WHERE INFOTYPE = 'ATTR:vandstandsmåler' AND ROWNUM <= 1) AS INFOTYPEID,
    '15101d43-ac91-4c7c-9e58-c7a0b5367910' AS SAGSEVENTFRAID,
    conv.ID AS PUNKTID
FROM PUNKT p
INNER JOIN CONV_PUNKT conv ON p.ID = conv.ID
INNER JOIN HVD_REF@refgeo href ON href.REFNR = conv.REFNR AND href.LBN = 86
;

-- ATTR:gnss_egnet
INSERT INTO PUNKTINFO (REGISTRERINGFRA, REGISTRERINGTIL, INFOTYPEID, SAGSEVENTFRAID, PUNKTID)
SELECT
    anv.IN_DATE AS REGISTRERINGFRA,
    NULL AS REGISTRERINGTIL,
    (SELECT INFOTYPEID FROM PUNKTINFOTYPE WHERE INFOTYPE = 'ATTR:gnss_egnet' AND ROWNUM <= 1) AS INFOTYPEID,
    '15101d43-ac91-4c7c-9e58-c7a0b5367910' AS SAGSEVENTFRAID,
    conv.ID AS PUNKTID
FROM PUNKT p
INNER JOIN CONV_PUNKT conv ON p.ID = conv.ID
INNER JOIN ANVEND@refgeo anv ON anv.REFNR = conv.REFNR AND anv.GPS = 1
;

-- ATTR:beskrivelse
INSERT INTO PUNKTINFO (REGISTRERINGFRA, REGISTRERINGTIL, INFOTYPEID, TEKST, SAGSEVENTFRAID, PUNKTID)
SELECT
    bf.IN_DATE AS REGISTRERINGFRA,
    bt.IN_DATE AS REGISTRERINGTIL,
    (SELECT INFOTYPEID FROM PUNKTINFOTYPE WHERE INFOTYPE = 'ATTR:beskrivelse' AND ROWNUM <= 1) AS INFOTYPEID,
    bf.TEKST AS TEKST,
    '15101d43-ac91-4c7c-9e58-c7a0b5367910' AS SAGSEVENTFRAID,
    conv.ID AS PUNKTID
FROM PUNKT p
INNER JOIN CONV_PUNKT conv ON p.ID = conv.ID
INNER JOIN BSK@refgeo bf ON bf.REFNR = conv.REFNR
LEFT JOIN BSK@refgeo bt ON bf.REFNR = bt.REFNR AND (bf.VERSNR+1) = bt.VERSNR
WHERE bf.IN_DATE < bt.IN_DATE OR bt.IN_DATE IS NULL
;

-- ATTR:højdefikspunkt
INSERT INTO PUNKTINFO (REGISTRERINGFRA, REGISTRERINGTIL, INFOTYPEID, SAGSEVENTFRAID, PUNKTID)
SELECT
    p.REGISTRERINGFRA AS REGISTRERINGFRA,
    NULL AS REGISTRERINGTIL,
    (SELECT INFOTYPEID FROM PUNKTINFOTYPE WHERE INFOTYPE = 'ATTR:højdefikspunkt' AND ROWNUM <= 1) AS INFOTYPEID,
    '15101d43-ac91-4c7c-9e58-c7a0b5367910' AS SAGSEVENTFRAID,
    conv.ID AS PUNKTID
FROM PUNKT p
INNER JOIN CONV_PUNKT conv ON p.ID = conv.ID
INNER JOIN HVD_REF@refgeo href ON href.REFNR = conv.REFNR AND href.MV_STATUS = 0
;

-- ATTR:MV_punkt
INSERT INTO PUNKTINFO (REGISTRERINGFRA, REGISTRERINGTIL, INFOTYPEID, SAGSEVENTFRAID, PUNKTID)
SELECT
    p.REGISTRERINGFRA AS REGISTRERINGFRA,
    NULL AS REGISTRERINGTIL,
    (SELECT INFOTYPEID FROM PUNKTINFOTYPE WHERE INFOTYPE = 'ATTR:MV_punkt' AND ROWNUM <= 1) AS INFOTYPEID,
    '15101d43-ac91-4c7c-9e58-c7a0b5367910' AS SAGSEVENTFRAID,
    conv.ID AS PUNKTID
FROM PUNKT p
INNER JOIN CONV_PUNKT conv ON p.ID = conv.ID
INNER JOIN HVD_REF@refgeo href ON href.REFNR = conv.REFNR AND href.MV_STATUS = 1
;

-- ATTR:GI_punkt
INSERT INTO PUNKTINFO (REGISTRERINGFRA, REGISTRERINGTIL, INFOTYPEID, SAGSEVENTFRAID, PUNKTID)
SELECT
    p.REGISTRERINGFRA AS REGISTRERINGFRA,
    NULL AS REGISTRERINGTIL,
    (SELECT INFOTYPEID FROM PUNKTINFOTYPE WHERE INFOTYPE = 'ATTR:GI_punkt' AND ROWNUM <= 1) AS INFOTYPEID,
    '15101d43-ac91-4c7c-9e58-c7a0b5367910' AS SAGSEVENTFRAID,
    conv.ID AS PUNKTID
FROM PUNKT p
INNER JOIN CONV_PUNKT conv ON p.ID = conv.ID
INNER JOIN HVD_REF@refgeo href ON href.REFNR = conv.REFNR AND href.MV_STATUS = 2
;

-- ATTR:hjælpepunkt
INSERT INTO PUNKTINFO (REGISTRERINGFRA, REGISTRERINGTIL, INFOTYPEID, SAGSEVENTFRAID, PUNKTID)
SELECT
    p.REGISTRERINGFRA AS REGISTRERINGFRA,
    NULL AS REGISTRERINGTIL,
    (SELECT INFOTYPEID FROM PUNKTINFOTYPE WHERE INFOTYPE = 'ATTR:hjælpepunkt' AND ROWNUM <= 1) AS INFOTYPEID,
    '15101d43-ac91-4c7c-9e58-c7a0b5367910' AS SAGSEVENTFRAID,
    conv.ID AS PUNKTID
FROM PUNKT p
INNER JOIN CONV_PUNKT conv ON p.ID = conv.ID
INNER JOIN HVD_REF@refgeo href ON href.REFNR = conv.REFNR AND href.MV_STATUS = 3
;

-- ATTR:sømærke
INSERT INTO PUNKTINFO (REGISTRERINGFRA, REGISTRERINGTIL, INFOTYPEID, SAGSEVENTFRAID, PUNKTID)
SELECT
    p.REGISTRERINGFRA AS REGISTRERINGFRA,
    NULL AS REGISTRERINGTIL,
    (SELECT INFOTYPEID FROM PUNKTINFOTYPE WHERE INFOTYPE = 'ATTR:sømærke' AND ROWNUM <= 1) AS INFOTYPEID,
    '15101d43-ac91-4c7c-9e58-c7a0b5367910' AS SAGSEVENTFRAID,
    conv.ID AS PUNKTID
FROM PUNKT p
INNER JOIN CONV_PUNKT conv ON p.ID = conv.ID
INNER JOIN HVD_REF@refgeo href ON href.REFNR = conv.REFNR AND href.MV_STATUS = 4
;

-- ATTR:teknikpunkt
INSERT INTO PUNKTINFO (REGISTRERINGFRA, REGISTRERINGTIL, INFOTYPEID, SAGSEVENTFRAID, PUNKTID)
SELECT
    p.REGISTRERINGFRA AS REGISTRERINGFRA,
    NULL AS REGISTRERINGTIL,
    (SELECT INFOTYPEID FROM PUNKTINFOTYPE WHERE INFOTYPE = 'ATTR:teknikpunkt' AND ROWNUM <= 1) AS INFOTYPEID,
    '15101d43-ac91-4c7c-9e58-c7a0b5367910' AS SAGSEVENTFRAID,
    conv.ID AS PUNKTID
FROM PUNKT p
INNER JOIN CONV_PUNKT conv ON p.ID = conv.ID
INNER JOIN HVD_REF@refgeo href ON href.REFNR = conv.REFNR AND href.MV_STATUS = 5
;

-- ATTR:aerotriangulationspunkt
INSERT INTO PUNKTINFO (REGISTRERINGFRA, REGISTRERINGTIL, INFOTYPEID, SAGSEVENTFRAID, PUNKTID)
SELECT
    p.REGISTRERINGFRA AS REGISTRERINGFRA,
    NULL AS REGISTRERINGTIL,
    (SELECT INFOTYPEID FROM PUNKTINFOTYPE WHERE INFOTYPE = 'ATTR:aerotriangulationspunkt' AND ROWNUM <= 1) AS INFOTYPEID,
    '15101d43-ac91-4c7c-9e58-c7a0b5367910' AS SAGSEVENTFRAID,
    conv.ID AS PUNKTID
FROM PUNKT p
INNER JOIN CONV_PUNKT conv ON p.ID = conv.ID
INNER JOIN HVD_REF@refgeo href ON href.REFNR = conv.REFNR AND href.MV_STATUS = 6
;

-- ATTR:tinglysningsnr
INSERT INTO PUNKTINFO (REGISTRERINGFRA, REGISTRERINGTIL, INFOTYPEID, TEKST, SAGSEVENTFRAID, PUNKTID)
SELECT
    dekf.IN_DATE AS REGISTRERINGFRA,
    dekt.IN_DATE AS REGISTRERINGTIL,
    (SELECT INFOTYPEID FROM PUNKTINFOTYPE WHERE INFOTYPE = 'ATTR:tinglysningsnr' AND ROWNUM <= 1) AS INFOTYPEID,
    'Sagsnummer fra Tingbogen ikke tilgængeligt. Opdatering udestår.' AS TEKST,
    '15101d43-ac91-4c7c-9e58-c7a0b5367910' AS SAGSEVENTFRAID,
    conv.ID AS PUNKTID
FROM PUNKT p
INNER JOIN CONV_PUNKT conv ON p.ID = conv.ID
INNER JOIN deklar@refgeo dekf ON dekf.REFNR = conv.REFNR AND dekf.ejerkode != 2
LEFT JOIN deklar@refgeo dekt ON dekf.REFNR = dekt.REFNR AND (dekf.VERSNR+1) = dekt.VERSNR AND dekt.ejerkode != 2
WHERE dekf.IN_DATE IS NOT NULL
;

-- ATTR:bemærkning
INSERT INTO PUNKTINFO (REGISTRERINGFRA, REGISTRERINGTIL, INFOTYPEID, TEKST, SAGSEVENTFRAID, PUNKTID)
SELECT
    bf.IN_DATE AS REGISTRERINGFRA,
    bt.IN_DATE AS REGISTRERINGTIL,
    (SELECT INFOTYPEID FROM PUNKTINFOTYPE WHERE INFOTYPE = 'ATTR:bemærkning' AND ROWNUM <= 1) AS INFOTYPEID,
     '[' || TO_CHAR(bf.IN_DATE, 'YYYY-MM-DD HH24:MI') || '] ' || bf.BEM AS TEKST,
    '15101d43-ac91-4c7c-9e58-c7a0b5367910' AS SAGSEVENTFRAID,
    conv.ID AS PUNKTID
FROM PUNKT p
INNER JOIN CONV_PUNKT conv ON p.ID = conv.ID
INNER JOIN HVD_BEM@refgeo bf ON bf.REFNR = conv.REFNR
LEFT JOIN HVD_BEM@refgeo bt ON bf.REFNR = bt.REFNR AND (bf.VERSNR+1) = bt.VERSNR
WHERE bf.IN_DATE < bt.IN_DATE OR bt.IN_DATE IS NULL
;


-- ATTR:beskadiget
INSERT INTO PUNKTINFO (REGISTRERINGFRA, REGISTRERINGTIL, INFOTYPEID, SAGSEVENTFRAID, PUNKTID)
SELECT
    p.REGISTRERINGFRA AS REGISTRERINGFRA,
    NULL AS REGISTRERINGTIL,
    (SELECT INFOTYPEID FROM PUNKTINFOTYPE WHERE INFOTYPE = 'ATTR:beskadiget' AND ROWNUM <= 1) AS INFOTYPEID,
    '15101d43-ac91-4c7c-9e58-c7a0b5367910' AS SAGSEVENTFRAID,
    conv.ID AS PUNKTID
FROM PUNKT p
INNER JOIN CONV_PUNKT conv ON p.ID = conv.ID
INNER JOIN TILSTAND@refgeo til ON til.REFNR = conv.REFNR AND til.TILSTAND = 151
;

COMMIT;
