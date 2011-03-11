drop function dbo.Mig_isSpanish
go
create function dbo.Mig_isSpanish(@nciviewid uniqueidentifier)
returns bit
as
BEGIN
	declare @r varchar(80), @r1 bit
	select @r = propertyvalue from viewproperty
	where propertyname = 'isSpanishContent' and nciviewid = @nciviewid 
	if @r = 'yes'
		select @r1 = 1

return @r1
END
GO
drop procedure dbo.Mig_getTranslation
go
create procedure dbo.Mig_getTranslation
as
BEGIN

	select distinct a.english, m.[page content type] as EnglishContentType, a.spanish, m1.[page content type]  as SpanishContentType
	from
		(
		select propertyvalue as English,nciviewid as spanish from viewproperty
		where propertyname = 'otherlanguageviewid'
		and dbo.Mig_isSpanish(nciviewid) =1
		union
		select nciviewid as English, propertyvalue as Spanish from viewproperty
		where propertyname = 'otherlanguageviewid'
		and dbo.Mig_isSpanish(propertyvalue) =1
		)a 
		inner join migmap m on a.english = m.nciviewid 
		inner join migmap m1 on a.spanish = m1.nciviewid
		where m.[page content type] <> 'rffNavOn'
				and m1.[page content type] <> 'rffNavOn'
END
GO
