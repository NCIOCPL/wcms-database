if object_id('percReport_getPretty_url_name') is  not null
	drop function dbo.percReport_getPretty_url_name 
GO
create function dbo.percReport_getPretty_url_name (@contentid int)
returns varchar(256)
as
BEGIN
	declare @prettyurl varchar(256)
	

				select @prettyurl = pretty_url_name 
				from
				(
				select pretty_url_name from dbo.CGVPUBLISHEDPAGEMETADATA_CGVPUBLISHEDPAGEMETADATA1 p
				inner join CONTENTSTATUS c on c.CONTENTID = p.CONTENTID and c.CURRENTREVISION = p.REVISIONID
				where c.CONTENTID  = @contentid
				union 
				select pretty_url_name from dbo.GENPAGEMETADATA_GENPAGEMETADATA1 p 
				inner join CONTENTSTATUS c on c.CONTENTID = p.CONTENTID and c.CURRENTREVISION = p.REVISIONID
				where c.CONTENTID  = @contentid
				union 
				select pretty_url_name from dbo.GLOPAGEMETADATASET_GLOPAGEMETADATASET p 
				inner join CONTENTSTATUS c on c.CONTENTID = p.CONTENTID and c.CURRENTREVISION = p.REVISIONID
				where c.CONTENTID  = @contentid
				)a
	
				

	return isnull(@prettyurl,'')
END

GO

