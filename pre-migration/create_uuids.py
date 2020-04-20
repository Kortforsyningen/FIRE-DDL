""""
Script der bruges til at generere tilfældige UUID'er til brug
i PUNKT-tabellen
"""
from functools import wraps
from time import time
import uuid

import cx_Oracle

from fire.cli import _username, _password, _hostname, _port, _service

if __name__ == "__main__":

    print("Creating UUIDS")

    rows = 1000000
    uuids = [(rowid, str(uuid.uuid4())) for rowid in range(rows)]
    con = cx_Oracle.connect(
        f"{_username}/{_password}@{_hostname}:{_port}/{_service}",
        encoding="UTF-8",
        nencoding="UTF-8",
    )
    cursor = con.cursor()

    try:
        cursor.execute('DROP TABLE temp_uuids')
    except:
        pass
    cursor.execute("CREATE TABLE temp_uuids (id NUMBER, uuid VARCHAR2(36))")
    con.commit()
    sql = "INSERT INTO temp_uuids (id, uuid) VALUES (:1, :2)"
    cursor.prepare(sql)
    cursor.executemany(None, uuids, arraydmlrowcounts=rows)
    con.commit()
    cursor.close()
    con.close()
