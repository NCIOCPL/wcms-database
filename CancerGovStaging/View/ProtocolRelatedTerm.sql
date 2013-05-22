IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[ProtocolRelatedTerm]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[ProtocolRelatedTerm]
GO

/****** Object:  VIEW [dbo].[ProtocolRelatedTerm]    Script Date: 10/8/2001 11:57:35 PM ******/
CREATE VIEW [dbo].[ProtocolRelatedTerm] AS 
SELECT 
	[ProtocolID],
	[TermID],
	[RelationTypeID],
	[ProductID]  ,
	[UpdateDate]  ,
	[UpdateUserID]  
FROM CancerGov..[ProtocolRelatedTerm]

GO
