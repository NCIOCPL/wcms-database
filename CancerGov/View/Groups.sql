IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[Groups]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[Groups]
GO
CREATE VIEW [dbo].[Groups]
AS

SELECT 	adminEmail,
	creationDate,
	creationUser,
	GroupID,
	groupIDName,
	groupName,
	isActive,
	parentGroupId,
	typeID,
	UpdateDate,
	UpdateUserID
FROM  	[CancerGovStaging].[dbo].[Groups]

GO
