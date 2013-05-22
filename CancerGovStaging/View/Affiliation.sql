IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[Affiliation]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[Affiliation]
GO

/****** Object:  VIEW [dbo].[Affiliation]    Script Date: 10/8/2001 11:57:33 PM ******/
CREATE VIEW [dbo].[Affiliation] AS 
SELECT 
	[AffiliationID],
	[PersonID],
	[OrganizationID],
	[Type],
	[Title],
	[UpdateDate]  ,
	[UpdateUserID]  ,
	[SourceID]  ,
	[DataSource]  
FROM CancerGov..[Affiliation]

GO
