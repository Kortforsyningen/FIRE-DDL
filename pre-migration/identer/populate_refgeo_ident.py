import json

from pathlib import Path

import click
import cx_Oracle

from db_connect import (usr, pwd, server, service, port)

BASE = Path(__file__).parents[0]
FILE = BASE / Path('identer.json')

with open(FILE, 'r') as f:
    identer = json.load(f)


con = cx_Oracle.connect(f'{usr}/{pwd}@{server}:{port}/{service}', encoding='UTF-8', nencoding='UTF-8')
cursor = con.cursor()

cursor.execute('DELETE FROM refnr_ident')
con.commit()
sql = 'INSERT INTO refnr_ident (refnr, ident_type, ident) VALUES (:1, :2, :3)'
cursor.prepare(sql)
cursor.executemany(None, identer)
con.commit()
cursor.close()
con.close()