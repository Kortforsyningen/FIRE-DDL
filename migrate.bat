@echo off
REM Setup
set PATH=%PATH%;C:\oracle\instantclient_19_3
set ORACLE_HOME=C:\oracle
set HOME=C:\Users\b012349
REM Path to login.sql
set SQLPATH=C:\dev\fire-ddl
set NLS_LANG=.AL32UTF8

CALL db_setup.bat
set CON=%DB_USER%/%DB_PASS%@%DB_HOST%:%DB_PORT%/%DB_SERV%
REM ========================== Pre migration ================================
REM


REM IDENTER
python pre-migration\identer\refnr2ident.py
echo Copying refnr.txt to reffs1t
scp pre-migration\identer\refnr.txt regn@reffs1t:/home/regn/FIRE/refnr.txt
echo Running extract_ident.sh on reffs1t
ssh regn@reffs1t './FIRE/extract_idents.sh'
echo Copying idents_clean.txt from reffs1t to local machine
scp regn@reffs1t:/home/regn/FIRE/idents_clean.txt pre-migration\identer\idents_clean.txt
python pre-migration\identer\parse_idents.py
python pre-migration\identer\populate_refgeo_ident.py


REM SKITSER
python pre-migration\skitser\download_skitser.py
python pre-migration\skitser\populate_skitser.py

REM ============================ Migration ==================================

REM sqlplus -S %CON% @sqlplus.sql 2> errors.log

echo Migration\ClearDB.sql
echo exit | sqlplus -S %CON% @Migration\ClearDB.sql > logs\ClearDB.txt

echo DDL.sql
echo exit | sqlplus -S %CON% @DDL.sql > logs\DDL.txt

echo Migration\disable_triggers.sql
echo exit | sqlplus -S %CON% @Migration\disable_triggers.sql > logs\disable_triggers.txt

echo insertFIRERows.sql
echo exit | sqlplus -S %CON% @insertFIRERows.sql > logs\insertFIRERows.txt

echo Migration\MakeSRIDType.sql
echo exit | sqlplus -S %CON% @Migration\MakeSRIDType.sql > logs\MakeSRIDType.txt

echo Migration\MakePunktInfoType.sql
echo exit | sqlplus -S %CON%  @Migration\MakePunktInfoType.sql > logs\MakePunktInfoType.txt

echo Migration\MakeIds.sql
echo exit | sqlplus -S %CON% @Migration\MakeIds.sql > logs\MakeIds.txt

echo Migration\MakePunkt.sql
echo exit | sqlplus -S %CON% @Migration\MakePunkt.sql > logs\MakePunkt.txt

echo Migration\MakeGeometriObjekt.sql
echo exit | sqlplus -S %CON% @Migration\MakeGeometriObjekt.sql > logs\MakeGeometriObjekt.txt

echo Migration\MakeKoordinat.sql
echo exit | sqlplus -S %CON% @Migration\MakeKoordinat.sql > logs\MakeKoordinat.txt

echo Migration\MakePunktInfoAFM.sql
echo exit | sqlplus -S %CON% @Migration\MakePunktInfoAFM.sql > logs\MakePunktInfoAFM.txt

echo Migration\MakePunktInfoATTR.sql
echo exit | sqlplus -S %CON%  @Migration\MakePunktInfoATTR.sql > logs\MakePunktInfoATTR.txt

echo Migration\MakePunktInfoIDENT.sql
echo exit | sqlplus -S %CON% @Migration\MakePunktInfoIDENT.sql > logs\MakePunktInfoIDENT.txt

echo Migration\MakePunktInfoNET.sql
echo exit | sqlplus -S %CON% @Migration\MakePunktInfoNET.sql > logs\MakePunktInfoNET.txt

echo Migration\MakePunktInfoREGION.sql
echo exit | sqlplus -S %CON% @Migration\MakePunktInfoREGION.sql > logs\MakePunktInfoREGION.txt

echo Migration\MakePunktInfoSKITSE.sql
echo exit | sqlplus -S %CON%  @Migration\MakePunktInfoSKITSE.sql > logs\MakePunktInfoSKITSE.txt

echo Migration\MakeObservation.sql
echo exit | sqlplus -S %CON% @Migration\MakeObservation.sql > logs\MakeObservation.txt

echo Migration\MakeBeregning.sql
echo exit | sqlplus -S %CON% @Migration\MakeBeregning.sql > logs\MakeBeregning.txt

echo Migration\enable_triggers.sql
echo exit | sqlplus -S %CON% @Migration\enable_triggers.sql > logs\enable_triggers.txt

echo Grants.sql
echo exit | sqlplus -S %CON% @Grants.sql > logs\Grants.txt

REM ========================== Post migration ================================
python post-migration\dvr90net\indset_dvr90net.py
python post-migration\indset_fundamentalpunkter.py
python post-migration\GR96_UTM_coordinates.py

echo ========================== ERRORS ================================
grep ERROR logs/*.txt
