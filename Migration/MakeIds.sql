/* -------------------------------------------------------------------------- */
/* Make ID conversion tables
/* File: MakeIds.sql
/* -------------------------------------------------------------------------- */

CREATE OR REPLACE FUNCTION random_uuid RETURN varchar2 AS
language java
name 'java.util.UUID.randomUUID() return String';

-- PUNKT.ID
CREATE TABLE CONV_PUNKT (
    REFNR INTEGER NOT NULL,
    ID VARCHAR2(100) NOT NULL,
    CONSTRAINT CONV_PUNKT_PK PRIMARY KEY (REFNR, ID)
);
INSERT INTO CONV_PUNKT (REFNR, ID)
SELECT
    r.refnr refnr,
    random_uuid() id
FROM HVD_REF@refgeo r
ORDER BY r.refnr;

CREATE INDEX refnr ON CONV_PUNKT(REFNR);

DROP TABLE TEMP_UUIDS;

COMMIT;