if OBJECT_ID('TaxonomySplit') is not null
	drop function dbo.TaxonomySplit
go 
create function dbo.TaxonomySplit (@s varchar(1000))
returns @r table
(taxonomyName varchar(250), taxonid int
)
AS
BEGIN
	if CHARINDEX(':', @s ) = 0 
	return 
	
	insert into @r 
	select  left(s.objectid, CHARINDEX(':', s.objectid)-1)
	, s2.objectid 
	from dbo.udf_StringSplit(@s, ';') s 
	cross apply dbo.udf_StringSplit(right(s.objectid, LEN(s.objectid)- CHARINDEX(':', s.objectid)), ',') s2

	return  
END
go
