IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[State]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[State]
GO

/****** Object:  VIEW [dbo].[State]    Script Date: 10/8/2001 11:57:35 PM ******/
CREATE VIEW [dbo].[State] AS 
SELECT 
	[StateID],
	[CountryID]  ,
	[Name],
	[ShortName],
	[UpdateDate]  ,
	[UpdateUserID]  ,
	[SourceID]  ,
	[DataSource]  
FROM CancerGov..[State]

GO
