IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[protocolsearchcontactcache]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[protocolsearchcontactcache]
GO
create view dbo.protocolsearchcontactcache
as 

select * from cdrlivect.dbo.protocolsearchcontactcache 


GO
