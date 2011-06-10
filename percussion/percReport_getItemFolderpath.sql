if object_id('percReport_getitemFolderPath') is not null
  drop function percReport_getItemFolderPath
go
create function dbo.percReport_getitemFolderPath(@contentid int)
returns varchar(300)
as
BEGIN
	declare @folderid int
	select top 1 @folderid = owner_id 
		from dbo.psx_objectRelationship 
	where dependent_id = @contentid and config_id = 3 order by owner_revision desc
return dbo.percReport_getFolderpath(@folderid)


END
