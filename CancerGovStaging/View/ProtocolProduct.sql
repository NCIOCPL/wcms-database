IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[ProtocolProduct]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[ProtocolProduct]
GO

/****** Object:  VIEW [dbo].[ProtocolProduct]    Script Date: 10/8/2001 11:57:35 PM ******/
CREATE VIEW [dbo].[ProtocolProduct] AS 
SELECT 
	[ProtocolID],
	[ProductType],
	[ScopeType],
	[IsIncluded]   ,
	[ReleaseDate]  ,
	[NewDate]  
FROM CancerGov..[ProtocolProduct]

GO
