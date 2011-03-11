IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[ProtocolAlternateID]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[ProtocolAlternateID]
GO

/****** Object:  VIEW [dbo].[ProtocolAlternateID]    Script Date: 10/8/2001 11:57:35 PM ******/
CREATE VIEW [dbo].[ProtocolAlternateID] AS 
SELECT 
	[ProtocolID],
	[AlternateID]  ,
	[Type],
	[CodeKey]  ,
	[Comments]  ,
	[UpdateDate]  ,
	[UpdateUserID]  
FROM CancerGov..[ProtocolAlternateID]

GO
