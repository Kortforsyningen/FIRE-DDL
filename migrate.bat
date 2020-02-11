@echo off
REM Setup
set PATH=%PATH%;C:\oracle\instantclient_19_3
set ORACLE_HOME=C:\oracle
REM Path to login.sql
set SQLPATH=C:\dev\fire\fire-ddl
set NLS_LANG=.AL32UTF8

CALL db_setup.bat
set CON=%DB_USER%/%DB_PASS%@%DB_HOST%:%DB_PORT%/%DB_SERV%
REM ========================== Pre migration ================================
REM
REM IDENTER
REM python pre-migration\identer\refnr2ident.py
REM scp pre-migration\identer\refnr.txt regn@reffs1t:/home/regn/FIRE/refnr.txt
REM ssh regn@reffs1t './FIRE/extract_idents.sh'
REM scp regn@reffs1t:/home/regn/FIRE/idents_clean.txt pre-migration\identer\idents_clean.txt
REM python pre-migration\identer\parse_idents.py
REM python pre-migration\identer\populate_refgeo_ident.py


REM ============================ Migration ==================================

REM sqlplus -S %CON% @sqlplus.sql 2> errors.log

echo Migration\ClearDB.sql
echo exit | sqlplus -S %CON% @Migration\ClearDB.sql > logs\ClearDB.txt

echo DDL.sql
echo exit | sqlplus -S %CON% @DDL.sql > logs\DDL.txt

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

REM ========================== Post migration ================================
python post-migration\dvr90net\indset_dvr90net.py
python post-migration\indset_fundamentalpunkter.py
python post-migration\GR96_UTM_coordinates.py

grep ERROR logs/*.txt
