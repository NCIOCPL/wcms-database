IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[LiteratureCitation]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[LiteratureCitation]
GO

/****** Object:  VIEW [dbo].[LiteratureCitation]    Script Date: 10/8/2001 11:57:34 PM ******/
CREATE VIEW [dbo].[LiteratureCitation] AS 
SELECT 
	[LiteratureCitationID],
	[Type],
	[Title]  ,
	[SearchTitle],
	[Author],
	[PublicationInfo],
	[Annotation],
	[ParentLiteratureCitationID]  ,
	[CancerLitID]  ,
	[DateAbstractRequested]  ,
	[DateAbstractReceived]  ,
	[RequestAbstract] ,
	[UpdateDate]  ,
	[UpdateUserID]  ,
	[SourceID]  ,
	[DataSource]  
FROM CancerGov..[LiteratureCitation]

GO
