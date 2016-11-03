if object_id('taxonomy_getTaxons') is not null
	drop procedure dbo.taxonomy_getTaxons
GO

create procedure dbo.taxonomy_getTaxons (@searchFilter nvarchar(900), @taxonomyName varchar(500) , @isLive bit =1)
as
BEGIN


if @isLive =1 
	select r.taxonID , r.Taxonlabel 
	from dbo.cgvPageMetadata  b inner join dbo.cgvTaxonRelation r on b.contentid = r.contentid
	where legacy_search_filter in (select * from [dbo].[udf_StringSplit](@searchFilter,',') )
	and r.taxonomyName = @taxonomyName
	Group by r.taxonID , r.Taxonlabel 

	ELSE
	select r.taxonID , r.Taxonlabel 
	from dbo.cgvStagingPageMetadata  b inner join dbo.cgvTaxonRelationstaging r on b.contentid = r.contentid
	where legacy_search_filter in (select * from [dbo].[udf_StringSplit](@searchFilter,',') )
	and r.taxonomyName = @taxonomyName
	Group by r.taxonID , r.Taxonlabel


END

GO
Grant execute on dbo.taxonomy_getTaxons to CDEuser