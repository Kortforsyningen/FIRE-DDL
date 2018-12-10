/* -------------------------------------------------------------------------- */
/* Make ID conversion tables 
/* File: MakeIds.sql
/* -------------------------------------------------------------------------- */

-- PUNKT.ID
CREATE TABLE CONV_PUNKT (
    REFNR INTEGER NOT NULL,
    ID VARCHAR2(100) NOT NULL,
    CONSTRAINT CONV_PUNKT_PK PRIMARY KEY (REFNR, ID)
);
INSERT INTO CONV_PUNKT (REFNR, ID)
SELECT 
    REFNR,
    REGEXP_REPLACE(SYS_GUID(), '(.{8})(.{4})(.{4})(.{4})(.{12})', '\1-\2-\3-\4-\5')
FROM HVD_REF@refgeo 
ORDER BY REFNR;

CREATE INDEX refnr ON CONV_PUNKT(REFNR);

COMMIT;