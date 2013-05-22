IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[ProtocolType]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[ProtocolType]
GO

/****** Object:  VIEW [dbo].[ProtocolType]    Script Date: 10/8/2001 11:57:35 PM ******/
CREATE VIEW [dbo].[ProtocolType] AS 
SELECT 
	[ProtocolID],
	[Type],
	[ProductID],
	[TypeScopeID],
	[UpdateDate]  ,
	[UpdateUserID]  
FROM CancerGov..[ProtocolType]

GO
