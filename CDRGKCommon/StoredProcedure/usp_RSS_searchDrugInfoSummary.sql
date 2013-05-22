If object_id('usp_RSS_searchDrugInfoSummary') is not NULL
	DROP procedure dbo.usp_RSS_searchDrugInfoSummary
GO
create procedure dbo.usp_RSS_searchDrugInfoSummary
@NumItems int =20,
@NewOrUpdated varchar(20)= 'both'
As
BEGIN
	set nocount on

	if @NewOrUpdated = 'both'
		select top (@NumItems)
			case when (datefirstPublished > = datelastModified or DateLastModified is NULL) then 'New - ' else 'Updated - ' END + title as title, 
			description, 
			case when datefirstPublished > = datelastModified then datefirstPublished
						else coalesce( dateLastModified, datefirstPublished) END as PubDate 
			, prettyurl as link
		from dbo.DrugInfoSummary
		order by case when datefirstPublished > = datelastModified then dateFirstPublished
						else coalesce( dateLastModified, datefirstPublished)
				END Desc
		ELSE
			IF @NewOrUpdated = 'new'
				select top (@NumItems)
					title, 
					description,
					DatefirstPublished as PubDate
					,   prettyurl as link
				from dbo.DrugInfoSummary
				order by DateFirstPublished Desc
			ElSE
				if @NewOrUpdated = 'Update'
					select top (@NumItems)
						title, 
						description,
						DateLastModified as PubDate					
						,   prettyurl as link
					from dbo.DrugInfoSummary
					order by DateLastModified Desc
	
END
GO
Grant execute on dbo.usp_RSS_searchDrugInfoSummary to websiteuser