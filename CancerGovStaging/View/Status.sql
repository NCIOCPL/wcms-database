IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[Status]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[Status]
GO

/****** Object:  VIEW [dbo].[Status]    Script Date: 10/8/2001 11:57:35 PM ******/
CREATE VIEW [dbo].[Status] AS 
SELECT 
	[StatusID],
	[Type],
	[Name],
	[ShortName],
	[Description],
	[UpdateDate]  ,
	[UpdateUserID]  ,
	[SourceID]  ,
	[DataSource]  
FROM CancerGov..[Status]

GO
