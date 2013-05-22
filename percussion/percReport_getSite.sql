if object_id('percReport_getSite') is not null
		drop function dbo.percReport_getSite
go
create function dbo.percReport_getSite(@contentid int)
	returns varchar(300)
as
BEGIN
	declare @folderpath varchar(900), @site varchar(300)
	select @folderpath = dbo.percReport_getitemfolderpath(@contentid)
		if charindex('/', @folderpath ) >0
			select @site = left( @folderpath, charindex('/', @folderpath ) -1)
		else 
			select @site = @folderpath
	return @site
END

