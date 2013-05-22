IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[TermAncestor]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[TermAncestor]
GO

/****** Object:  VIEW [dbo].[TermAncestor]    Script Date: 10/8/2001 11:57:35 PM ******/
CREATE VIEW [dbo].[TermAncestor] AS 
SELECT 
	[TermID],
	[AncestorID],
	[ProductTypeID],
	[AncestorLevel]  ,
	[UpdateDate]  ,
	[UpdateUserID]  
FROM CancerGov..[TermAncestor]

GO
