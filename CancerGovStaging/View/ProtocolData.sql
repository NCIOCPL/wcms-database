IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[ProtocolData]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[ProtocolData]
GO

/****** Object:  VIEW [dbo].[ProtocolData]    Script Date: 10/8/2001 11:57:35 PM ******/
CREATE VIEW [dbo].[ProtocolData] AS 
SELECT 
	[ProtocolID],
	[Type],
	[Status],
	[StatusDate]  ,
	[FileName]  ,
	[Data] ,
	[DataSize]  ,
	[IsLoaded]   ,
	[UpdateDate]  ,
	[UpdateUserID]  
FROM CancerGov..[ProtocolData]

GO
