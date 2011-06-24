-- not a SP, but script direct used by Percussion

/*
select  
b.contentid
,b.category_name 
,f.foldername
from dbo.ct_cgvbestbetscategory b inner join dbo.contentstatus c on b.contentid = c.contentid and c.public_revision = b.revisionid
inner join dbo.psx_objectrelationship r on r.dependent_id = b.contentid and config_id =3
inner join dbo.folder f on f.id = r.owner_id
order by f.foldername, b.category_name
*/



