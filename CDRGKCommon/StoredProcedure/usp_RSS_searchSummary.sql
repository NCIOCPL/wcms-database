If object_id('usp_RSS_searchSummary') is not NULL
	DROP procedure dbo.usp_RSS_searchSummary
GO
create procedure dbo.usp_RSS_searchSummary
@audience varchar(50),
@NumItems int =20,
@summaryType varchar(100) ='All',
@NewOrUpdated varchar(20)= 'both',
@Language varchar(20) = 'English'
As
BEGIN
	set nocount on

	if @NewOrUpdated = 'both'
		select top (@NumItems)
			case when (datefirstPublished > = datelastModified or DateLastModified is NULL) then 'New - ' else 'Updated - ' END + title as title, 
			description,type as Category, 
			case when charindex('cancer.gov' , prettyurl ) >0 then 
			right(prettyurl,  len(prettyURL) - ( charindex('cancer.gov' , prettyurl ) + 9) )
			else prettyurl
			END as link
			, 
			case when datefirstPublished > = datelastModified then datefirstPublished
						else coalesce( dateLastModified, datefirstPublished) END as PubDate
		from dbo.summary
		where audience = @audience
				and language = @language
				and (	@summaryType = 'ALL' or
						(@SummaryType <> 'ALL' and type = @SummaryType)
					 )
				and prettyURL is not NULL
		order by case when datefirstPublished > = datelastModified then dateFirstPublished
						else coalesce( dateLastModified, datefirstPublished)
				END Desc
		ELSE
			IF @NewOrUpdated = 'new'
				select top (@NumItems)
					title, description,type as Category, 
					case when charindex('cancer.gov' , prettyurl ) >0 then 
					right(prettyurl,  len(prettyURL) - ( charindex('cancer.gov' , prettyurl ) + 9) )
					else prettyurl
					END as link
					,
					DatefirstPublished as PubDate					
				from dbo.summary
				where audience = @audience
						and language = @language
						and (	@summaryType = 'ALL' or
								(@SummaryType <> 'ALL' and type = @SummaryType)
							 )
						and prettyURL is not NULL
				order by DateFirstPublished Desc
			ElSE
			if @NewOrUpdated = 'Update'
				select top (@NumItems)
					title, description,type as Category, 
					case when charindex('cancer.gov' , prettyurl ) >0 then 
					right(prettyurl,  len(prettyURL) - ( charindex('cancer.gov' , prettyurl ) + 9) )
					else prettyurl
					END as link
					,
					DateLastModified as PubDate					
				from dbo.summary
				where audience = @audience
						and language = @language
						and (	@summaryType = 'ALL' or
								(@SummaryType <> 'ALL' and type = @SummaryType)
							 )
						and prettyURL is not NULL
				order by DateLastModified Desc
	
END
GO

Grant execute on dbo.usp_RSS_searchSummary to websiteuser