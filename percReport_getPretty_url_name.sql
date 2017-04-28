if object_id('percReport_getPretty_url_name') is  not null
	drop function dbo.percReport_getPretty_url_name 
GO
create function dbo.percReport_getPretty_url_name (@contentid int)
returns varchar(256)
as
BEGIN
	declare @prettyurl varchar(256), @subpage varchar(400)

	if not exists (select * from
		dbo.CGVPUBLISHEDPAGEMETADATA_CGVPUBLISHEDPAGEMETADATA1 
		where contentid = @contentid
		)
		select @prettyurl = '***'
	ELSE

		BEGIN

			select @subpage = 'page' + convert(varchar(3),r.sort_rank +1) from psx_objectrelationship r inner join contentstatus c on r.owner_id = c.contentid
			and (r.owner_revision = c.public_revision)
			where dependent_id = @contentid and config_id = 112
			if @subpage is not null
				select @prettyurl = isnull(pretty_url_name,'') + isnull( @subpage, '') from
				dbo.CGVPUBLISHEDPAGEMETADATA_CGVPUBLISHEDPAGEMETADATA1 
				where contentid = @contentid
			else 
				select @prettyurl = pretty_url_name from
				dbo.CGVPUBLISHEDPAGEMETADATA_CGVPUBLISHEDPAGEMETADATA1 
				where contentid = @contentid

		END


	return @prettyurl
END

GO

