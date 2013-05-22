IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[UserGroupPermissionMap]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[UserGroupPermissionMap]
GO

CREATE VIEW [dbo].[UserGroupPermissionMap]
AS

SELECT 	creationDate,
	creationUser,
	groupID,
	permissionID,
	UpdateDate,
	UpdateUserID,
	userID
FROM  	[CancerGovStaging].[dbo].[UserGroupPermissionMap]

GO
