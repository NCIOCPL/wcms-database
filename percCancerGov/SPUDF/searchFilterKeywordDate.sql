if object_id('searchFilterKeywordDate') is not NULL
	drop procedure dbo.searchFilterKeywordDate
go
create procedure dbo.searchFilterKeywordDate
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
@isLive bit = 1
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

	select @select = 'select top ' + convert(nvarchar(20), @maxResults)  
		+' * '
		
	-- staging or live
	
	if @islive = 1
			select @from =  ' from   dbo.cgvPageSearch  '  
		ELSE
			select @from =  ' from  dbo.cgvStagingPageSearch '  

	if @keyword is not NULL
			select @from = @from + ' p inner join dbo.udf_stringSplit(''' + 
				@keyword + ''', '' '') a on p.meta_keywords like ''%''+ a.objectid + ''%''  ' 
	
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

	--1 posteddate	--2 updateDate	--4 reviewDate
	
	Select @orderby = case @ResultsSortOrder  
		when 1 then 
		' order by date ' 
		when 2 then
		' order by date desc'
		when 3 then
		' order by long_title '
		when 4 then
		' order by long_title desc ' 
		Else ' order by date desc'  END


	select @rowNumber = ', row_number() over (' + @orderby + ') as RowNumber '

	select @paging = ' where rowNumber >  ' + convert(nvarchar(10), (@startPage -1)*@recordsPerPage)  +
			' AND rowNumber < = ' + convert(nvarchar(10),@startPage *@recordsPerPage) 
		
		

	select @s = 
				'select * from (' +
				@select + char(13) + 
				@rowNumber + char(13) + 
				@from  + char(13) +  ' where ' + 
				@where + char(13) + ') a ' +
				@paging + char(13) +
				@orderby

	print @s


	select @scount = 'select count(*) ' +  @from  + char(13) +  ' where ' + @where 

	print @scount

	exec sp_executesql @scount

	exec sp_executesql @s

	

END
GO

Grant execute on dbo.searchFilterKeywordDate to CDEUser

