USE [PercCancerGov]
GO

/****** Object:  StoredProcedure [dbo].[searchFilterKeywordDate]    Script Date: 08/04/2015 09:25:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

if OBJECT_ID('searchFilterKeywordDate') is not null
	drop procedure [dbo].[searchFilterKeywordDate]
go

create procedure [dbo].[searchFilterKeywordDate]
(
@Keyword nvarchar(500) = NULL,
@StartDate datetime = null,
@EndDate datetime = null,
@SearchFilter nvarchar(500) = NULL,
@ExcludeSearchFilter nvarchar(500) = NULL, 
@ResultsSortOrder int = 0,
@Language nvarchar(2) = 'en',
--@SearchType nvarchar = NULL,
@MaxResults int = 500 ,
@RecordsPerPage int = 20,
@StartPage int = 1,
@isLive bit = 1,
@siteName nvarchar(400) = '//Sites/CancerGov',
@taxonomyFilter udt_taxonomyFilter READONLY
)
AS
BEGIN
	declare @s nvarchar(max), 
			@select nvarchar(3000), 
			@from nvarchar(2000), 
			@where nvarchar(4000),
			@orderby nvarchar(2000),
			@rowNumber nvarchar(2000),
			@paging nvarchar(1000),
			@Scount nvarchar(max)

	if @siteName = ''
		select @siteName = '//Sites/CancerGov'

	if @maxResults > 0
			select @select = 'select top ' + convert(nvarchar(20), @maxResults)  
				+' p.* '
		ELSE
			select @select = 'select  p.*  '
		
	-- staging or live
	if @searchfilter like N'Blog Series-%'
			BEGIN
			if @islive = 1
				select @from =  ' from   dbo.cgvBlog p '  
			ELSE
				select @from =  ' from  dbo.cgvStagingBlog p '  
			END
		ELSE
			BEGIN
			if @islive = 1
					select @from =  ' from   dbo.cgvPageSearch  p '  
				ELSE
					select @from =  ' from  dbo.cgvStagingPageSearch p '  
			END

	select @where = ' site = ''' + @siteName + ''''

		if @keyword is not NULL
			select @where =  @where + ' and contentid in
		(
		select distinct contentid
		 from   dbo.cgvPageSearch   p inner join dbo.udf_stringSplit(''' + 
				@keyword + ''', '' '') a on p.meta_keywords like ''%''+ a.objectid + ''%''  )' 
	
	
	
	if exists (select * from @taxonomyFilter )
		BEGIN
		
			
		
			create table #taxmmap (taxonomyName varchar(250), taxonid int)
			insert into #taxmmap 
			select * from @taxonomyFilter 
			
			declare @name varchar(250)
			DECLARE db_cursor CURSOR FOR  
			SELECT distinct taxonomyname
			FROM @taxonomyfilter order by taxonomyname
			
			OPEN db_cursor  
			FETCH NEXT FROM db_cursor INTO  @name

			WHILE @@FETCH_STATUS = 0  
			BEGIN  
				   	select @where = case when @where is null then '' else @where  + ' AND ' END 
				   	+
				   	'  p.contentid in (select contentid from ' + case @islive when 1 then 'cgvTaxonRelation' else 'cgvTaxonRelationStaging' END + '  m inner join (select * from #taxmmap where taxonomyname = '''+@name+''' ) t on t.taxonomyname = m.taxonomyname and t.taxonid = m.taxonid   ) '
				   	
				   FETCH NEXT FROM db_cursor INTO @name  
			END  

			CLOSE db_cursor  
			DEALLOCATE db_cursor 
		
		
		END

	
	
	if @searchfilter is not NULL and @searchfilter <> ''
		select @where = case when @where is null then '' else @where  + ' AND ' END +  ' legacy_search_filter like ''%' +  @searchfilter + '%'''

	if @ExcludeSearchfilter is not NULL and @ExcludeSearchfilter <> ''
		select @where = case when @where is null then '' else @where  + ' AND ' END +  ' legacy_search_filter not like ''%' +  @Excludesearchfilter + '%'''

	if @language is not null
		select @where =  case when @where is null then '' else @where  + ' AND ' END + ' language = ''' + @language + ''''

	
	if @startdate is not null
		select @where =  case when @where is null then '' else @where  + ' AND ' END +  ' date_first_published  > =  ''' + convert(nvarchar(20), @startDate) + ''''

	if @Enddate is not null
		select @where = case when @where is null then '' else @where  + ' AND ' END +  ' date_first_published  <  ''' + convert(nvarchar(20), @EndDate) + ''''

	---SortOrder
	--
	--# Reverse Chronological (value = 2)
	--# Chronological (value = 1)
	--# Ascending Alphabetical by Title (value = 3)
	--# Descending Alphabetical by Title (value = 4)


	--1 posteddate
	--2 updateDate
	--4 reviewDate

	
	Select @orderby = case @ResultsSortOrder  
		when 1 then 
		' order by date , p.contentid' 
		when 2 then
		' order by date desc, p.contentid desc'
		when 3 then
		' order by long_title '
		when 4 then
		' order by long_title desc ' 
		when 5 then
		' order by sort_date desc, p.contentid desc ' 
		Else ' order by date desc, p.contentid desc'  END


	select @rowNumber = ', row_number() over (' + @orderby + ') as RowNumber '

	select @paging = ' where rowNumber >  ' + convert(nvarchar(10), (@startPage -1)*@recordsPerPage)  +
			' AND rowNumber < = ' + convert(nvarchar(10),@startPage *@recordsPerPage) 
		
		

	select @s = 
				'select * from (' +
				@select + char(13) + 
				@rowNumber + char(13) + 
				@from  + char(13) +  ' where ' + 
				@where + char(13) + ') p ' +
				@paging + char(13) +
				@orderby

	print @s


	select @scount = 'select count(*) ' +  @from  + char(13) +  ' where ' + @where 

	print @scount

	exec sp_executesql @scount

	exec sp_executesql @s

	

END


GO


grant execute on dbo.searchFilterKeywordDate to CDEuser