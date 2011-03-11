IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[Permissions]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[Permissions]
GO

CREATE VIEW [dbo].[Permissions]
AS

SELECT 	creationDate,
	creationUser,
	permissionID,
	permissionName,
	permssionDescription,
	UpdateDate,
	UpdateUserID
FROM  	[CancerGovStaging].[dbo].[Permissions]

GO
