IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[ProtocolStatusHistory]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[ProtocolStatusHistory]
GO

/****** Object:  VIEW [dbo].[ProtocolStatusHistory]    Script Date: 10/8/2001 11:57:35 PM ******/
CREATE VIEW [dbo].[ProtocolStatusHistory] AS 
SELECT 
	[ProtocolID],
	[StatusID],
	[StatusDate]  ,
	[Comments]  ,
	[UpdateDate]  ,
	[UpdateUserID]  
FROM CancerGov..[ProtocolStatusHistory]

GO
