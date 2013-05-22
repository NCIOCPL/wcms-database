
drop function dbo.percReport_getFolderPath
go
create function dbo.percReport_getFolderPath (@folderID int)
returns varchar(600)
as
BEGIN

declare @folderPath varchar(500)

	; with ancestor as 
			(
			select 
				NUll as contentid
				, f.contentid as owner_id
				, cs.title as foldername
			, convert(varchar(512),  cs.title) as path
			, 1 as level
			from PSX_folder f 
				inner join contentstatus cs on f.contentid = cs.contentid
			where f.contentid = @folderid
			union all
			select 
					r.dependent_id
					,r.owner_id
					, cs.title as foldername
					, convert(varchar(512),cs.title + '/' + a.path) as path
					, a.level + 1 
				from  ancestor a inner join PSX_ObjectRelationship r  
				ON r.dependent_id = a.owner_id and config_id = 3
				inner join contentstatus cs on  r.owner_id = cs.contentid 
			)
			select @folderpath = path 
			from ancestor 
			where level = (select level -1 from ancestor where owner_id =2 )  
			
		

	return @folderpath
END