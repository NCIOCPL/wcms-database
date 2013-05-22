IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[protocolsearchResultViewCache]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[protocolsearchResultViewCache]
GO
create view dbo.protocolsearchResultViewCache
as 

select * from cdrlivect.dbo.protocolsearchResultViewCache 


GO
