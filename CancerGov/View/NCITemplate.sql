IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[NCITemplate]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[NCITemplate]
GO

CREATE VIEW [dbo].[NCITemplate]
AS

SELECT 	AddURL,
	[Description],
	EditURL,
	[Name],
	[NCITemplateID],
	UpdateDate,
	UpdateUserID,
	URL
FROM  	[CancerGovStaging].[dbo].[NCITemplate]

GO
