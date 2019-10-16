@echo off
REM Setup
set PATH=%PATH%;C:\oracle\instantclient_19_3
set ORACLE_HOME=C:\oracle
set NLS_LANG=.AL32UTF8

CALL db_setup.bat
set CON=%DB_USER%/%DB_PASS%@%DB_HOST%:%DB_PORT%/%DB_SERV%
REM ========================== Pre migration ================================
REM
REM IDENTER
python pre-migration\identer\refnr2ident.py
scp pre-migration\identer\refnr.txt regn@reffs1t:/home/regn/FIRE/refnr.txt
ssh regn@reffs1t './FIRE/extract_idents.sh'
scp regn@reffs1t:/home/regn/FIRE/idents_clean.txt pre-migration\identer\idents_clean.txt
python pre-migration\identer\parse_idents.py
python pre-migration\identer\populate_refgeo_ident.py


REM ============================ Migration ==================================

REM sqlplus -S %CON% @sqlplus.sql 2> errors.log

echo Migration\ClearDB.sql
(echo.SET SQLBLANKLINES ON
echo.START Migration\ClearDB.sql
echo.exit )| sqlplus -S %CON% > logs\ClearDB.txt

echo DDL.sql
(echo.SET SQLBLANKLINES ON
echo.START DDL.sql
echo.exit )| sqlplus -S %CON% > logs\DDL.txt

echo insertFIRERows.sql
(echo.SET SQLBLANKLINES ON
echo.START insertFIRERows.sql
echo.exit )| sqlplus -S %CON% > logs\insertFIRERows.txt

echo Migration\MakeSRIDType.sql
(echo.SET SQLBLANKLINES ON
echo.START Migration\MakeSRIDType.sql
echo.exit )| sqlplus -S %CON% > logs\MakeSRIDType.txt

echo Migration\MakePunktInfoType.sql
(echo.SET SQLBLANKLINES ON
echo.START Migration\MakePunktInfoType.sql
echo.exit )| sqlplus -S %CON% > logs\MakePunktInfoType.txt

echo Migration\MakeIds.sql
(echo.SET SQLBLANKLINES ON
echo.START Migration\MakeIds.sql
echo.exit )| sqlplus -S %CON% > logs\MakeIds.txt

echo Migration\MakePunkt.sql
(echo.SET SQLBLANKLINES ON
echo.START Migration\MakePunkt.sql
echo.exit )| sqlplus -S %CON% > logs\MakePunkt.txt

echo Migration\MakeGeometriObjekt.sql
(echo.SET SQLBLANKLINES ON
echo.START Migration\MakeGeometriObjekt.sql
echo.exit )| sqlplus -S %CON% > logs\MakeGeometriObjekt.txt

echo Migration\MakeKoordinat.sql
(echo.SET SQLBLANKLINES ON
echo.START Migration\MakeKoordinat.sql
echo.exit )| sqlplus -S %CON% > logs\MakeKoordinat.txt

echo Migration\MakePunktInfoAFM.sql
(echo.SET SQLBLANKLINES ON
echo.START Migration\MakePunktInfoAFM.sql
echo.exit )| sqlplus -S %CON% > logs\MakePunktInfoAFM.txt

echo Migration\MakePunktInfoIDENT.sql
(echo.SET SQLBLANKLINES ON
echo.START Migration\MakePunktInfoATTR.sql
echo.exit )| sqlplus -S %CON% > logs\MakePunktInfoATTR.txt

echo Migration\MakePunktInfoIDENT.sql
(echo.SET SQLBLANKLINES ON
echo.START Migration\MakePunktInfoIDENT.sql
echo.exit )| sqlplus -S %CON% > logs\MakePunktInfoIDENT.txt

echo Migration\MakePunktInfoNET.sql
(echo.SET SQLBLANKLINES ON
echo.START Migration\MakePunktInfoNET.sql
echo.exit )| sqlplus -S %CON% > logs\MakePunktInfoNET.txt

echo Migration\MakePunktInfoREGION.sql
(echo.SET SQLBLANKLINES ON
echo.START Migration\MakePunktInfoREGION.sql
echo.exit )| sqlplus -S %CON% > logs\MakePunktInfoREGION.txt

echo Migration\MakePunktInfoSKITSE.sql
(echo.SET SQLBLANKLINES ON
echo.START Migration\MakePunktInfoSKITSE.sql
echo.exit )| sqlplus -S %CON% > logs\MakePunktInfoSKITSE.txt

echo Migration\MakeObservation.sql
(echo.SET SQLBLANKLINES ON
echo.START Migration\MakeObservation.sql
echo.exit )| sqlplus -S %CON% > logs\MakeObservation.txt

echo Migration\MakeBeregning.sql
(echo.SET SQLBLANKLINES ON
echo.START Migration\MakeBeregning.sql
echo.exit )| sqlplus -S %CON% > logs\MakeBeregning.txt

REM ========================== Post migration ================================
python post-migration\dvr90net\indset_dvr90net.py

grep ERROR logs/*.txt
