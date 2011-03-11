If object_id('usp_RSS_searchProtocol') is not NULL
	DROP procedure dbo.usp_RSS_searchProtocol
GO
create procedure dbo.usp_RSS_searchProtocol
@NumItems int =40
As
BEGIN
	set nocount on

	select top (@NumItems)
			 HealthProfessionaltitle, 
			'' as description,datefirstPublished as PubDate,
			typeOfTrial as Category,  PrimaryPrettyurlID as link
		from dbo.protocol p inner join protocoldetail t on p.protocolid  = t.protocolid 
		where  isactiveProtocol =1
		order by dateFirstPublished  Desc
		
END
GO

Grant execute on dbo.usp_RSS_searchProtocol to websiteuser