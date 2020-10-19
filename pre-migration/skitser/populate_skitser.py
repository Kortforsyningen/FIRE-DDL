"""
CREATE TABLE fire_skitser (
    refnr NUMBER,
    versnr NUMBER,
    png_path VARCHAR2(200),
    png_md5 VARCHAR2(200),
    master_path VARCHAR2(200),
    master_md5 VARCHAR2(200)
);
"""
import json
from pathlib import Path

import click
import cx_Oracle

from db_connect import (usr, pwd, server, service, port)

base_path = Path(r'F:\GRF\Data\FIRE')
FILE = Path(r'F:\GRF\Data\FIRE\skitser.json')

with open(FILE, 'r') as f:
    skitser = json.load(f)

con = cx_Oracle.connect(f'{usr}/{pwd}@{server}:{port}/{service}', encoding='UTF-8', nencoding='UTF-8')
cursor = con.cursor()

cursor.execute('DELETE FROM fire_skitser')
con.commit()
sql = 'INSERT INTO fire_skitser (refnr, versnr, png_path, png_md5, master_path, master_md5) VALUES (:1, :2, :3, :4, :5, :6)'
cursor.prepare(sql)
cursor.executemany(None, skitser)
con.commit()
cursor.close()
con.close()
