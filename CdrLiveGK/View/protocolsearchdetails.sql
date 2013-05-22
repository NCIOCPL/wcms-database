IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[protocolsearchdetails]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[protocolsearchdetails]
GO
create view dbo.protocolsearchdetails
as 

select * from cdrlivect.dbo.protocolsearchdetails 

GO
