IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[ProtocolOrganizationPerson]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[ProtocolOrganizationPerson]
GO

/****** Object:  VIEW [dbo].[ProtocolOrganizationPerson]    Script Date: 10/8/2001 11:57:35 PM ******/
CREATE VIEW [dbo].[ProtocolOrganizationPerson] AS 
SELECT 
	[ProtocolOrgID],
	[PersonID],
	[PersonOrgRole],
	[UpdateDate]  ,
	[UpdateUserID]  ,
	[DataSource]  
FROM CancerGov..[ProtocolOrganizationPerson]

GO
