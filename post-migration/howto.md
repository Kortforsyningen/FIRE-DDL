# Post-migration

En række operationer er nødvendige at udføre efter en REFGEO -> FIRE migration er kørt. Disse beskrives herunder.

## NET:DVR90

NET:DVR90 bruges i bestemmelsen af ARTSKODE i udstillingsmodellen.
Indsættelse af attributten sker ved hjælp af Python API'et til FIRE.
Dette er derfor en forudsætning for at scriptet kan køres. Det gøres
ved følgende kommonda:

```
python indset_dvr90net.py
```