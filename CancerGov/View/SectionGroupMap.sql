IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[SectionGroupMap]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[SectionGroupMap]
GO

CREATE VIEW [dbo].[SectionGroupMap] 
AS

SELECT 	SectionID,
	GroupID,
	CreateDate,
	UpdateUserID,
	UpdateDate
FROM  	[CancerGovStaging].[dbo].[SectionGroupMap] 

GO
