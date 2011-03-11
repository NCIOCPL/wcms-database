IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[Citation]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[Citation]
GO

/****** Object:  VIEW [dbo].[Citation]    Script Date: 10/8/2001 11:57:34 PM ******/
CREATE VIEW [dbo].[Citation] AS 
SELECT 
	[CitationID],
	[Type],
	[StatusID],
	[CitedEntityID]  ,
	[UpdateDate]  ,
	[UpdateUserID]  ,
	[SourceID]  ,
	[DataSource]  
FROM CancerGov..[Citation]

GO
