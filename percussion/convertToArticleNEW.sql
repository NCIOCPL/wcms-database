update c set c.CONTENTTYPEID = (select contenttypeid from CONTENTTYPES where CONTENTTYPENAME = 'cgvarticle')
from CONTENTSTATUS c inner join CONTENTTYPES t on c.CONTENTTYPEID = t.CONTENTTYPEID 
where t.CONTENTTYPENAME in ('cgvClinicaltrialresult', 'cgvDruginfosummary', 'cgvFeaturedClinicaltrial')

insert into CT_CGVARTICLE1 (CONTENTID, REVISIONID)
select contentid , revisionid from dbo.CT_CGVCLINICALTRIALRESULT

insert into CT_CGVARTICLE1 (CONTENTID, REVISIONID)
select contentid , revisionid from dbo.CT_CGVDRUGINFOSUMMARY 

insert into CT_CGVARTICLE1 (CONTENTID, REVISIONID)
select contentid , revisionid from dbo.CT_CGVFEATUREDCLINICALTRIAL

truncate table CT_CGVCLINICALTRIALRESULT 
truncate table ct_cgvdruginfosummary
truncate table ct_cgvfeaturedclinicaltrial 

