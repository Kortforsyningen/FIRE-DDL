'''

NOTE!!

Remember to include Oracle instaclient in PATH:

    set PATH=%PATH%;C:\oracle\instantclient_18_3

'''

import sys
from pathlib import Path

import click
import cx_Oracle

from db_connect import (usr, pwd, server, service, port)

BASE = Path(__file__).parents[0]
REFNR_FILE = BASE / Path('refnr.txt')


con = cx_Oracle.connect(f'{usr}/{pwd}@{server}:{port}/{service}', encoding='UTF-8', nencoding='UTF-8')
cursor = con.cursor()

cursor.execute('SELECT count(*) FROM hvd_ref@refgeo WHERE mv_status !=-1')
refnr_count = cursor.fetchone()[0]
cursor.execute('''SELECT refnr, typ FROM hvd_ref@refgeo WHERE mv_status !=-1''')

with open(REFNR_FILE, 'w') as outfile:
    with click.progressbar(cursor, label='Reading refnumbers', length=refnr_count) as progress_cursor:
        for refnr, _ in progress_cursor:
            outfile.write(f'{refnr}\n')

con.close()
