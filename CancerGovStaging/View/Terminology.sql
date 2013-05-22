IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[Terminology]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[Terminology]
GO

/****** Object:  VIEW [dbo].[Terminology]    Script Date: 10/8/2001 11:57:36 PM ******/
CREATE VIEW [dbo].[Terminology] AS 
SELECT 
	[TermID],
	[StatusID],
	[StatusDate]  ,
	[Name],
	[ShortName]  ,
	[Acronym]  ,
	[Definition]  ,
	[UpdateDate]  ,
	[UpdateUserID]  ,
	[SourceID]  ,
	[DataSource]  
FROM CancerGov..[Terminology]

GO
