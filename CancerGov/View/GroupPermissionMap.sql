IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[GroupPermissionMap]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[GroupPermissionMap]
GO

CREATE VIEW [dbo].[GroupPermissionMap]
AS

SELECT 	creationDate,
	creationUser,
	groupID,
	permissionID,
	UpdateDate,
	UpdateUserID
FROM  	[CancerGovStaging].[dbo].[GroupPermissionMap]

GO
