'''
Missing images:

    28011 2
    43973 2
    128102 2
    518032 2
    518033 2
    518981 2
    519227 2
    519230 2
'''

import gzip
import json
import hashlib
from pathlib import Path

import click
import cx_Oracle

from db_connect import (usr, pwd, server, service, port)

def md5sum(path):
    """Return md5 sum of file given in path."""
    md5 = hashlib.md5(open(path, 'rb').read()).hexdigest()
    return md5


base_path = Path(r'C:\data\fire\imgs')
base_path = Path(r'F:\GRF\Data\FIRE')

con = cx_Oracle.connect(f'{usr}/{pwd}@{server}:{port}/{service}', encoding='UTF-8', nencoding='UTF-8')
cursor = con.cursor()

cursor.execute('SELECT count(*) FROM skitse WHERE skitse_typ=1')
refnr_count = cursor.fetchone()[0]


sql = """SELECT
    s.refnr,  s.skitse# skitse, p.skitse# png, s.grafik_format, s.versnr, (SELECT r.ident FROM refnr_ident r WHERE s.refnr=r.refnr AND ROWNUM=1) ident
FROM
    skitse s
JOIN skitse_png p  ON s.refnr=p.refnr_id
WHERE
    s.grafik_format IS NOT NULL
"""

#sql = f'SELECT * FROM ({sql}) WHERE rownum <= 25' # circumvent Oracle limitations
cursor.execute(sql)

skitser = []

with click.progressbar(cursor, label="Læser skitser", length=refnr_count) as progress_cursor:
    for refnr, master, png, fmt, version, landsnr in progress_cursor:

        fmt = fmt.strip()

        try:
            # Gem PNG fil
            png_path = Path('skitser_png') / Path(landsnr.replace(' ', '') + f'_{version}.png')
            with open(base_path / png_path, 'wb+') as png_image:
                png_image.write(png.read())

            png_md5 = md5sum(base_path / png_path)

            # Gem master fil
            if fmt == 'tif.gz':
                master = gzip.decompress(master.read())
                fmt = 'tif'
            else:
                master = master.read()

            master_path = Path('skitser_master') / Path(landsnr.replace(' ', '') + f'_{version}.{fmt}')
            with open(base_path / master_path, 'wb+') as master_img:
                master_img.write(master)
            master_md5 = md5sum(base_path / master_path)

            skitser.append({1: refnr, 2: version, 3: str(png_path).replace("\\", "/"), 4: png_md5, 5: str(master_path).replace("\\", "/"), 6: master_md5})

        except Exception as e:
            print(f'Unknown exception: {refnr}, {fmt}, {version}, {landsnr}')
            print(e)
            continue


with open(base_path  / Path('skitser.json'), 'w') as out:
    json.dump(skitser, out, indent=4)
