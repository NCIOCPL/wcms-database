use PercCancerGov
GO
if OBJECT_ID('getFirst2Paragraph')	is not null
	drop function dbo.getFirst2Paragraph
go
create function dbo.getFirst2Paragraph(@b nvarchar(max))
returns nvarchar(max)
as
BEGIN
	
	declare @p0 int, @p1 int, @p2 int, @s nvarchar(max)
	select @p1 = CHARINDEX('</p>', @b)
	if @p1 <= 0
		select @s = ''
	 ELSE
		BEGIN
			select @p0 = CHARINDEX('<p>', @b)
			select @p2 = CHARINDEX('</p>', substring(@b, @p1 + 4 , 9999999))
			if @p2 > 0 
				select @s = SUBSTRING(@b,@p0 , @p1 + @P2 + 7- @p0)
				ELSE
					select @s= SUBSTRING(@b,  @p0,  @p1 + @P2 + 5- @p0)	
		END
		
	return @s

END