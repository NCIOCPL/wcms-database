
drop procedure dbo.ct_cleanprintresultcache
go
create procedure dbo.ct_cleanprintresultcache
as
BEGIN

	delete from dbo.ctprintresult 
	where printid in (select printid from dbo.ctprintresultcache where cachedate < dateadd(d,-90,getdate()))

	delete from dbo.ctPrintResultCache 
	where cachedate < dateadd(d,-90,getdate())


END

