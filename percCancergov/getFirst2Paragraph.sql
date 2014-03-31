use PercCancerGov
GO
if OBJECT_ID('getFirst2Paragraph')	is not null
	drop function dbo.getFirst2Paragraph
go
create function dbo.getFirst2Paragraph(@xml xml)
returns nvarchar(max)
as
BEGIN
	
	return isnull(convert(nvarchar(max) , @xml.query('(/p)[1]')),'') + isnull(convert(nvarchar(max), @xml.query('(/p)[2]') ),'')

	
		
	

END