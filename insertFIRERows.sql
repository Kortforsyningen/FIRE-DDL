
-- Oprettelse af første sag samt tilhørende sagsrelaterede informationer
INSERT INTO SAG (ID, REGISTRERINGFRA)
VALUES ('4f8f29c8-c38f-4c69-ae28-c7737178de1f', to_date('2018-10-01','YYYY-MM-DD'));

INSERT INTO SAGSINFO (AKTIV, SAGID, REGISTRERINGFRA, REGISTRERINGTIL, JOURNALNUMMER, BEHANDLER, BESKRIVELSE)
VALUES ('true','4f8f29c8-c38f-4c69-ae28-c7737178de1f', to_date('2018-10-01','YYYY-MM-DD'), NULL,  NULL, 'Thomas Knudsen', 'Sagen er oprette i forbindelse med migrering af data fra REFGEO til FIRE');

commit;
-- NullObservationspunkt:
-- Første punkt i Punkt-tabellen. Udelukkende til brug for at at NULL-observatioen kan henvise til det.

INSERT INTO SAGSEVENT (ID, REGISTRERINGFRA, EVENT, SAGID)
VALUES ('ce5d92cb-e890-411b-a836-0b3f19564500', to_date('2018-10-02','YYYY-MM-DD'), 'punkt_oprettet', '4f8f29c8-c38f-4c69-ae28-c7737178de1f');

INSERT INTO PUNKT (ID, REGISTRERINGFRA, REGISTRERINGTIL, SAGSEVENTID)
VALUES ('cb29ee7b-d5ab-4903-aecd-3860a80caf0b', to_date('2018-10-02','YYYY-MM-DD'), NULL, 'ce5d92cb-e890-411b-a836-0b3f19564500');

INSERT INTO SAGSEVENTINFO (REGISTRERINGFRA, BESKRIVELSE, SAGSEVENTID)
VALUES (to_date('2018-10-02','YYYY-MM-DD'), 'NULL-punkt oprettet. Første punkt i Punkt-tabellen. Udelukkende til brug for at at NULL-observatioen kan henvise til det', 'ce5d92cb-e890-411b-a836-0b3f19564500');

commit;
-- Første række i observationstabellen. 
-- Udelukkende til brug for at beregninger uden egentlige observationer kan overholde modellen.

INSERT INTO SAGSEVENT (ID, REGISTRERINGFRA, EVENT, SAGID)
VALUES ('a36bc4c3-cb99-4d69-b891-52f976d69451', SYSDATE, 'observation_indsat', '4f8f29c8-c38f-4c69-ae28-c7737178de1f');

INSERT INTO OBSERVATION (REGISTRERINGFRA, SAGSEVENTID, OBSERVATIONSTIDSPUNKT, ANTAL, OBSERVATIONSTYPE, OPSTILLINGSPUNKTID)
VALUES (SYSDATE, 'a36bc4c3-cb99-4d69-b891-52f976d69451', SYSDATE , 0, 'nulobservation', 'cb29ee7b-d5ab-4903-aecd-3860a80caf0b');

commit;


-- Oprettelse af sagsevents med tilhørende sagseventinfo til anvendelse ved migrering fra REFGEO til FIRE

INSERT INTO SAGSEVENT (ID, REGISTRERINGFRA, EVENT, SAGID)
VALUES ('7f2952b7-7729-4952-8f05-b4f372abe939', SYSDATE, 'koordinat_beregnet', '4f8f29c8-c38f-4c69-ae28-c7737178de1f');

INSERT INTO SAGSEVENTINFO (REGISTRERINGFRA, BESKRIVELSE, SAGSEVENTID)
VALUES (SYSDATE, 'Denne event har migreret punkter og punkternes visningsgeometri fra REFGEO til FIRE', '7f2952b7-7729-4952-8f05-b4f372abe939');

INSERT INTO SAGSEVENT (ID, REGISTRERINGFRA, EVENT, SAGID)
VALUES ('d4a8c021-3b6a-4efb-86fb-2e1b9d6dd694', SYSDATE, 'observation_indsat', '4f8f29c8-c38f-4c69-ae28-c7737178de1f');

INSERT INTO SAGSEVENTINFO (REGISTRERINGFRA, BESKRIVELSE, SAGSEVENTID)
VALUES (SYSDATE, 'Denne event har migreret observationer fra REFGEO til FIRE', 'd4a8c021-3b6a-4efb-86fb-2e1b9d6dd694');

INSERT INTO SAGSEVENT (ID, REGISTRERINGFRA, EVENT, SAGID)
VALUES ('15101d43-ac91-4c7c-9e58-c7a0b5367910', SYSDATE, 'punktinfo_tilføjet', '4f8f29c8-c38f-4c69-ae28-c7737178de1f');

INSERT INTO SAGSEVENTINFO (REGISTRERINGFRA, BESKRIVELSE, SAGSEVENTID)
VALUES (SYSDATE, 'Denne event har migreret punktinformationer fra REFGEO til FIRE', '15101d43-ac91-4c7c-9e58-c7a0b5367910');

INSERT INTO SAGSEVENT (ID, REGISTRERINGFRA, EVENT, SAGID)
VALUES ('e964cca6-7b16-414a-9538-8639eacaac3d', SYSDATE, 'punkt_oprettet', '4f8f29c8-c38f-4c69-ae28-c7737178de1f');

INSERT INTO SAGSEVENTINFO (REGISTRERINGFRA, BESKRIVELSE, SAGSEVENTID)
VALUES (SYSDATE, 'Denne event har migreret punkter og punkternes visningsgeometri fra REFGEO til FIRE', 'e964cca6-7b16-414a-9538-8639eacaac3d');

commit;

-- End