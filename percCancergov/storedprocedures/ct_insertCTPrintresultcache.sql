if object_id('ct_insertPrintresultcache') is not NULL
	drop procedure dbo.ct_insertPrintresultcache
go

create procedure dbo.ct_insertPrintresultcache
(@content nvarchar(max), @searchparams nvarchar(max), @trialids udt_trialids READONLY, @printid uniqueidentifier output, @islive bit = 1)
AS
BEGIN
set nocount on
declare @pid table(printid uniqueidentifier)

	insert into dbo.ctPrintResultCache(content, searchparams, islive)
	OUTPUT inserted.printid
	INTO @pid
	values(@content, @searchparams, @islive)

	select top 1 @printid = printid from @pid

	insert into dbo.ctprintresult(printid, trialid)
	select @printid, trialid
	from @trialids 

	return
END
Go
grant execute on dbo.ct_insertPrintResultCache to CDEUSER
GO
