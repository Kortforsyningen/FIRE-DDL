# Pre-migration

En række operationer er nødvendige at udføre inden en REFGEO -> FIRE migration
køres. Disse beskrives herunder.

## Identer

Formålet er at lave en tabel i REFGEO der knytter fikspunktsidenter til dets
unikke refnummer. Denne tabel findes i REFGEO under navnet REFNR_IDENT.
I migrationen fra REFGEO til FIRE bruges denne tabel til at registrere identer
i FIRE.

Fikspunktsidenter findes ikke direkte i REFGEO. Identerne stykkes sammen af
data fra flere forskellige kilder i REFGEO og desværre er metoden til dette
ukendt. Ved hjælp af programmet `from_idt`, der kører på `reffs1t` maskinen,
kan et REFGEO refnr omdannes til et landsnr. Samme applikation kan udtrække
samtlige andre identer til samme punkt ud fra landsnummeret.

Med `refnr2ident.py` udtrækkes alle refnumre fra REFGEO til filen `refnr.txt`:

```
> set PATH=%PATH%;C:\oracle\instantclient_18_3
> python refnr2ident.py
> scp refnr.txt regn@reffs1t:/home/regn/FIRE
```

På `reffs1t` eksekveres nedenstående kommando. Afviklingen tager en halv times tid.

```
extract_idents.sh
```

scriptet slutter af og til med en segfault. Efter alt at dømme sker segfaulten
efter output-filen er genereret og skrevet til disken, så umiddelbart er der ikke
noget at være bekymret for.

Herefter flyttes filen `identer_clean.txt` tilbage til den lokale maskine:

```
scp regn@reffs1t:/home/regn/FIRE/idents_clean.txt .
```

Når filen er hentet skal den køres igennem et script der rydder op i filen
og organiserer data på en brugbar måde:

```
python parse_idents.py
```

Dette script genererer filen `identer.json` som efterfølgende indlæses i REFGEO ved

```
python populate_refgeo_ident.py
```
