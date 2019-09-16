'''

NOTE!!

Remember to include Oracle instaclient in PATH:

    set PATH=%PATH%;C:\oracle\instantclient_18_3

Yes, this is bullshit, but what can you do!?


> fromidt -r refnr.txt -o landsnr.txt
> fromidt -f landsnr.txt -o identer.txt
> sed "/^ *$/d" identer.txt > indenter_new.txt # fjern blanke linjer
> grep -E -v "^\*|#" indenter_new.txt > identer_clean.txt

'''


import sys

import click
import cx_Oracle

usr = 'refadm'
pwd = 'ref03adm'
server = 'gst-orarac.prod.sitad.dk'
service = 'refgeo.prod.sitad.dk'
port = 1521

con = cx_Oracle.connect(f'{usr}/{pwd}@{server}:{port}/{service}')
cursor = con.cursor()

cursor.execute('SELECT count(*) FROM hvd_ref WHERE mv_status !=-1')
refnr_count = cursor.fetchone()[0]
cursor.execute('''SELECT refnr, typ FROM hvd_ref WHERE mv_status !=-1''')

with open('refnr.txt', 'w') as outfile:
    with click.progressbar(cursor, label='Reading refnumbers', length=refnr_count) as progress_cursor:
        for refnr, _ in progress_cursor:
            outfile.write(f'{refnr}\n')

con.close()
