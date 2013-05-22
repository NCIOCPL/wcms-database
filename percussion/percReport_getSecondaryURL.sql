if object_id('percReport_getSecondaryURL') is not null
	drop function dbo.percReport_getSecondaryURL 
go
create function dbo.percReport_getSecondaryURL (@contentid int, @c tinyint)
returns varchar(3000)
as
BEGIN
	declare @u varchar(500), @sort_rank varchar(3), @mainContentid int

	
	select @sort_rank = convert(varchar(3),sort_rank), @maincontentid = c.contentid 
		from psx_objectrelationship r inner join contentstatus c on r.owner_id = c.contentid
		where r.dependent_id = @contentid and r.config_id = 112 and owner_revision = c.public_revision

	if @sort_rank is null		
			select @u =  promo_url from
			(
			select  promo_url,row_number() over (partition by p.contentid order by s.promo_url) i
			from dbo.CT_CGVPROMOURL1 s inner join contentstatus c on c.contentid = s.contentid and c.public_revision = s.revisionid
			inner join PSX_ObjectRelationship r on s.contentid = r.owner_id and r.owner_revision = c.public_revision
			inner join contentstatus p on p.contentid = r.dependent_id
			where p.contentid = @contentid
			)a
			  where i= @c
		ELSE		
			select @u =  promo_url from
			(
			select  promo_url + '/page' + @sort_rank  as promo_url,row_number() over (partition by p.contentid order by s.promo_url) i
			from dbo.CT_CGVPROMOURL1 s inner join contentstatus c on c.contentid = s.contentid and c.public_revision = s.revisionid
			inner join PSX_ObjectRelationship r on s.contentid = r.owner_id and r.owner_revision = c.public_revision
			inner join contentstatus p on p.contentid = r.dependent_id
			where p.contentid = @maincontentid
			)a
			  where i= @c


	return @u

END