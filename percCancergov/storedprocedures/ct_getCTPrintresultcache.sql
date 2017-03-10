if object_id('ct_getPrintResultCache') is not NULL
	drop procedure dbo.ct_getPrintResultCache
GO
Create procedure dbo.ct_getPrintResultCache(@printid uniqueidentifier)
AS
BEGIN
	select top 1 content from dbo.ctPrintResultCache where printid = @printid 
END
GO
Grant execute on dbo.ct_getPrintResultCache to CDEUser
GO

