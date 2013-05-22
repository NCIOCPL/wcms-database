IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[TermType]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[TermType]
GO

/****** Object:  VIEW [dbo].[TermType]    Script Date: 10/8/2001 11:57:36 PM ******/
CREATE VIEW [dbo].[TermType] AS 
SELECT 
	[TermID],
	[Type],
	[TypeOfType],
	[UpdateDate]  ,
	[UpdateUserID]  
FROM CancerGov..[TermType]

GO
