IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[NCIUsers]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[NCIUsers]
GO

CREATE VIEW [dbo].[NCIUsers]
AS

SELECT 	email
	lastVisit,
	loginName,
	nSessions,
	password,
	registrationDate,
	secontToLastVist,
	UpdateDate,
	UpdateUserID,
	userID
FROM  	[CancerGovStaging].[dbo].[NCIUsers]

GO
