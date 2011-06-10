select  
b.contentid
,b.category_name 
,f.foldername
from dbo.ct_cgvbestbetscategory b inner join dbo.contentstatus c on b.contentid = c.contentid and c.public_revision = b.revisionid
inner join dbo.psx_objectrelationship r on r.dependent_id = b.contentid and config_id =3
inner join dbo.folder f on f.id = r.owner_id
order by f.foldername, b.category_name


-----------------------------------------------------------------




select  b.contentid,category_name , dbo.percReport_getitemfolderpath(b.contentid)
from ct_cgvbestbetscategory b inner join contentstatus c on b.contentid = c.contentid and c.public_revision = b.revisionid
order by category_name


select folder.foldername, ct_cgvbestbetscategory.category_name from folder, ct_cgvbestbetscategory, psx_objectrelationship where folder.id = psx_objectrelationship.owner_id and psx_objectrelationship.dependent_id = ct_cgvbestbetscategory.contentid order by folder.foldername, ct_cgvbestbetscategory.category_name


select  
replace(dbo.percReport_getitemfolderpath(b.contentid), 'cancergov/bestbets','') , count(*)
from dbo.ct_cgvbestbetscategory b inner join dbo.contentstatus c on b.contentid = c.contentid and c.public_revision = b.revisionid
group by replace(dbo.percReport_getitemfolderpath(b.contentid), 'cancergov/bestbets','')


select distinct owner_revision from dbo.psx_objectrelationship
where config_id =3