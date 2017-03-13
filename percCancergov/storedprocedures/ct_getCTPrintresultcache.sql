if object_id('ct_getPrintResultCache') is not NULL
	drop procedure dbo.ct_getPrintResultCache
GO
Create procedure dbo.ct_getPrintResultCache(@printid uniqueidentifier, @islive bit = 1)
AS
BEGIN
	set nocount on 
	select top 1 content from dbo.ctPrintResultCache where printid = @printid and islive = @isLive
END
GO
Grant execute on dbo.ct_getPrintResultCache to CDEUser
GO

