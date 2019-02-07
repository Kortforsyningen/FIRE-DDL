﻿/* -------------------------------------------------------------------------- */
/* Make OBSERVATION data. ALl observations are migrated. Furthermore a sagsevent
/* is created for every observation insert timestamp in order to group observations.
/* For each sagsevent sagseventinfo will be created as well if possible. 
/* File: MakeObservation.sql   
/* -------------------------------------------------------------------------- */

-- Make lookup table OBSGROUPS1 containing every unique observation group based on the first x characters
-- of the JSNR (x = length - 1) and a new unique ID
-- Will be used to populate column OBSERVATION.GRUPPE for observaton types geometrisk_koteforskel, geometrisk_koteforskel, trigonometrisk_koteforskel
CREATE TABLE OBSGROUPS1 (
    GROUPID INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1 ORDER NOCACHE) PRIMARY KEY,
    JSNR NUMBER NOT NULL
);

INSERT INTO OBSGROUPS1 (JSNR)
SELECT DISTINCT o.JSNR FROM (
    SELECT DISTINCT SUBSTR(JSNR, 1, LENGTH(JSNR)-1) AS JSNR FROM NI_NIV@refgeo UNION ALL 
    SELECT DISTINCT SUBSTR(JSNR, 1, LENGTH(JSNR)-1) AS JSNR FROM NI_PRS@refgeo UNION ALL 
    SELECT DISTINCT SUBSTR(JSNR, 1, LENGTH(JSNR)-1) AS JSNR FROM NI_MTZ@refgeo 
) o
WHERE o.JSNR IS NOT NULL
;

-- Make lookup table OBSGROUPS2 containing every unique O_REFNR and a new unique ID
-- Will be used to populate column OBSERVATION.GRUPPE for observaton types zenitvinkel, skråafstand, vektor, retning, horisontalafstand
CREATE TABLE OBSGROUPS2 (
    GROUPID INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1 ORDER NOCACHE) PRIMARY KEY,
    O_REFNR NUMBER NOT NULL
);

INSERT INTO OBSGROUPS2 (O_REFNR)
SELECT DISTINCT o.O_REFNR FROM (
    SELECT DISTINCT O_REFNR FROM NI_ZDS_O@refgeo UNION ALL 
    SELECT DISTINCT O_REFNR FROM GG_DST_O@refgeo UNION ALL 
    SELECT DISTINCT O_REFNR FROM GG_VT3_O@refgeo UNION ALL 
    SELECT DISTINCT O_REFNR FROM RG_DIR_O@refgeo UNION ALL 
    SELECT DISTINCT O_REFNR FROM RG_DST_O@refgeo
) o
WHERE o.O_REFNR IS NOT NULL
;

-- Make lookup table OBSSAGSEVENTID containing every unique insert time for all 
-- observations and a new unique ID. Will be used to create sagsevents and to 
-- populate column OBSERVATION.SAGSEVENTID for all observation types   
CREATE TABLE OBSSAGSEVENTID (
    IN_DATE TIMESTAMP(6) WITH TIME ZONE NOT NULL,
    UUID VARCHAR2(36) NOT NULL
);
INSERT INTO OBSSAGSEVENTID (IN_DATE, UUID)
SELECT 
    s.IN_DATE, 
    REGEXP_REPLACE(SYS_GUID(), '(.{8})(.{4})(.{4})(.{4})(.{12})', '\1-\2-\3-\4-\5')
FROM (
    SELECT DISTINCT ss.IN_DATE FROM (
        SELECT IN_DATE FROM NI_NIV@refgeo UNION ALL
        SELECT IN_DATE FROM NI_PRS@refgeo UNION ALL
        SELECT IN_DATE FROM NI_MTZ@refgeo UNION ALL
        SELECT IN_DATE FROM NI_ZDS@refgeo UNION ALL
        SELECT IN_DATE FROM GG_DST@refgeo UNION ALL
        SELECT IN_DATE FROM GG_VT3@refgeo UNION ALL
        SELECT IN_DATE FROM RG_DIR@refgeo UNION ALL
        SELECT IN_DATE FROM RG_DST@refgeo
    ) ss
) s 
;

-- Create sagsevents
INSERT INTO SAGSEVENT (ID, REGISTRERINGFRA, EVENTTYPEID, SAGID)
SELECT UUID, SYSDATE, (SELECT EVENTTYPEID FROM EVENTTYPE WHERE EVENT = 'observation_indsat'), '4f8f29c8-c38f-4c69-ae28-c7737178de1f'
FROM OBSSAGSEVENTID;  



-- Insert observations
-- We will insert data in OBSERVATION and in a working table TMP_OBS_JSNR.
-- TMP_OBS_JSNR will be used to hold the JSNR (observationsjournalnummer) from 
-- REFGEO as this information is not a part of the FIRE datamodel. But the info
-- is required to establish a relation between calculations and observation stored
-- in table BEREGNING_OBSERVATION
CREATE TABLE TMP_OBS_JSNR (
  OBJECTID INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1 ORDER NOCACHE) PRIMARY KEY,
  SIGTEPUNKTID VARCHAR2(36),
  OPSTILLINGSPUNKTID VARCHAR2(36),
  JSNR NUMBER
);
-- insert one row in order to match the OBSERVATION table (first row is NULL-observation created by te DLL)
INSERT INTO TMP_OBS_JSNR (SIGTEPUNKTID) VALUES (NULL);

-- geometrisk_koteforskel 1
INSERT ALL
INTO TMP_OBS_JSNR (SIGTEPUNKTID, OPSTILLINGSPUNKTID, JSNR) VALUES (SIGTEPUNKTID, OPSTILLINGSPUNKTID, JSNR)
INTO OBSERVATION (
  REGISTRERINGFRA, REGISTRERINGTIL, OBSERVATIONSTIDSPUNKT,
  SIGTEPUNKTID, OBSERVATIONSTYPEID, ANTAL, GRUPPE, OPSTILLINGSPUNKTID,
  VALUE1, VALUE2, VALUE3, VALUE4, VALUE5, VALUE6, VALUE7, VALUE8,
  VALUE9, VALUE10, VALUE11, VALUE12, VALUE13, VALUE14, VALUE15, SAGSEVENTFRAID
) 
VALUES (
  REGISTRERINGFRA, REGISTRERINGTIL, OBSERVATIONSTIDSPUNKT,
  SIGTEPUNKTID, OBSERVATIONSTYPEID, ANTAL, GRUPPE, OPSTILLINGSPUNKTID,
  VALUE1, VALUE2, VALUE3, VALUE4, VALUE5, VALUE6, VALUE7, VALUE8,
  VALUE9, VALUE10, VALUE11, VALUE12, VALUE13, VALUE14, VALUE15, SAGSEVENTFRAID
)
SELECT 
  opst.JSNR AS JSNR,
  opst.IN_DATE AS REGISTRERINGFRA,
  NULL AS REGISTRERINGTIL,
  NVL(obs.OBS_DATE, TO_DATE(opst.YEAR, 'YYYY')) AS OBSERVATIONSTIDSPUNKT,
  obsconv.ID AS SIGTEPUNKTID,
  (SELECT OBSERVATIONSTYPEID FROM OBSERVATIONTYPE WHERE OBSERVATIONSTYPE = 'geometrisk_koteforskel' AND ROWNUM <= 1) AS OBSERVATIONSTYPEID,
  opst.SETS AS ANTAL,
  grp.GROUPID AS GRUPPE,
  opstconv.ID AS OPSTILLINGSPUNKTID,
  obs.OBS AS VALUE1,
  obs.S_LENGTH AS VALUE2,
  obs.SET_UP AS VALUE3,
  obs.ETA AS VALUE4,
  opst.MD * obs.S_LENGTH AS VALUE5,
  opst.MC AS VALUE6,
  0 AS VALUE7,
  NULL AS VALUE8,
  NULL AS VALUE9,
  NULL AS VALUE10,
  NULL AS VALUE11,
  NULL AS VALUE12,
  NULL AS VALUE13,
  NULL AS VALUE14,
  NULL AS VALUE15,
  sevent.UUID AS SAGSEVENTFRAID
FROM PUNKT opstp
INNER JOIN CONV_PUNKT opstconv ON opstp.ID = opstconv.ID
INNER JOIN NI_NIV@refgeo opst ON opstconv.REFNR = opst.REFNR
INNER JOIN NI_NIV_O@refgeo obs ON opst.O_REFNR = obs.O_REFNR
INNER JOIN CONV_PUNKT obsconv ON obs.REFNR = obsconv.REFNR
INNER JOIN PUNKT obsp ON obsp.ID = obsconv.ID
LEFT JOIN OBSSAGSEVENTID sevent ON sevent.IN_DATE = opst.IN_DATE
LEFT JOIN OBSGROUPS1 grp ON SUBSTR(opst.JSNR, 1, LENGTH(opst.JSNR)-1) = grp.JSNR
;    


-- geometrisk_koteforskel 2, similar to the above exception for value7
INSERT ALL
INTO TMP_OBS_JSNR (SIGTEPUNKTID, OPSTILLINGSPUNKTID, JSNR) VALUES (SIGTEPUNKTID, OPSTILLINGSPUNKTID, JSNR)
INTO OBSERVATION (
  REGISTRERINGFRA, REGISTRERINGTIL, OBSERVATIONSTIDSPUNKT,
  SIGTEPUNKTID, OBSERVATIONSTYPEID, ANTAL, GRUPPE, OPSTILLINGSPUNKTID,
  VALUE1, VALUE2, VALUE3, VALUE4, VALUE5, VALUE6, VALUE7, VALUE8,
  VALUE9, VALUE10, VALUE11, VALUE12, VALUE13, VALUE14, VALUE15, SAGSEVENTFRAID
) 
VALUES (
  REGISTRERINGFRA, REGISTRERINGTIL, OBSERVATIONSTIDSPUNKT,
  SIGTEPUNKTID, OBSERVATIONSTYPEID, ANTAL, GRUPPE, OPSTILLINGSPUNKTID,
  VALUE1, VALUE2, VALUE3, VALUE4, VALUE5, VALUE6, VALUE7, VALUE8,
  VALUE9, VALUE10, VALUE11, VALUE12, VALUE13, VALUE14, VALUE15, SAGSEVENTFRAID
)
SELECT 
  opst.JSNR AS JSNR,
  opst.IN_DATE AS REGISTRERINGFRA,
  NULL AS REGISTRERINGTIL,
  NVL(obs.OBS_DATE, TO_DATE(opst.YEAR, 'YYYY')) AS OBSERVATIONSTIDSPUNKT,
  obsconv.ID AS SIGTEPUNKTID,
  (SELECT OBSERVATIONSTYPEID FROM OBSERVATIONTYPE WHERE OBSERVATIONSTYPE = 'geometrisk_koteforskel' AND ROWNUM <= 1) AS OBSERVATIONSTYPEID,
  opst.SETS AS ANTAL,
  grp.GROUPID AS GRUPPE,
  opstconv.ID AS OPSTILLINGSPUNKTID,
  obs.OBS AS VALUE1,
  obs.S_LENGTH AS VALUE2,
  obs.SET_UP AS VALUE3,
  obs.ETA AS VALUE4,
  opst.MD * obs.S_LENGTH AS VALUE5,
  opst.MC AS VALUE6,
  CASE 
    WHEN opst.YEAR BETWEEN 1885 AND 1910 THEN 1
    WHEN opst.YEAR BETWEEN 1938 AND 1961 THEN 2
    WHEN opst.YEAR BETWEEN 1982 AND 1994 THEN 3
    ELSE 0
  END AS VALUE7,
  NULL AS VALUE8,
  NULL AS VALUE9,
  NULL AS VALUE10,
  NULL AS VALUE11,
  NULL AS VALUE12,
  NULL AS VALUE13,
  NULL AS VALUE14,
  NULL AS VALUE15,
  sevent.UUID AS SAGSEVENTFRAID
FROM PUNKT opstp
INNER JOIN CONV_PUNKT opstconv ON opstp.ID = opstconv.ID
INNER JOIN NI_PRS@refgeo opst ON opstconv.REFNR = opst.REFNR
INNER JOIN NI_PRS_O@refgeo obs ON opst.O_REFNR = obs.O_REFNR
INNER JOIN CONV_PUNKT obsconv ON obs.REFNR = obsconv.REFNR
INNER JOIN PUNKT obsp ON obsp.ID = obsconv.ID
LEFT JOIN OBSSAGSEVENTID sevent ON sevent.IN_DATE = opst.IN_DATE
LEFT JOIN OBSGROUPS1 grp ON SUBSTR(opst.JSNR, 1, LENGTH(opst.JSNR)-1) = grp.JSNR
;

-- trigonometrisk_koteforskel
INSERT ALL
INTO TMP_OBS_JSNR (SIGTEPUNKTID, OPSTILLINGSPUNKTID, JSNR) VALUES (SIGTEPUNKTID, OPSTILLINGSPUNKTID, JSNR)
INTO OBSERVATION (
  REGISTRERINGFRA, REGISTRERINGTIL, OBSERVATIONSTIDSPUNKT,
  SIGTEPUNKTID, OBSERVATIONSTYPEID, ANTAL, GRUPPE, OPSTILLINGSPUNKTID,
  VALUE1, VALUE2, VALUE3, VALUE4, VALUE5, VALUE6, VALUE7, VALUE8,
  VALUE9, VALUE10, VALUE11, VALUE12, VALUE13, VALUE14, VALUE15, SAGSEVENTFRAID
) 
VALUES (
  REGISTRERINGFRA, REGISTRERINGTIL, OBSERVATIONSTIDSPUNKT,
  SIGTEPUNKTID, OBSERVATIONSTYPEID, ANTAL, GRUPPE, OPSTILLINGSPUNKTID,
  VALUE1, VALUE2, VALUE3, VALUE4, VALUE5, VALUE6, VALUE7, VALUE8,
  VALUE9, VALUE10, VALUE11, VALUE12, VALUE13, VALUE14, VALUE15, SAGSEVENTFRAID
)
SELECT 
  opst.JSNR AS JSNR,
  opst.IN_DATE AS REGISTRERINGFRA,
  NULL AS REGISTRERINGTIL,
  NVL(obs.OBS_DATE, TO_DATE(opst.YEAR, 'YYYY')) AS OBSERVATIONSTIDSPUNKT,
  obsconv.ID AS SIGTEPUNKTID,
  (SELECT OBSERVATIONSTYPEID FROM OBSERVATIONTYPE WHERE OBSERVATIONSTYPE = 'trigonometrisk_koteforskel' AND ROWNUM <= 1) AS OBSERVATIONSTYPEID,
  opst.SETS AS ANTAL,
  grp.GROUPID AS GRUPPE,
  opstconv.ID AS OPSTILLINGSPUNKTID,
  obs.OBS AS VALUE1,
  obs.S_LENGTH AS VALUE2,
  obs.SET_UP AS VALUE3,
  opst.MD * obs.S_LENGTH AS VALUE4,
  opst.MC AS VALUE5,
  NULL AS VALUE6,
  NULL AS VALUE7,
  NULL AS VALUE8,
  NULL AS VALUE9,
  NULL AS VALUE10,
  NULL AS VALUE11,
  NULL AS VALUE12,
  NULL AS VALUE13,
  NULL AS VALUE14,
  NULL AS VALUE15,
  sevent.UUID AS SAGSEVENTFRAID
FROM PUNKT opstp
INNER JOIN CONV_PUNKT opstconv ON opstp.ID = opstconv.ID
INNER JOIN NI_MTZ@refgeo opst ON opstconv.REFNR = opst.REFNR
INNER JOIN NI_MTZ_O@refgeo obs ON opst.O_REFNR = obs.O_REFNR
INNER JOIN CONV_PUNKT obsconv ON obs.REFNR = obsconv.REFNR
INNER JOIN PUNKT obsp ON obsp.ID = obsconv.ID
LEFT JOIN OBSSAGSEVENTID sevent ON sevent.IN_DATE = opst.IN_DATE
LEFT JOIN OBSGROUPS1 grp ON SUBSTR(opst.JSNR, 1, LENGTH(opst.JSNR)-1) = grp.JSNR 
;

-- zenitvinkel
INSERT ALL
INTO TMP_OBS_JSNR (SIGTEPUNKTID, OPSTILLINGSPUNKTID, JSNR) VALUES (SIGTEPUNKTID, OPSTILLINGSPUNKTID, JSNR)
INTO OBSERVATION (
  REGISTRERINGFRA, REGISTRERINGTIL, OBSERVATIONSTIDSPUNKT,
  SIGTEPUNKTID, OBSERVATIONSTYPEID, ANTAL, GRUPPE, OPSTILLINGSPUNKTID,
  VALUE1, VALUE2, VALUE3, VALUE4, VALUE5, VALUE6, VALUE7, VALUE8,
  VALUE9, VALUE10, VALUE11, VALUE12, VALUE13, VALUE14, VALUE15, SAGSEVENTFRAID
) 
VALUES (
  REGISTRERINGFRA, REGISTRERINGTIL, OBSERVATIONSTIDSPUNKT,
  SIGTEPUNKTID, OBSERVATIONSTYPEID, ANTAL, GRUPPE, OPSTILLINGSPUNKTID,
  VALUE1, VALUE2, VALUE3, VALUE4, VALUE5, VALUE6, VALUE7, VALUE8,
  VALUE9, VALUE10, VALUE11, VALUE12, VALUE13, VALUE14, VALUE15, SAGSEVENTFRAID
)
SELECT 
  opst.JSNR AS JSNR,
  opst.IN_DATE AS REGISTRERINGFRA,
  NULL AS REGISTRERINGTIL,
  TO_DATE(CASE WHEN opst.YEAR IS NULL OR opst.YEAR < 1700 THEN 1700 ELSE opst.YEAR END, 'YYYY') AS OBSERVATIONSTIDSPUNKT,
  obsconv.ID AS SIGTEPUNKTID,
  (SELECT OBSERVATIONSTYPEID FROM OBSERVATIONTYPE WHERE OBSERVATIONSTYPE = 'zenitvinkel' AND ROWNUM <= 1) AS OBSERVATIONSTYPEID,
  opst.SETS AS ANTAL,
  grp.GROUPID AS GRUPPE,
  opstconv.ID AS OPSTILLINGSPUNKTID,
  obs.OBS AS VALUE1,
  opst.IH AS VALUE2,
  obs.S_LENGTH AS VALUE3,
  opst.MD AS VALUE4,
  opst.MC AS VALUE5,
  NULL AS VALUE6,
  NULL AS VALUE7,
  NULL AS VALUE8,
  NULL AS VALUE9,
  NULL AS VALUE10,
  NULL AS VALUE11,
  NULL AS VALUE12,
  NULL AS VALUE13,
  NULL AS VALUE14,
  NULL AS VALUE15,
  sevent.UUID AS SAGSEVENTFRAID
FROM PUNKT opstp
INNER JOIN CONV_PUNKT opstconv ON opstp.ID = opstconv.ID
INNER JOIN NI_ZDS@refgeo opst ON opstconv.REFNR = opst.REFNR
INNER JOIN NI_ZDS_O@refgeo obs ON opst.O_REFNR = obs.O_REFNR
INNER JOIN CONV_PUNKT obsconv ON obs.REFNR = obsconv.REFNR
INNER JOIN PUNKT obsp ON obsp.ID = obsconv.ID
LEFT JOIN OBSSAGSEVENTID sevent ON sevent.IN_DATE = opst.IN_DATE
LEFT JOIN OBSGROUPS2 grp ON obs.O_REFNR = grp.O_REFNR
;    

-- skråafstand
INSERT ALL
INTO TMP_OBS_JSNR (SIGTEPUNKTID, OPSTILLINGSPUNKTID, JSNR) VALUES (SIGTEPUNKTID, OPSTILLINGSPUNKTID, JSNR)
INTO OBSERVATION (
  REGISTRERINGFRA, REGISTRERINGTIL, OBSERVATIONSTIDSPUNKT,
  SIGTEPUNKTID, OBSERVATIONSTYPEID, ANTAL, GRUPPE, OPSTILLINGSPUNKTID,
  VALUE1, VALUE2, VALUE3, VALUE4, VALUE5, VALUE6, VALUE7, VALUE8,
  VALUE9, VALUE10, VALUE11, VALUE12, VALUE13, VALUE14, VALUE15, SAGSEVENTFRAID
) 
VALUES (
  REGISTRERINGFRA, REGISTRERINGTIL, OBSERVATIONSTIDSPUNKT,
  SIGTEPUNKTID, OBSERVATIONSTYPEID, ANTAL, GRUPPE, OPSTILLINGSPUNKTID,
  VALUE1, VALUE2, VALUE3, VALUE4, VALUE5, VALUE6, VALUE7, VALUE8,
  VALUE9, VALUE10, VALUE11, VALUE12, VALUE13, VALUE14, VALUE15, SAGSEVENTFRAID
)
SELECT 
  opst.JSNR AS JSNR,
  opst.IN_DATE AS REGISTRERINGFRA,
  NULL AS REGISTRERINGTIL,
  TO_DATE(CASE WHEN opst.YEAR IS NULL OR opst.YEAR < 1700 THEN 1700 ELSE opst.YEAR END, 'YYYY') AS OBSERVATIONSTIDSPUNKT,
  obsconv.ID AS SIGTEPUNKTID,
  (SELECT OBSERVATIONSTYPEID FROM OBSERVATIONTYPE WHERE OBSERVATIONSTYPE = 'skråafstand' AND ROWNUM <= 1) AS OBSERVATIONSTYPEID,
  opst.SETS AS ANTAL,
  grp.GROUPID AS GRUPPE,
  opstconv.ID AS OPSTILLINGSPUNKTID,
  obs.OBS AS VALUE1,
  opst.MD AS VALUE2,
  opst.MC AS VALUE3,
  NULL AS VALUE4,
  NULL AS VALUE5,
  NULL AS VALUE6,
  NULL AS VALUE7,
  NULL AS VALUE8,
  NULL AS VALUE9,
  NULL AS VALUE10,
  NULL AS VALUE11,
  NULL AS VALUE12,
  NULL AS VALUE13,
  NULL AS VALUE14,
  NULL AS VALUE15,
  sevent.UUID AS SAGSEVENTFRAID
FROM PUNKT opstp
INNER JOIN CONV_PUNKT opstconv ON opstp.ID = opstconv.ID
INNER JOIN GG_DST@refgeo opst ON opstconv.REFNR = opst.REFNR
INNER JOIN GG_DST_O@refgeo obs ON opst.O_REFNR = obs.O_REFNR
INNER JOIN CONV_PUNKT obsconv ON obs.REFNR = obsconv.REFNR
INNER JOIN PUNKT obsp ON obsp.ID = obsconv.ID
LEFT JOIN OBSSAGSEVENTID sevent ON sevent.IN_DATE = opst.IN_DATE
LEFT JOIN OBSGROUPS2 grp ON opst.O_REFNR = grp.O_REFNR
;    


-- vektor
INSERT ALL
INTO TMP_OBS_JSNR (SIGTEPUNKTID, OPSTILLINGSPUNKTID, JSNR) VALUES (SIGTEPUNKTID, OPSTILLINGSPUNKTID, JSNR)
INTO OBSERVATION (
  REGISTRERINGFRA, REGISTRERINGTIL, OBSERVATIONSTIDSPUNKT,
  SIGTEPUNKTID, OBSERVATIONSTYPEID, ANTAL, GRUPPE, OPSTILLINGSPUNKTID,
  VALUE1, VALUE2, VALUE3, VALUE4, VALUE5, VALUE6, VALUE7, VALUE8,
  VALUE9, VALUE10, VALUE11, VALUE12, VALUE13, VALUE14, VALUE15, SAGSEVENTFRAID
) 
VALUES (
  REGISTRERINGFRA, REGISTRERINGTIL, OBSERVATIONSTIDSPUNKT,
  SIGTEPUNKTID, OBSERVATIONSTYPEID, ANTAL, GRUPPE, OPSTILLINGSPUNKTID,
  VALUE1, VALUE2, VALUE3, VALUE4, VALUE5, VALUE6, VALUE7, VALUE8,
  VALUE9, VALUE10, VALUE11, VALUE12, VALUE13, VALUE14, VALUE15, SAGSEVENTFRAID
)
SELECT 
  opst.JSNR AS JSNR,
  opst.IN_DATE AS REGISTRERINGFRA,
  NULL AS REGISTRERINGTIL,
  TO_DATE(CASE WHEN opst.YEAR IS NULL OR opst.YEAR < 1700 THEN 1700 ELSE opst.YEAR END, 'YYYY') AS OBSERVATIONSTIDSPUNKT,
  obsconv.ID AS SIGTEPUNKTID,
  (SELECT OBSERVATIONSTYPEID FROM OBSERVATIONTYPE WHERE OBSERVATIONSTYPE = 'vektor' AND ROWNUM <= 1) AS OBSERVATIONSTYPEID,
  opst.SETS AS ANTAL,
  grp.GROUPID AS GRUPPE,
  opstconv.ID AS OPSTILLINGSPUNKTID,
  obs.OBSN AS VALUE1,
  obs.OBSE AS VALUE2,
  obs.OBSH AS VALUE3,
  opst.MCNE AS VALUE4,
  opst.MDNEH AS VALUE5,
  om.QXX AS VALUE6,
  om.QYY AS VALUE7,
  om.QZZ AS VALUE8,
  om.QXY AS VALUE9,
  om.QXZ AS VALUE10,
  om.QYZ AS VALUE11,
  NULL AS VALUE12,
  NULL AS VALUE13,
  NULL AS VALUE14,
  NULL AS VALUE15,
  sevent.UUID AS SAGSEVENTFRAID
FROM PUNKT opstp
INNER JOIN CONV_PUNKT opstconv ON opstp.ID = opstconv.ID
INNER JOIN GG_VT3@refgeo opst ON opstconv.REFNR = opst.REFNR
INNER JOIN GG_VT3_O@refgeo obs ON opst.O_REFNR = obs.O_REFNR
INNER JOIN CONV_PUNKT obsconv ON obs.REFNR = obsconv.REFNR
INNER JOIN PUNKT obsp ON obsp.ID = obsconv.ID
INNER JOIN GG_VT3_M@refgeo om ON opst.O_REFNR = om.O_REFNR
LEFT JOIN OBSSAGSEVENTID sevent ON sevent.IN_DATE = opst.IN_DATE
LEFT JOIN OBSGROUPS2 grp ON opst.O_REFNR = grp.O_REFNR
;    

-- retning
INSERT ALL
INTO TMP_OBS_JSNR (SIGTEPUNKTID, OPSTILLINGSPUNKTID, JSNR) VALUES (SIGTEPUNKTID, OPSTILLINGSPUNKTID, JSNR)
INTO OBSERVATION (
  REGISTRERINGFRA, REGISTRERINGTIL, OBSERVATIONSTIDSPUNKT,
  SIGTEPUNKTID, OBSERVATIONSTYPEID, ANTAL, GRUPPE, OPSTILLINGSPUNKTID,
  VALUE1, VALUE2, VALUE3, VALUE4, VALUE5, VALUE6, VALUE7, VALUE8,
  VALUE9, VALUE10, VALUE11, VALUE12, VALUE13, VALUE14, VALUE15, SAGSEVENTFRAID
) 
VALUES (
  REGISTRERINGFRA, REGISTRERINGTIL, OBSERVATIONSTIDSPUNKT,
  SIGTEPUNKTID, OBSERVATIONSTYPEID, ANTAL, GRUPPE, OPSTILLINGSPUNKTID,
  VALUE1, VALUE2, VALUE3, VALUE4, VALUE5, VALUE6, VALUE7, VALUE8,
  VALUE9, VALUE10, VALUE11, VALUE12, VALUE13, VALUE14, VALUE15, SAGSEVENTFRAID
)
SELECT 
  opst.JSNR AS JSNR,
  opst.IN_DATE AS REGISTRERINGFRA,
  NULL AS REGISTRERINGTIL,
  TO_DATE(CASE WHEN opst.YEAR IS NULL OR opst.YEAR < 1700 THEN 1700 ELSE opst.YEAR END, 'YYYY') AS OBSERVATIONSTIDSPUNKT,
  obsconv.ID AS SIGTEPUNKTID,
  (SELECT OBSERVATIONSTYPEID FROM OBSERVATIONTYPE WHERE OBSERVATIONSTYPE = 'retning' AND ROWNUM <= 1) AS OBSERVATIONSTYPEID,
  opst.SETS AS ANTAL,
  grp.GROUPID AS GRUPPE,
  opstconv.ID AS OPSTILLINGSPUNKTID,
  obs.OBS AS VALUE1,
  opst.MD AS VALUE2,
  opst.MC AS VALUE3,
  NULL AS VALUE4,
  NULL AS VALUE5,
  NULL AS VALUE6,
  NULL AS VALUE7,
  NULL AS VALUE8,
  NULL AS VALUE9,
  NULL AS VALUE10,
  NULL AS VALUE11,
  NULL AS VALUE12,
  NULL AS VALUE13,
  NULL AS VALUE14,
  NULL AS VALUE15,
  sevent.UUID AS SAGSEVENTFRAID
FROM PUNKT opstp
INNER JOIN CONV_PUNKT opstconv ON opstp.ID = opstconv.ID
LEFT JOIN GEOMETRIOBJEKT opstgeom ON opstp.ID = opstgeom.PUNKTID
INNER JOIN RG_DIR@refgeo opst ON opstconv.REFNR = opst.REFNR
INNER JOIN RG_DIR_O@refgeo obs ON opst.O_REFNR = obs.O_REFNR
INNER JOIN CONV_PUNKT obsconv ON obs.REFNR = obsconv.REFNR
INNER JOIN PUNKT obsp ON obsp.ID = obsconv.ID
LEFT JOIN OBSSAGSEVENTID sevent ON sevent.IN_DATE = opst.IN_DATE
LEFT JOIN OBSGROUPS2 grp ON opst.O_REFNR = grp.O_REFNR
;    

-- horisontalafstand
INSERT ALL
INTO TMP_OBS_JSNR (SIGTEPUNKTID, OPSTILLINGSPUNKTID, JSNR) VALUES (SIGTEPUNKTID, OPSTILLINGSPUNKTID, JSNR)
INTO OBSERVATION (
  REGISTRERINGFRA, REGISTRERINGTIL, OBSERVATIONSTIDSPUNKT,
  SIGTEPUNKTID, OBSERVATIONSTYPEID, ANTAL, GRUPPE, OPSTILLINGSPUNKTID,
  VALUE1, VALUE2, VALUE3, VALUE4, VALUE5, VALUE6, VALUE7, VALUE8,
  VALUE9, VALUE10, VALUE11, VALUE12, VALUE13, VALUE14, VALUE15, SAGSEVENTFRAID
) 
VALUES (
  REGISTRERINGFRA, REGISTRERINGTIL, OBSERVATIONSTIDSPUNKT,
  SIGTEPUNKTID, OBSERVATIONSTYPEID, ANTAL, GRUPPE, OPSTILLINGSPUNKTID,
  VALUE1, VALUE2, VALUE3, VALUE4, VALUE5, VALUE6, VALUE7, VALUE8,
  VALUE9, VALUE10, VALUE11, VALUE12, VALUE13, VALUE14, VALUE15, SAGSEVENTFRAID
)
SELECT 
  opst.JSNR AS JSNR,
  opst.IN_DATE AS REGISTRERINGFRA,
  NULL AS REGISTRERINGTIL,
  TO_DATE(CASE WHEN opst.YEAR IS NULL OR opst.YEAR < 1700 THEN 1700 ELSE opst.YEAR END, 'YYYY') AS OBSERVATIONSTIDSPUNKT,
  obsconv.ID AS SIGTEPUNKTID,
  (SELECT OBSERVATIONSTYPEID FROM OBSERVATIONTYPE WHERE OBSERVATIONSTYPE = 'horisontalafstand' AND ROWNUM <= 1) AS OBSERVATIONSTYPEID,
  opst.SETS AS ANTAL,
  grp.GROUPID AS GRUPPE,
  opstconv.ID AS OPSTILLINGSPUNKTID,
  obs.OBS AS VALUE1,
  opst.MD AS VALUE2,
  opst.MC AS VALUE3,
  NULL AS VALUE4,
  NULL AS VALUE5,
  NULL AS VALUE6,
  NULL AS VALUE7,
  NULL AS VALUE8,
  NULL AS VALUE9,
  NULL AS VALUE10,
  NULL AS VALUE11,
  NULL AS VALUE12,
  NULL AS VALUE13,
  NULL AS VALUE14,
  NULL AS VALUE15,
  sevent.UUID AS SAGSEVENTFRAID
FROM PUNKT opstp
INNER JOIN CONV_PUNKT opstconv ON opstp.ID = opstconv.ID
INNER JOIN RG_DST@refgeo opst ON opstconv.REFNR = opst.REFNR
INNER JOIN RG_DST_O@refgeo obs ON opst.O_REFNR = obs.O_REFNR
INNER JOIN CONV_PUNKT obsconv ON obs.REFNR = obsconv.REFNR
INNER JOIN PUNKT obsp ON obsp.ID = obsconv.ID
LEFT JOIN OBSSAGSEVENTID sevent ON sevent.IN_DATE = opst.IN_DATE
LEFT JOIN OBSGROUPS2 grp ON opst.O_REFNR = grp.O_REFNR
;    

CREATE INDEX obsjsnr ON TMP_OBS_JSNR(JSNR);

-- Make sagseventinfo based on info from REFGEO.JSBR_OBS
INSERT INTO SAGSEVENTINFO (REGISTRERINGFRA, BESKRIVELSE, SAGSEVENTID)
SELECT se.REGISTRERINGFRA AS REGISTRERINGFRA, 'Observationens indsættelsestid: ' || TO_CHAR(jsnr.IN_DATE, 'YYYY-MM-DD HH24:MI') || ', sted: ' || jinfo.STED || ', ' || jinfo.TEKST AS BESKRIVELSE, se.ID AS SAGSEVENTID 
FROM 
( 
    SELECT obs.IN_DATE, MIN(obs.JSNR) AS JSNR_FRA, MAX(obs.JSNR)AS JSNR_TIL
    FROM 
    (
        SELECT IN_DATE, JSNR FROM NI_NIV@refgeo UNION ALL
        SELECT IN_DATE, JSNR FROM NI_PRS@refgeo UNION ALL
        SELECT IN_DATE, JSNR FROM NI_MTZ@refgeo UNION ALL
        SELECT IN_DATE, JSNR FROM NI_ZDS@refgeo UNION ALL
        SELECT IN_DATE, JSNR FROM GG_DST@refgeo UNION ALL
        SELECT IN_DATE, JSNR FROM GG_VT3@refgeo UNION ALL
        SELECT IN_DATE, JSNR FROM RG_DIR@refgeo UNION ALL
        SELECT IN_DATE, JSNR FROM RG_DST@refgeo
    ) obs
    GROUP BY obs.IN_DATE
) jsnr
INNER JOIN JSNR_OBS@refgeo jinfo ON jinfo.JSNR_FRA = jsnr.JSNR_FRA AND jinfo.JSNR_TIL = jsnr.JSNR_TIL
INNER JOIN OBSSAGSEVENTID convid ON jsnr.IN_DATE = convid.IN_DATE
INNER JOIN SAGSEVENT se ON se.ID = convid.UUID
ORDER BY jsnr.IN_DATE DESC
;

-- Clean up
DROP TABLE OBSGROUPS1 PURGE;
DROP TABLE OBSGROUPS2 PURGE;
DROP TABLE OBSSAGSEVENTID PURGE;

COMMIT;
