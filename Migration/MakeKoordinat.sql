/* -------------------------------------------------------------------------- */
/* Make KOORDINAT data. 
/* File: MakeKoordinat.sql   
/* -------------------------------------------------------------------------- */

/*
Heads up 
TID_5D er ikke medtaget. Afventer SDFE
Der medtages kun koordinater hvor regFra < regTil (pga. datafejl og konflikt med constraints)
*/


DELETE FROM KOORDINAT;

-- Indsæt data fra alle koordinat tabeller i REF_GEO
-- Undtaget tidsserier, håndteres senere
INSERT INTO KOORDINAT (
    REGISTRERINGFRA, 
    REGISTRERINGTIL, 
    SRID, 
    SX, 
    SY, 
    SZ, 
    T, 
    TRANSFORMERET, 
    X, 
    Y, 
    Z, 
    SAGSEVENTID, 
    PUNKTID
) 
SELECT 
    coor.IN_DATE,
    coor.OUT_DATE,
    coor.SRID AS SRID,
    coor.SX,
    coor.SY,
    coor.SZ,
    coor.T,
    CASE WHEN coor.ARTSKODE = 6 THEN 'true' ELSE 'false' END AS BEREGNET,
    coor.X,
    coor.Y, 
    coor.Z,
    '7f2952b7-7729-4952-8f05-b4f372abe939', -- SELECT ID FROM SAGSEVENT WHERE EVENT = 'koordinat_beregnet';
    p.ID
FROM PUNKT p
INNER JOIN CONV_PUNKT conv ON p.ID = conv.ID
LEFT JOIN 
(
    SELECT cf.REFNR, 'EPSG:5799' AS SRID, cf.HBERDATO AS T, NULL AS X, NULL AS Y, cf.H AS Z, NULL AS SX, NULL AS SY, cf.H_MF AS SZ, cf.IN_DATE AS IN_DATE, ct.IN_DATE AS OUT_DATE, cf.ARTSKODE FROM dvr90@refgeo cf LEFT JOIN dvr90@refgeo ct ON cf.REFNR = ct.REFNR AND (cf.VERSNR+1) = ct.VERSNR UNION ALL
    SELECT cf.REFNR, 'EPSG:5317' AS SRID, cf.HBERDATO AS T, NULL AS X, NULL AS Y, cf.H AS Z, NULL AS SX, NULL AS SY, cf.H_MF AS SZ, cf.IN_DATE AS IN_DATE, ct.IN_DATE AS OUT_DATE, cf.ARTSKODE FROM fvr09@refgeo cf LEFT JOIN fvr09@refgeo ct ON cf.REFNR = ct.REFNR AND (cf.VERSNR+1) = ct.VERSNR UNION ALL
    SELECT cf.REFNR, 'EPSG:4230' AS SRID, cf.CBERDATO AS T, cf.E AS X, cf.N AS Y, NULL AS Z, cf.KOOR_MF AS SX, cf.KOOR_MF AS SY, NULL AS SZ, cf.IN_DATE AS IN_DATE, ct.IN_DATE AS OUT_DATE, cf.ARTSKODE FROM geo_ed50@refgeo cf LEFT JOIN geo_ed50@refgeo ct ON cf.REFNR = ct.REFNR AND (cf.VERSNR+1) = ct.VERSNR UNION ALL
    SELECT cf.REFNR, 'EPSG:4231' AS SRID, cf.CBERDATO AS T, cf.E AS X, cf.N AS Y, NULL AS Z, cf.KOOR_MF AS SX, cf.KOOR_MF AS SY, NULL AS SZ, cf.IN_DATE AS IN_DATE, ct.IN_DATE AS OUT_DATE, cf.ARTSKODE FROM geo_ed87@refgeo cf LEFT JOIN geo_ed87@refgeo ct ON cf.REFNR = ct.REFNR AND (cf.VERSNR+1) = ct.VERSNR UNION ALL
    SELECT cf.REFNR, 'GL:4747' AS SRID, cf.CBERDATO AS T, cf.E AS X, cf.N AS Y, NULL AS Z, cf.KOOR_MF AS SX, cf.KOOR_MF AS SY, NULL AS SZ, cf.IN_DATE AS IN_DATE, ct.IN_DATE AS OUT_DATE, cf.ARTSKODE FROM geo_nad83g@refgeo cf LEFT JOIN geo_nad83g@refgeo ct ON cf.REFNR = ct.REFNR AND (cf.VERSNR+1) = ct.VERSNR UNION ALL
    SELECT cf.REFNR, 'LOC:GI44' AS SRID, cf.HBERDATO AS T, NULL AS X, NULL AS Y, cf.H AS Z, NULL AS SX, NULL AS SY, cf.H_MF AS SZ, cf.IN_DATE AS IN_DATE, ct.IN_DATE AS OUT_DATE, cf.ARTSKODE FROM gi44@refgeo cf LEFT JOIN gi44@refgeo ct ON cf.REFNR = ct.REFNR AND (cf.VERSNR+1) = ct.VERSNR UNION ALL
    SELECT cf.REFNR, 'LOC:GM91' AS SRID, cf.HBERDATO AS T, NULL AS X, NULL AS Y, cf.H AS Z, NULL AS SX, NULL AS SY, cf.H_MF AS SZ, cf.IN_DATE AS IN_DATE, ct.IN_DATE AS OUT_DATE, cf.ARTSKODE FROM gm91@refgeo cf LEFT JOIN gm91@refgeo ct ON cf.REFNR = ct.REFNR AND (cf.VERSNR+1) = ct.VERSNR UNION ALL
    SELECT cf.REFNR, 'DK:GS' AS SRID, cf.CBERDATO AS T, cf.E AS X, cf.N AS Y, NULL AS Z, cf.KOOR_MF AS SX, cf.KOOR_MF AS SY, NULL AS SZ, cf.IN_DATE AS IN_DATE, ct.IN_DATE AS OUT_DATE, cf.ARTSKODE FROM gs@refgeo cf LEFT JOIN gs@refgeo ct ON cf.REFNR = ct.REFNR AND (cf.VERSNR+1) = ct.VERSNR UNION ALL
    SELECT cf.REFNR, 'DK:GSB' AS SRID, cf.CBERDATO AS T, cf.E AS X, cf.N AS Y, NULL AS Z, cf.KOOR_MF AS SX, cf.KOOR_MF AS SY, NULL AS SZ, cf.IN_DATE AS IN_DATE, ct.IN_DATE AS OUT_DATE, cf.ARTSKODE FROM gsb@refgeo cf LEFT JOIN gsb@refgeo ct ON cf.REFNR = ct.REFNR AND (cf.VERSNR+1) = ct.VERSNR UNION ALL
    SELECT cf.REFNR, 'LOC:HPOT_DRV90' AS SRID, cf.HBERDATO AS T, NULL AS X, NULL AS Y, cf.H AS Z, NULL AS SX, NULL AS SY, cf.H_MF AS SZ, cf.IN_DATE AS IN_DATE, ct.IN_DATE AS OUT_DATE, cf.ARTSKODE FROM hpot_dvr90@refgeo cf LEFT JOIN hpot_dvr90@refgeo ct ON cf.REFNR = ct.REFNR AND (cf.VERSNR+1) = ct.VERSNR UNION ALL
    SELECT cf.REFNR, 'DK:KK' AS SRID, cf.CBERDATO AS T, cf.E AS X, cf.N AS Y, NULL AS Z, cf.KOOR_MF AS SX, cf.KOOR_MF AS SY, NULL AS SZ, cf.IN_DATE AS IN_DATE, ct.IN_DATE AS OUT_DATE, cf.ARTSKODE FROM kk@refgeo cf LEFT JOIN kk@refgeo ct ON cf.REFNR = ct.REFNR AND (cf.VERSNR+1) = ct.VERSNR UNION ALL
    SELECT cf.REFNR, 'LOC:KN44' AS SRID, cf.HBERDATO AS T, NULL AS X, NULL AS Y, cf.H AS Z, NULL AS SX, NULL AS SY, cf.H_MF AS SZ, cf.IN_DATE AS IN_DATE, ct.IN_DATE AS OUT_DATE, cf.ARTSKODE FROM kn44@refgeo cf LEFT JOIN kn44@refgeo ct ON cf.REFNR = ct.REFNR AND (cf.VERSNR+1) = ct.VERSNR UNION ALL
    SELECT cf.REFNR, 'LOC:MSL' AS SRID, cf.HBERDATO AS T, NULL AS X, NULL AS Y, cf.H AS Z, NULL AS SX, NULL AS SY, cf.H_MF AS SZ, cf.IN_DATE AS IN_DATE, ct.IN_DATE AS OUT_DATE, cf.ARTSKODE FROM msl@refgeo cf LEFT JOIN msl@refgeo ct ON cf.REFNR = ct.REFNR AND (cf.VERSNR+1) = ct.VERSNR UNION ALL
    SELECT cf.REFNR, 'DK:OS' AS SRID, cf.CBERDATO AS T, cf.E AS X, cf.N AS Y, NULL AS Z, cf.KOOR_MF AS SX, cf.KOOR_MF AS SY, NULL AS SZ, cf.IN_DATE AS IN_DATE, ct.IN_DATE AS OUT_DATE, cf.ARTSKODE FROM os@refgeo cf LEFT JOIN os@refgeo ct ON cf.REFNR = ct.REFNR AND (cf.VERSNR+1) = ct.VERSNR UNION ALL
    SELECT cf.REFNR, 'DK:S34J' AS SRID, cf.CBERDATO AS T, cf.E AS X, cf.N AS Y, NULL AS Z, cf.KOOR_MF AS SX, cf.KOOR_MF AS SY, NULL AS SZ, cf.IN_DATE AS IN_DATE, ct.IN_DATE AS OUT_DATE, cf.ARTSKODE FROM s34j@refgeo cf LEFT JOIN s34j@refgeo ct ON cf.REFNR = ct.REFNR AND (cf.VERSNR+1) = ct.VERSNR UNION ALL
    SELECT cf.REFNR, 'DK:S34S' AS SRID, cf.CBERDATO AS T, cf.E AS X, cf.N AS Y, NULL AS Z, cf.KOOR_MF AS SX, cf.KOOR_MF AS SY, NULL AS SZ, cf.IN_DATE AS IN_DATE, ct.IN_DATE AS OUT_DATE, cf.ARTSKODE FROM s34s@refgeo cf LEFT JOIN s34s@refgeo ct ON cf.REFNR = ct.REFNR AND (cf.VERSNR+1) = ct.VERSNR UNION ALL
    SELECT cf.REFNR, 'DK:S45B' AS SRID, cf.CBERDATO AS T, cf.E AS X, cf.N AS Y, NULL AS Z, cf.KOOR_MF AS SX, cf.KOOR_MF AS SY, NULL AS SZ, cf.IN_DATE AS IN_DATE, ct.IN_DATE AS OUT_DATE, cf.ARTSKODE FROM s45b@refgeo cf LEFT JOIN s45b@refgeo ct ON cf.REFNR = ct.REFNR AND (cf.VERSNR+1) = ct.VERSNR UNION ALL
    SELECT cf.REFNR, 'DK:SB' AS SRID, cf.CBERDATO AS T, cf.E AS X, cf.N AS Y, NULL AS Z, cf.KOOR_MF AS SX, cf.KOOR_MF AS SY, NULL AS SZ, cf.IN_DATE AS IN_DATE, ct.IN_DATE AS OUT_DATE, cf.ARTSKODE FROM sb@refgeo cf LEFT JOIN sb@refgeo ct ON cf.REFNR = ct.REFNR AND (cf.VERSNR+1) = ct.VERSNR UNION ALL
    SELECT cf.REFNR, 'TS:LRL' AS SRID, cf.HBERDATO AS T, NULL AS X, NULL AS Y, cf.H AS Z, NULL AS SX, NULL AS SY, cf.H_MF AS SZ, cf.IN_DATE AS IN_DATE, ct.IN_DATE AS OUT_DATE, cf.ARTSKODE FROM ts_lrl@refgeo cf LEFT JOIN ts_lrl@refgeo ct ON cf.REFNR = ct.REFNR AND (cf.VERSNR+1) = ct.VERSNR UNION ALL
    SELECT cf.REFNR, 'EPSG:25832' AS SRID, cf.CBERDATO AS T, cf.E AS X, cf.N AS Y, NULL AS Z, cf.KOOR_MF AS SX, cf.KOOR_MF AS SY, NULL AS SZ, cf.IN_DATE AS IN_DATE, ct.IN_DATE AS OUT_DATE, cf.ARTSKODE FROM tsu32_euref89@refgeo cf LEFT JOIN tsu32_euref89@refgeo ct ON cf.REFNR = ct.REFNR AND (cf.VERSNR+1) = ct.VERSNR UNION ALL
    SELECT cf.REFNR, 'EPSG:23032' AS SRID, cf.CBERDATO AS T, cf.E AS X, cf.N AS Y, NULL AS Z, cf.KOOR_MF AS SX, cf.KOOR_MF AS SY, NULL AS SZ, cf.IN_DATE AS IN_DATE, ct.IN_DATE AS OUT_DATE, cf.ARTSKODE FROM utm32_ed50@refgeo cf LEFT JOIN utm32_ed50@refgeo ct ON cf.REFNR = ct.REFNR AND (cf.VERSNR+1) = ct.VERSNR UNION ALL
    SELECT cf.REFNR, 'EPSG:23033' AS SRID, cf.CBERDATO AS T, cf.E AS X, cf.N AS Y, NULL AS Z, cf.KOOR_MF AS SX, cf.KOOR_MF AS SY, NULL AS SZ, cf.IN_DATE AS IN_DATE, ct.IN_DATE AS OUT_DATE, cf.ARTSKODE FROM utm33_ed50@refgeo cf LEFT JOIN utm33_ed50@refgeo ct ON cf.REFNR = ct.REFNR AND (cf.VERSNR+1) = ct.VERSNR UNION ALL
    -- TID_5D har anden struktur og mangler VERSNR, ARTSKODE OG CBERDATO - de er sat til null. AFVENTER SDFE
--    SELECT cf.REFNR, 'EPSG:XXX' AS SRID, NULL AS T, cf.XKOOR AS X, cf.YKOOR AS Y, cf.ZKOOR AS Z, cf.XRMS AS SX, cf.YRMS AS SY, cf.ZRMS AS SZ, cf.IN_DATE AS IN_DATE, NULL AS OUT_DATE, NULL AS ARTSKODE FROM refadm.tid_5d@refgeo cf UNION ALL

    -- geo_euref89 (2d) joines med ellh_euref89 (1d). Hvis der er et join indsættes flettes data til 3d koordinat (EPSG:4937), ellers indsættes 2d (EPSG:4258). SZ sættes til 3 x SX 
    SELECT cf.REFNR, CASE WHEN cf.ELLH IS NOT NULL THEN 'EPSG:4937' ELSE 'EPSG:4258' END AS SRID, cf.CBERDATO AS T, cf.E AS X, cf.N AS Y, cf.ELLH AS Z, cf.KOOR_MF AS SX, cf.KOOR_MF AS SY, (3*cf.KOOR_MF) AS SZ, cf.IN_DATE AS IN_DATE, ct.IN_DATE AS OUT_DATE, cf.ARTSKODE 
    FROM (
        SELECT xy.REFNR, xy.CBERDATO, xy.E, xy.N, z.ELLH, xy.KOOR_MF, xy.IN_DATE, xy.VERSNR, xy.ARTSKODE FROM geo_euref89@refgeo xy LEFT JOIN ellh_euref89@refgeo z ON xy.REFNR = z.REFNR AND xy.CBERDATO=z.CBERDATO
    ) cf 
    LEFT JOIN (
        SELECT xy.REFNR, xy.CBERDATO, xy.E, xy.N, z.ELLH, xy.KOOR_MF, xy.IN_DATE, xy.VERSNR, xy.ARTSKODE FROM geo_euref89@refgeo xy LEFT JOIN ellh_euref89@refgeo z ON xy.REFNR = z.REFNR AND xy.CBERDATO=z.CBERDATO
    ) ct ON cf.REFNR = ct.REFNR AND (cf.VERSNR+1) = ct.VERSNR UNION ALL
    
    -- geo_gr96 (2d) joines med ellh_gr96 (1d). Hvis der er et join indsættes flettes data til 3d koordinat (EPSG:4909), ellers indsættes 2d (EPSG:4747). SZ sættes til 3 x SX 
    SELECT cf.REFNR, CASE WHEN cf.ELLH IS NOT NULL THEN 'EPSG:4909' ELSE 'EPSG:4747' END AS SRID, cf.CBERDATO AS T, cf.E AS X, cf.N AS Y, cf.ELLH AS Z, cf.KOOR_MF AS SX, cf.KOOR_MF AS SY, (3*cf.KOOR_MF) AS SZ, cf.IN_DATE AS IN_DATE, ct.IN_DATE AS OUT_DATE, cf.ARTSKODE 
    FROM (
        SELECT xy.REFNR, xy.CBERDATO, xy.E, xy.N, z.ELLH, xy.KOOR_MF, xy.IN_DATE, xy.VERSNR, xy.ARTSKODE FROM geo_gr96@refgeo xy LEFT JOIN ellh_gr96@refgeo z ON xy.REFNR = z.REFNR AND xy.CBERDATO=z.CBERDATO
    ) cf 
    LEFT JOIN (
        SELECT xy.REFNR, xy.CBERDATO, xy.E, xy.N, z.ELLH, xy.KOOR_MF, xy.IN_DATE, xy.VERSNR, xy.ARTSKODE FROM geo_gr96@refgeo xy LEFT JOIN ellh_gr96@refgeo z ON xy.REFNR = z.REFNR AND xy.CBERDATO=z.CBERDATO
    ) ct ON cf.REFNR = ct.REFNR AND (cf.VERSNR+1) = ct.VERSNR
) coor ON conv.REFNR = coor.REFNR
WHERE coor.SRID IS NOT NULL AND coor.IN_DATE < coor.OUT_DATE
;

-- Tidsserier skal håndteres anderledes. Jessenpunkt bruges som SRID
-- TS_DVR90 + TS_EUREF89
INSERT INTO KOORDINAT (
    REGISTRERINGFRA, REGISTRERINGTIL, SRID, SX, SY, SZ, T, TRANSFORMERET, X, Y, Z, SAGSEVENTID, PUNKTID
)
SELECT 
--    coor.REFNR,
    coor.IN_DATE,
    coor.OUT_DATE,
    coor.SRID AS SRID,
    coor.SX,
    coor.SY,
    coor.SZ,
    coor.T,
    CASE WHEN coor.ARTSKODE = 6 THEN 'true' ELSE 'false' END AS BEREGNET,
    coor.X,
    coor.Y, 
    coor.Z,
    '7f2952b7-7729-4952-8f05-b4f372abe939',
    p.ID
FROM PUNKT p
INNER JOIN CONV_PUNKT conv ON p.ID = conv.ID
LEFT JOIN 
(
    SELECT cf.REFNR, 'TS:' || cf.JNR_BSIDE AS SRID, cf.HBERDATO AS T, NULL AS X, NULL AS Y, cf.H AS Z, NULL AS SX, NULL AS SY, cf.H_MF AS SZ, cf.IN_DATE AS IN_DATE, ct.IN_DATE AS OUT_DATE, cf.ARTSKODE FROM ts_dvr90@refgeo cf LEFT JOIN ts_dvr90@refgeo ct ON cf.REFNR = ct.REFNR AND (cf.VERSNR+1) = ct.VERSNR UNION ALL
    SELECT cf.REFNR, 'TS:' || cf.JNR_BSIDE AS SRID, cf.CBERDATO AS T, cf.E AS X, cf.N AS Y, cf.H AS Z, cf.KOOR_MF AS SX, cf.KOOR_MF AS SY, cf.KOTE_MF AS SZ, cf.IN_DATE AS IN_DATE, ct.IN_DATE AS OUT_DATE, cf.ARTSKODE FROM ts_euref89@refgeo cf LEFT JOIN ts_euref89@refgeo ct ON cf.REFNR = ct.REFNR AND (cf.VERSNR+1) = ct.VERSNR
)coor ON conv.REFNR = coor.REFNR
WHERE coor.SRID IS NOT NULL AND coor.IN_DATE < coor.OUT_DATE
;

COMMIT;