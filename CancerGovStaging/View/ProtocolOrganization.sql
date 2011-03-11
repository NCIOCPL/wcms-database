IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[ProtocolOrganization]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[ProtocolOrganization]
GO

/****** Object:  VIEW [dbo].[ProtocolOrganization]    Script Date: 10/8/2001 11:57:35 PM ******/
CREATE VIEW [dbo].[ProtocolOrganization] AS 
SELECT 
	[ProtocolOrgID],
	[ProtocolID],
	[OrganizationID],
	[OrganizationRoleID],
	[Type]  ,
	[StatusID]  ,
	[SattusDate]  ,
	[ParentProtocolOrgID]  ,
	[Comments],
	[ProtocolAffiliatedID]  ,
	[UpdateDate]  ,
	[UpdateUserID]  ,
	[SourceID]  ,
	[DataSource]  
FROM CancerGov..[ProtocolOrganization]

GO
