IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[protocolsearchsyscache]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[protocolsearchsyscache]
GO
create view dbo.protocolsearchsyscache
as 

select * from cdrlivect.dbo.protocolsearchsyscache 

GO
