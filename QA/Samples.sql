/* -------------------------------------------------------------------------- */
/* Sample SQL to get information about a punkt, observation and beregning. 
/* SQL assumes that you are using the REFNR as identifier when obtaining info
/* about punkt (including geometri, punktinfo and koordinat)
/* For observation the SQL assumes you are using the REFNR of the opstillingspunkt
/* For beregning the SQL assumes you are using the beregning sagseventid.   
/* -------------------------------------------------------------------------- */

-- Find FIRE ID for et punkt med kendt REFNR
SELECT * FROM CONV_PUNKT WHERE REFNR = 633;

-- Punkt
SELECT * FROM PUNKT WHERE ID = (SELECT ID FROM CONV_PUNKT WHERE REFNR = 633) ORDER BY REGISTRERINGFRA;

-- Geometriobjekt
SELECT * FROM GEOMETRIOBJEKT WHERE PUNKTID = (SELECT ID FROM CONV_PUNKT WHERE REFNR = 633) ORDER BY REGISTRERINGFRA;

-- Punktinfo
SELECT * FROM PUNKTINFO WHERE PUNKTID = (SELECT ID FROM CONV_PUNKT WHERE REFNR = 633) ORDER BY INFOTYPE, REGISTRERINGFRA;

-- Koordinat
SELECT * FROM KOORDINAT WHERE PUNKTID = (SELECT ID FROM CONV_PUNKT WHERE REFNR = 633) ORDER BY SRID, REGISTRERINGFRA;

-- Observation
SELECT * FROM OBSERVATION WHERE OPSTILLINGSPUNKTID = (SELECT ID FROM CONV_PUNKT WHERE REFNR = 633) ORDER BY OBSERVATIONSTYPE, REGISTRERINGFRA;

-- Koordinater i beregning
SELECT * 
FROM BEREGNING b
INNER JOIN BEREGNING_KOORDINAT bk ON b.OBJECTID = bk.BEREGNINGOBJECTID
INNER JOIN KOORDINAT k ON k.OBJECTID = bk.KOORDINATOBJECTID 
WHERE b.SAGSEVENTID = '7C581B4A-6299-7F16-E053-1A041EAC3A76'
;
-- Punkter i beregning
SELECT * 
FROM BEREGNING b
INNER JOIN BEREGNING_OBSERVATION bo ON b.OBJECTID = bo.BEREGNINGOBJECTID
INNER JOIN OBSERVATION o ON o.OBJECTID = bo.OBSERVATIONOBJECTID 
WHERE b.SAGSEVENTID = '7C581B4A-6299-7F16-E053-1A041EAC3A76'
;

