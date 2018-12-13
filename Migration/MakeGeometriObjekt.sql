/* -------------------------------------------------------------------------- */
/* Make GEOMETRIOBJEKT data. 
/* File: MakeGeometriObjekt.sql   
/* -------------------------------------------------------------------------- */

DELETE FROM GEOMETRIOBJEKT;

INSERT INTO GEOMETRIOBJEKT (
    REGISTRERINGFRA, 
    REGISTRERINGTIL,
    GEOMETRI, 
    SAGSEVENTID,
    PUNKTID
)
SELECT 
    coor.C_DATO,
    NULL,
    coor.GEO_LOCATION,
    'e964cca6-7b16-414a-9538-8639eacaac3d', -- SELECT ID FROM SAGSEVENT WHERE EVENT = 'punkt_oprettet'; brug den yngste
    conv.ID
FROM HVD_REF@refgeo href
INNER JOIN LOC_CRD@refgeo coor ON href.REFNR = coor.REFNR
INNER JOIN CONV_PUNKT conv ON href.REFNR = conv.REFNR
INNER JOIN PUNKT p ON p.ID = conv.ID
WHERE coor.GEO_LOCATION IS NOT NULL AND coor.C_DATO IS NOT NULL 
;    

COMMIT;
