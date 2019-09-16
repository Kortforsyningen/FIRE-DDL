import json
import itertools
import re
from collections import namedtuple

import click


Ident = namedtuple('Ident', ['ident', 'type'])

IDENT_FILE = 'idents_clean.txt'
#IDENT_FILE = 'identer_test.txt'

REGIONS = ('DK', 'EE', 'GL', 'SJ', 'FO', 'SE', 'FI')
REGIONS_REGEX = '|'.join(REGIONS)


def has_region(ident: str) -> bool:
    if ident[0:3].strip() in REGIONS:
        return True
    else:
        return False


def parse_ident_type(ident: str, region: str) -> str:
    ident = ident.strip() # We don't want unwanted whitespace poluting the search

    if re.match('^\D\w\w\w$', ident):
        return 'GNSS'

    if re.match('^\w{0,2}[\w\s]-\d{2}-[\w|\s|\.]{1,5}$', ident):
        return 'landsnr'

    if re.match('^81\s?\d{3}$', ident) and region not in REGIONS:
        return 'jessen'

    if re.match('^G\.[I|M]\.\d{4}(/\d{4}(.\d)?)?$', ident):
        return 'GI'

    return 'diverse'

# get a list of refnr
with open('refnr.txt') as f:
    refnumre = [int(l) for l in f.readlines()]

identer = []

with open(IDENT_FILE, 'r') as ident_fil:
    with click.progressbar(ident_fil, label='Parsing idents', length=len(refnumre)) as identer_progress:
        for i, (line, refnr) in enumerate(zip(identer_progress, refnumre)):


            # Split before region when only one space between idents
            line = re.sub("(\w)(\s{1,})"+f"({REGIONS_REGEX})", r"\1~\3", line)


            # Reduce to only one space between region and ident
            line = re.sub(f"([{REGIONS_REGEX}] )(\s*)(\w)", r"\1\3", line)

            # Split on two or more spaces
            line = re.sub("(\w)(\s{2,})(\w)", r"\1~\3", line)

            # list(dict.fromkeys()) removes duplicate entries and preserves order
            idents = list(dict.fromkeys(line.strip().split("~")))


            temp_idents = []

            for text in idents:
                if has_region(text):
                    code = text[2:].strip()
                    region = text[0:3].strip()
                else:
                    code = text.strip()
                    region = ''

                # Strip all singular spaces
                #code = re.sub("(\S)(\s)(\S)", r'\1\3', code).strip()
                code = re.sub("(\s)(\S)", r'\2', code).strip()

                # Add country code if present
                ident_type = parse_ident_type(code, region)

                # A few GNSS ident duplicates exists, i.e. "DK  NORD" and
                # "FO  NORD". We don't want to include the region for Danish
                # GNSS idents
                if ident_type == 'GNSS' and region == 'DK':
                    region = ''
                ident = (region + '  ' + code).strip()

                if ident == '':
                    continue

                idt = {'1': refnr, '2': ident_type, '3': ident}
                if idt in temp_idents:
                    continue
                temp_idents.append(idt)

            identer.extend(temp_idents)


with open('identer.json', 'w') as out:
    json.dump(identer, out, indent=4)
