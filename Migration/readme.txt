Migration of data from REFGEO to FIRE

The SQL files contain the statements required to migrate data from REFGEO db til FIRE db. 
In order to execute the SQL succesfully the a database link named refgeo must exist (which allows the user to read from REFGEO db) 

SQL files are briefly described below. A more detailed description can be found in the files. Estimated runtime is 45 min.

The files should be executed sequentially in the order of appearance below.

ClearDB.sql                 Resets the database, meaning all tables will be dropped

DDL.sql                     Builds the database and populates OBSERVATIONTYPE. The file is authored by SDFE and located in the root of the repo.
insertFIRERows.sql          Populates the database with default sager and sagsevents. The file is authored by SDFE and located in the root of the repo.

MakeSRIDType.sql            Populates SRIDTYPE and SRIDNAMESPACE tables with valid/allowed SRIDs and namespaces
MakePunktInfoType.sql       Populates PUNKTINFOTYPE and PUNKTINFOTYPENAMESPACE tables with valid/allowed types and namespace
MakeIds.sql                 Populates CONV_PUNKT table which is a lookup table containing the REFGEO ID (REFNR) and the corresponding FIRE ID. The table will only be used for migration purposes and can be dropped when all migration sqls have been executed succesfully.
MakePunkt.sql               Populates PUNKT table. Only "authoritative" data will be migrated. See file for definition of "authoritative".
MakeGeometriObjekt.sql      Populates GEOMETRIOBJEKT table. 
MakeKoordinat.sql           Populates KOORDINAT table. 
MakePunktInfoAFM.sql        Populates PUNKTINFO table with namespace AFM info.
MakePunktInfoATTR.sql       Populates PUNKTINFO table with namespace ATTR info.
MakePunktInfoIDENT.sql      Populates PUNKTINFO table with namespace IDENT info.
MakePunktInfoNET.sql        Populates PUNKTINFO table with namespace NET info.
MakePunktInfoREGION.sql     Populates PUNKTINFO table with namespace REGION info.
MakePunktInfoSKITSE.sql     Populates PUNKTINFO table with namespace SKITSE info.
MakeObservation.sql         Populates OBSERVATION table. 
MakeBeregning.sql           Populates BEREGNING and the two cross tables BEREGNING_KOORDINAT and BEREGNING_OBSERVATION.

