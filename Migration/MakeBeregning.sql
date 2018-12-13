/* -------------------------------------------------------------------------- */
/* Make BEREGNING data.  
/* File: MakeBeregning.sql   
/* -------------------------------------------------------------------------- */

-- Populate BEREGNING based on the previously established sagseventid for every
-- calculation time. Notice that we will set the value of REGISTRERINGFRA to 
-- calculation time and not sysdate.
INSERT INTO BEREGNING (REGISTRERINGFRA, SAGSEVENTID)
SELECT BERDATO, SAID
FROM KOOR_BERE_SAGSEVENTID
;

CREATE INDEX regfra ON BEREGNING(REGISTRERINGFRA);

-- Populate BEREGNING_KOORDINAT. This table contains the relation between a 
-- calculation and the coordinates affected by the calculation. It is the 
-- calculation time (BEREGNING.REGISTRERINGFRA and KOORDINAT.T) that relates the two
INSERT INTO BEREGNING_KOORDINAT (BEREGNINGOBJECTID, KOORDINATOBJECTID)
SELECT b.OBJECTID, k.OBJECTID
FROM BEREGNING b
INNER JOIN KOORDINAT k ON b.REGISTRERINGFRA = k.T; 

-- Populate BEREGNING_OBSERVATION. This table contains the relation between a
-- calculation and the observations that were input to the calculation. By default
-- this relation does not exist in REFGEO, only in the reports created as part
-- of the calculation process. SDFE (Kristian) has extracted relevant data from 
-- the reports and stored the info in table FIRE_OBSJOURNALNUMRE. 
INSERT INTO BEREGNING_OBSERVATION (BEREGNINGOBJECTID, OBSERVATIONOBJECTID)
SELECT b.OBJECTID, fobs.OBJECTID
FROM BEREGNING b
INNER JOIN (
    -- There are duplicates in the FIRE_OBSJOURNALNUMRE table, so let's remove them
    SELECT BEREGNINGSDATO, JOURNALNUMMER FROM FIRE_OBSJOURNALNUMRE GROUP BY BEREGNINGSDATO, JOURNALNUMMER
) ojnr ON b.REGISTRERINGFRA = ojnr.BEREGNINGSDATO
INNER JOIN TMP_OBS_JSNR fobs ON ojnr.JOURNALNUMMER = fobs.JSNR
;


-- Clean up
DROP TABLE KOOR_BERE_SAGSEVENTID PURGE;
DROP TABLE TMP_OBS_JSNR PURGE;

COMMIT;