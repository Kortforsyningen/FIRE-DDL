/* -------------------------------------------------------------------------- */
/* Make PUNKTINFO data (with namespace AFM). 
/* File: MakePunktInfoAFM.sql   
/* -------------------------------------------------------------------------- */
/*
SPØRGSMÅL
*/



DELETE FROM PUNKTINFO WHERE INFOTYPE LIKE 'AFM:%';
-- SELECT COUNT(*) FROM PUNKTINFO WHERE INFOTYPE LIKE 'AFM:%';
-- SELECT INFOTYPE, COUNT(*) FROM PUNKTINFO WHERE INFOTYPE LIKE 'AFM:%' GROUP BY INFOTYPE;

-- Afmærkninger skal stykkes sammen fra to forskellige tabeller: AFMTXT og AFMTYP_TXT. 
-- Førstnævnte er en samlekasse til alle de afmærkningsbeskrivelse der ikke er er standardisere. Dem gemmer vi under en kategori med URN'en AFM:diverse. 
-- De resterende afmærkningsbeskrivelser er de standardiserede der findes i AFMTYP_TXT. De får URN'er bestemt ud fra kolonnen AFMTYP, sådan at de bliver AFM:xxxx.
-- Koblingen mellem punkterne og afmærkningstyperne findes i FYSIK tabellen, hvor refnr kan knyttes til rækker i AFMTYP_TXT. 
-- For de afmærkningern hvor der ikke findes en standardiseret type vil AFMTYP_TXT.TEKST være "p_afmtxt". Dette betyder at refnr'eret i stedet skal slås op i AFMTXT. 
-- Disse skal gemmes som tekstværdi under URN'en AFM:diverse.

-- Lav temporær tabel med afmærkninger og hvor højde_over_ er sorteret fra. Årsagen er at historik ellers bliver fejlagtig
CREATE TABLE FYSIK_AFM AS
SELECT ss.REFNR, ss.AFMTYP, ss.IN_DATE, ss.my_versnr AS VERSNR FROM 
(
    SELECT s.REFNR, AFMTYP, s.IN_DATE, ROW_NUMBER() OVER (PARTITION BY REFNR ORDER BY s.REFNR, s.IN_DATE) my_versnr FROM 
    (
        SELECT REFNR, AFMTYP, MIN(IN_DATE) AS IN_DATE FROM FYSIK@refgeo GROUP BY REFNR, AFMTYP
    ) s
) ss;

-- AFM:xxxx (dem med standardiseret afmtyp)
INSERT INTO PUNKTINFO (REGISTRERINGFRA, REGISTRERINGTIL, INFOTYPE, TEKST, SAGSEVENTID, PUNKTID)
SELECT 
    afmfrom.IN_DATE AS REGISTRERINGFRA,
    afmto.IN_DATE AS REGISTRERINGTIL,
    'AFM:' || afmfrom.AFMTYP AS INFOTYPE,
    afmtyp.TEKST AS TEKST,
    '15101d43-ac91-4c7c-9e58-c7a0b5367910' AS SAGSEVENTID,
    conv.ID AS PUNKTID
FROM FYSIK_AFM afmfrom
INNER JOIN CONV_PUNKT conv ON afmfrom.REFNR = conv.REFNR
INNER JOIN PUNKT p ON p.ID = conv.ID
INNER JOIN AFMTYP_TXT@refgeo afmtyp ON afmfrom.AFMTYP = afmtyp.AFMTYP AND afmtyp.TEKST != 'p_afmtxt' -- betyder kun dem med standardiseret afmtyp
LEFT JOIN FYSIK_AFM afmto ON afmfrom.REFNR = afmto.REFNR AND (afmfrom.VERSNR+1) = afmto.VERSNR  
;

-- AFM:diverse (alle de ikke-standardiserede)
INSERT INTO PUNKTINFO (REGISTRERINGFRA, REGISTRERINGTIL, INFOTYPE, TEKST, SAGSEVENTID, PUNKTID)
SELECT 
    afmfrom.IN_DATE AS REGISTRERINGFRA,
    afmto.IN_DATE AS REGISTRERINGTIL,
    'AFM:diverse' AS INFOTYPE,
    afm.TEKST AS TEKST,
    '15101d43-ac91-4c7c-9e58-c7a0b5367910' AS SAGSEVENTID,
    conv.ID AS PUNKTID
FROM FYSIK_AFM afmfrom
INNER JOIN CONV_PUNKT conv ON afmfrom.REFNR = conv.REFNR
INNER JOIN PUNKT p ON p.ID = conv.ID
INNER JOIN AFMTYP_TXT@refgeo afmtyp ON afmfrom.AFMTYP = afmtyp.AFMTYP AND afmtyp.TEKST = 'p_afmtxt' -- kun dem med speciel afmtype
INNER JOIN AFMTXT@refgeo afm ON afmfrom.REFNR = afm.REFNR
LEFT JOIN FYSIK_AFM afmto ON afmfrom.REFNR = afmto.REFNR AND (afmfrom.VERSNR+1) = afmto.VERSNR
;


-- AFM:horisontal, AFM:horisontalvertikal, AFM:vertikal
INSERT INTO PUNKTINFO (REGISTRERINGFRA, REGISTRERINGTIL, INFOTYPE, SAGSEVENTID, PUNKTID)
SELECT 
    afmfrom.IN_DATE AS REGISTRERINGFRA,
    afmto.IN_DATE AS REGISTRERINGTIL,
    CASE      
        WHEN SUBSTR(afmfrom.AFMTYP, 1, 1) = '1' THEN 'AFM:horisontal' 
        WHEN SUBSTR(afmfrom.AFMTYP, 1, 1) = '2' THEN 'AFM:vertikal' 
        ELSE 'AFM:horisontalvertikal'
    END AS INFOTYPE,
    '15101d43-ac91-4c7c-9e58-c7a0b5367910' AS SAGSEVENTID,
    conv.ID AS PUNKTID
FROM FYSIK_AFM afmfrom
INNER JOIN CONV_PUNKT conv ON afmfrom.REFNR = conv.REFNR
INNER JOIN PUNKT p ON p.ID = conv.ID
LEFT JOIN FYSIK_AFM afmto ON afmfrom.REFNR = afmto.REFNR AND (afmfrom.VERSNR+1) = afmto.VERSNR
WHERE afmfrom.AFMTYP >=1000 AND afmfrom.AFMTYP < 4000
;  

-- AFM:naturlig, bemærk ingen historik pga. QUICKSTNINFORM (indeholder kun gældende værdier) 
INSERT INTO PUNKTINFO (REGISTRERINGFRA, REGISTRERINGTIL, INFOTYPE, TEKST, SAGSEVENTID, PUNKTID)
SELECT 
    href.OPRDATO AS REGISTRERINGFRA,
    NULL AS REGISTRERINGTIL,
    'AFM:naturlig' AS INFOTYPE,
    NULL AS TEKST,
    '15101d43-ac91-4c7c-9e58-c7a0b5367910' AS SAGSEVENTID,
    conv.ID AS PUNKTID
FROM PUNKT p
INNER JOIN CONV_PUNKT conv ON p.ID = conv.ID
INNER JOIN HVD_REF@refgeo href ON href.REFNR = conv.REFNR
INNER JOIN QUICKSTNINFORM@refgeo n ON n.REFNR = conv.REFNR AND n.n_mark=1
;

-- Lav temporær tabel med hvor højde_over_ og hvor afmtyp er sorteret fra. Årsagen er at historik ellers bliver fejlagtig
CREATE TABLE FYSIK_HOEJDE AS
SELECT ss.REFNR, ss.HEIGHT_TYP, ss.HEIGHT, ss.IN_DATE, ss.my_versnr AS VERSNR FROM 
(
    SELECT s.REFNR, s.HEIGHT_TYP, s.HEIGHT, s.IN_DATE, ROW_NUMBER() OVER (PARTITION BY REFNR ORDER BY s.REFNR, s.IN_DATE) my_versnr FROM 
    (
        SELECT REFNR, HEIGHT_TYP, HEIGHT, MIN(IN_DATE) AS IN_DATE FROM FYSIK@refgeo WHERE HEIGHT IS NOT NULL GROUP BY REFNR, HEIGHT_TYP, HEIGHT
    ) s
) ss;

-- AFM:højde_over_xxx (ca. 12 stk)
INSERT INTO PUNKTINFO (REGISTRERINGFRA, REGISTRERINGTIL, INFOTYPE, TAL, SAGSEVENTID, PUNKTID)
SELECT 
    hfrom.IN_DATE AS REGISTRERINGFRA,
    hto.IN_DATE AS REGISTRERINGTIL,
    'AFM:højde_over_' || trim('.' FROM height.TEKST) AS INFOTYPE,
    hfrom.HEIGHT AS TAL,
    '15101d43-ac91-4c7c-9e58-c7a0b5367910' AS SAGSEVENTID,
    conv.ID AS PUNKTID
FROM FYSIK_HOEJDE hfrom
INNER JOIN CONV_PUNKT conv ON hfrom.REFNR = conv.REFNR
INNER JOIN PUNKT p ON p.ID = conv.ID
INNER JOIN (SELECT * FROM HEIGHT_TXT@refgeo WHERE HEIGHT_TYP > 0) height ON hfrom.HEIGHT_TYP = height.HEIGHT_TYP
LEFT JOIN FYSIK_HOEJDE hto ON hfrom.REFNR = hto.REFNR AND (hfrom.VERSNR+1) = hto.VERSNR
;

-- Clean up
DROP TABLE FYSIK_AFM PURGE;
DROP TABLE FYSIK_HOEJDE PURGE;

-- Commit
COMMIT;