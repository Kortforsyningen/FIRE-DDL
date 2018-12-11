/* -------------------------------------------------------------------------- */
/* Make PUNKT data. We will only transfer white listed punkter according to
/* the following rules: All punkter established in 2016 and beyond plus
/* punkter established before 2016 having a location, observation or position.   
/* File: MakePunkt.sql   
/* -------------------------------------------------------------------------- */

-- Create a list of authoritative punkter
CREATE TABLE AUTHREFNR (
   REFNR INTEGER NOT NULL,
   PRIMARY KEY (REFNR)    
); 

-- Insert all established from 2016 and beyond
INSERT INTO AUTHREFNR (REFNR)
SELECT href.REFNR FROM HVD_REF@refgeo href WHERE href.OPRDATO >= DATE '2016-01-01'
;

-- Insert punkter established before 2016 having a location, observation or position.
INSERT INTO AUTHREFNR (REFNR)
SELECT distrefnr.REFNR
FROM (
    SELECT allrefnr.REFNR 
    FROM (
        -- Lokationer
        SELECT REFNR FROM LOC_CRD@refgeo UNION ALL
        -- Koordinater
        SELECT REFNR FROM dvr90@refgeo UNION ALL
        SELECT REFNR FROM fvr09@refgeo UNION ALL
        SELECT REFNR FROM geo_ed50@refgeo UNION ALL
        SELECT REFNR FROM geo_ed87@refgeo UNION ALL
        SELECT REFNR FROM geo_euref89@refgeo UNION ALL
        SELECT REFNR FROM geo_gr96@refgeo UNION ALL
        SELECT REFNR FROM geo_nad83g@refgeo UNION ALL
        SELECT REFNR FROM gi44@refgeo UNION ALL
        SELECT REFNR FROM gm91@refgeo UNION ALL
        SELECT REFNR FROM gs@refgeo UNION ALL
        SELECT REFNR FROM gsb@refgeo UNION ALL
        SELECT REFNR FROM hpot_dvr90@refgeo UNION ALL
        SELECT REFNR FROM kk@refgeo UNION ALL
        SELECT REFNR FROM kn44@refgeo UNION ALL
        SELECT REFNR FROM msl@refgeo UNION ALL
        SELECT REFNR FROM os@refgeo UNION ALL
        SELECT REFNR FROM s34j@refgeo UNION ALL
        SELECT REFNR FROM s34s@refgeo UNION ALL
        SELECT REFNR FROM s45b@refgeo UNION ALL
        SELECT REFNR FROM sb@refgeo UNION ALL
        SELECT REFNR FROM ts_dvr90@refgeo UNION ALL
        SELECT REFNR FROM ts_euref89@refgeo UNION ALL
        SELECT REFNR FROM ts_lrl@refgeo UNION ALL
        SELECT REFNR FROM tsu32_euref89@refgeo UNION ALL
        SELECT REFNR FROM utm32_ed50@refgeo UNION ALL
        SELECT REFNR FROM utm33_ed50@refgeo UNION ALL
        SELECT REFNR FROM ellh_euref89@refgeo UNION ALL
        SELECT REFNR FROM ellh_gr96@refgeo UNION ALL
        -- Observationer
        SELECT REFNR FROM GG_DST_O@refgeo UNION ALL
        SELECT REFNR FROM GG_VT3_O@refgeo UNION ALL
        SELECT REFNR FROM NI_MTZ_O@refgeo UNION ALL
        SELECT REFNR FROM NI_NIV_O@refgeo UNION ALL
        SELECT REFNR FROM NI_PRS_O@refgeo UNION ALL
        SELECT REFNR FROM NI_ZDS_O@refgeo UNION ALL
        SELECT REFNR FROM RG_DIR_O@refgeo UNION ALL
        SELECT REFNR FROM RG_DST_O@refgeo
    ) allrefnr
    GROUP BY allrefnr.REFNR
) distrefnr
INNER JOIN HVD_REF@refgeo href ON distrefnr.REFNR = href.REFNR AND href.OPRDATO < TO_DATE('2016-01-01','YYYY-MM-DD')
;

-- Create PUNKT table based on authoritative punkter
INSERT INTO PUNKT (
    ID, 
    REGISTRERINGFRA, 
    REGISTRERINGTIL, 
    SAGSEVENTID
)
SELECT 
    conv.ID,
    href.OPRDATO,
    NULL,
    'e964cca6-7b16-414a-9538-8639eacaac3d' -- SELECT ID FROM SAGSEVENT WHERE EVENT = 'punkt_oprettet'; brug den yngste
FROM HVD_REF@refgeo href
INNER JOIN AUTHREFNR auth ON href.REFNR = auth.REFNR
INNER JOIN CONV_PUNKT conv ON href.REFNR = conv.REFNR
ORDER BY href.OPRDATO DESC
-- FETCH FIRST 1000 ROWS ONLY -- only for datadump
;

COMMIT;