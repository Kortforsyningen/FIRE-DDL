prompt run login.sql
show sqlterminator
show sqlblanklines
set sqlblanklines on
set sqlterminator ';'
show sqlterminator
show sqlblanklines
WHENEVER SQLERROR EXIT SQL.SQLCODE
alter session set current_schema = FIRE_ADM;
prompt ready login.sql
set echo on