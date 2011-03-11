IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[protocolsearch]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[protocolsearch]
GO
create view dbo.protocolsearch
as 

select * from cdrlivect.dbo.protocolsearch 

GO
