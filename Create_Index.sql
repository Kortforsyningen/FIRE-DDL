-- -- create index punkt_pid on punkt(punktid); -- findes hedder id_idx_0001
create index punktinfo_pid on punktinfo(punktid);
create index koordinat_pid on koordinat(punktid);
create index geomobj_pid on geometriobjekt(punktid);

create index observ_opid on observation(opstillingspunktid);
create index observ_spid on observation(sigtepunktid);

-- Der er i forvejen index på punktinfotype(infotypeid);
create index punktinfotyp_anv on punktinfotype(anvendelse);
create index punktinfotyp_typ on punktinfotype(infotype);


--- --  Dette bør lægges på ifm indlæsning fra REFGEO
create unique index geomobj_datopid on geometriobjekt(punktid, registreringfra);