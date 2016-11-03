if object_id('taxonomy_getMonthlyAgg') is not null
	drop procedure dbo.taxonomy_getMonthlyAgg
GO

create procedure dbo.taxonomy_getMonthlyAgg (@searchFilter varchar(900), @numberofPreviousYears smallint , @isLive bit =1)
as
BEGIN
declare @i smallint
declare @y table (y smallint)
declare @m table(m smallint)
select @i = 1
while @i <13
	BEGIN
		insert into @m
			select @i
		select @i+=1
	END

select @i= 0 - @numberofPreviousYears 
while @i <1
	BEGIN
		insert into @y
			select datepart(year, dateadd(year, @i,  getdate()))
		select @i+=1
	END


if @isLive =1 
	select y as year,m as month,   count(b.legacy_search_filter) as total
	from  @y t cross join @m m  
	left outer join cgvPageSearch  b on datepart(year, b.date) = t.y and datepart( month, b.[date]) = m.m
	and legacy_search_filter in (select * from [dbo].[udf_StringSplit](@searchFilter,',') )
	where (t.y < datepart(year, getdate()) or (t.y = datepart(year, getdate()) and  m.m <= datepart(month, getdate())))
	group by y,m
	order by 1 desc,2 desc
else 
	select y as year,m as month,   count(b.legacy_search_filter) as total
	from  @y t cross join @m m  
	left outer join cgvStagingPageSearch  b on datepart(year, b.date) = t.y and datepart( month, b.[date]) = m.m
	and legacy_search_filter in (select * from [dbo].[udf_StringSplit](@searchFilter,',') )
	where (t.y < datepart(year, getdate()) or (t.y = datepart(year, getdate()) and  m.m <= datepart(month, getdate())))
	group by y,m
	order by 1 desc,2 desc

END

GO
Grant execute on dbo.taxonomy_getMonthlyAgg to CDEuser