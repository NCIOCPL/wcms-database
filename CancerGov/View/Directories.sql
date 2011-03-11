IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[Directories]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[Directories]
GO

CREATE VIEW [dbo].[Directories] 
AS

SELECT 	DirectoryID,
	DirectoryName,
	CreateDate,
	UpdateUserID,
	UpdateDate
FROM  	[CancerGovStaging].[dbo].[Directories] 


GO
