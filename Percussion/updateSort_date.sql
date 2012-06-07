-------------
--citation

update g
set g.sort_date = gc.publication_date
from GENQUERYSET_GENQUERYSET g 
inner join contentstatus c on g.contentid = c.contentid 
inner join CT_GENCITATION gc on gc.contentid = c.contentid and gc.revisionid = c.currentrevision

insert into GENQUERYSET_GENQUERYSET(contentid, revisionid, sort_date)
select c.contentid, c.currentrevision, gc.publication_date 
from contentstatus c 
inner join CT_GENCITATION gc on gc.contentid = c.contentid and gc.revisionid = c.currentrevision
where c.contentid not in (select contentid from GENQUERYSET_GENQUERYSET)


--------

---event

update g
set g.sort_date = gc.start_date
from GENQUERYSET_GENQUERYSET g 
inner join contentstatus c on g.contentid = c.contentid 
inner join CT_GENEVENT gc on gc.contentid = c.contentid and gc.revisionid = c.currentrevision

insert into GENQUERYSET_GENQUERYSET(contentid, revisionid, sort_date)
select c.contentid, c.currentrevision, gc.start_date 
from contentstatus c 
inner join CT_GENEVENT gc on gc.contentid = c.contentid and gc.revisionid = c.currentrevision
where c.contentid not in (select contentid from GENQUERYSET_GENQUERYSET)

---------


update g
set g.sort_date = gc.date_first_published
from GENQUERYSET_GENQUERYSET g 
inner join contentstatus c on g.contentid = c.contentid 
inner join contenttypes t on t.contenttypeid = c.contenttypeid
inner join GENDATESSET_GENDATESSET gc on gc.contentid = c.contentid and gc.revisionid = c.currentrevision
where contenttypename in ('genfile', 'genGeneral'
, 'genNews', 'genNewsletterDetails', 'genFundingOpp', 'gloVideo')
and date_first_published is not null


insert into GENQUERYSET_GENQUERYSET(contentid, revisionid, sort_date)
select c.contentid, c.currentrevision, gc.date_first_published
from contentstatus c 
inner join contenttypes t on t.contenttypeid = c.contenttypeid
inner join GENDATESSET_GENDATESSET gc on gc.contentid = c.contentid and gc.revisionid = c.currentrevision
where 
contenttypename in ('genfile', 'genGeneral'
, 'genNews', 'genNewsletterDetails', 'genFundingOpp', 'gloVideo')
and 
date_first_published is not null
and 
c.contentid not in 
(select contentid from GENQUERYSET_GENQUERYSET)