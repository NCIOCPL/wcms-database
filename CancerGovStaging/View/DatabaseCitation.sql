IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DatabaseCitation]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[DatabaseCitation]
GO

/****** Object:  VIEW [dbo].[DatabaseCitation]    Script Date: 10/8/2001 11:57:34 PM ******/
CREATE VIEW [dbo].[DatabaseCitation] AS 
SELECT 
	[DatabaseCitationID],
	[Type]  ,
	[DatabaseName],
	[Author],
	[ParentDatabaseCitationID]  ,
	[LastRevisedDate]  ,
	[UpdateDate]  ,
	[UpdateUserID]  ,
	[SourceID]  ,
	[DataSource]  
FROM CancerGov..[DatabaseCitation]

GO
