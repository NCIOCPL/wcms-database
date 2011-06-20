if object_id('percReport_getOwner') is not null
	drop function dbo.percReport_getOwner 
go
create function dbo.percReport_getOwner (@contentid int, @c tinyint)
returns varchar(3000)
as
BEGIN
	declare @owner int
	
		select @owner= owner_id from
		(
		select distinct r.owner_id, row_number() over (order by owner_id) as i
		from dbo.psx_objectrelationship r
		inner join dbo.contentstatus c on c.contentid = r.owner_id and (r.owner_revision = -1 or r.owner_revision = c.public_revision)
			where dependent_id = @contentid and config_id <> 3 
		) a
		where  i  = @c
		


	return @owner

END