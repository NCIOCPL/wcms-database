IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[OrganizationRole]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[OrganizationRole]
GO

/****** Object:  VIEW [dbo].[OrganizationRole]    Script Date: 10/8/2001 11:57:34 PM ******/
CREATE VIEW [dbo].[OrganizationRole] AS 
SELECT 
	[OrganizationRoleID],
	[Type]  ,
	[Name],
	[ShortName],
	[UpdateDate]  ,
	[UpdateUserID]  ,
	[SourceID]  ,
	[DataSource]  
FROM CancerGov..[OrganizationRole]

GO
