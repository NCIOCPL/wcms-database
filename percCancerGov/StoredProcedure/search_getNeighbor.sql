use percCancergov
go
if OBJECT_ID('search_getNeighbor') is not null
	drop procedure dbo.search_getNeighbor 
go
create procedure dbo.search_getNeighbor 
(@contentid int
, @filter nvarchar(500)
,@Language nvarchar(2) = 'en'
, @isLive bit = 1,
@siteName nvarchar(400) = '//Sites/CancerGov')
As
BEGIN
	declare  @r int
		-- staging or live
	
	if @islive = 1
	
	BEGIN
	
		select ROW_NUMBER() OVER (ORDER BY date_first_published, contentid) as rownumber
			, *
			into #t
			from dbo.cgvPageMetadata
			where site = @siteName
			and LANGUAGE = @Language
			and LEGACY_SEARCH_FILTER like @filter +'%'
			and LEGACY_SEARCH_FILTER in
			(select top 1 LEGACY_SEARCH_FILTER from dbo.cgvPageMetadata where CONTENTID = @contentid)
			
		
			select @r = rownumber from #t 
			where CONTENTID = @contentid
			
			
			select *
			from #t
			where rownumber = @r -1 
			 
			select *
			from #t
			where rownumber = @r +1 
			
	END
	ELSE	
	
		BEGIN
			select ROW_NUMBER() OVER (ORDER BY date_first_published, contentid) as rownumber
			, *
			into #t1
			from dbo.cgvstagingPageMetadata
			where site = @siteName
			and LANGUAGE = @Language
			and LEGACY_SEARCH_FILTER like @filter +'%'
			and LEGACY_SEARCH_FILTER in
			(select top 1 LEGACY_SEARCH_FILTER from dbo.cgvstagingPageMetadata where CONTENTID = @contentid)
		
		
			select @r = rownumber from #t1
			where CONTENTID = @contentid
			
		
			select *
			from #t1
			where rownumber = @r -1 
			 
			select *
			from #t1
			where rownumber = @r +1 
			
			
		END
	
END
GO

grant execute on dbo.search_getNeighbor to CDEUser
GO


