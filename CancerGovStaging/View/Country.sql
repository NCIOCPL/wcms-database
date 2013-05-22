IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[Country]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[Country]
GO

/****** Object:  VIEW [dbo].[Country]    Script Date: 10/8/2001 11:57:34 PM ******/
CREATE VIEW [dbo].[Country] AS 
SELECT 
	[CountryID],
	[Name],
	[ShortName],
	[UpdateDate]  ,
	[UpdateUserID]  ,
	[SourceID]  ,
	[DataSource]  
FROM CancerGov..[Country]

GO
