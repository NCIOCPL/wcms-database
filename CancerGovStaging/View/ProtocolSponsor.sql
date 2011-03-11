IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[ProtocolSponsor]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[ProtocolSponsor]
GO

/****** Object:  VIEW [dbo].[ProtocolSponsor]    Script Date: 10/8/2001 11:57:35 PM ******/
CREATE VIEW [dbo].[ProtocolSponsor] AS 
SELECT 
	[ProtocolID],
	[SponsorID],
	[UpdateDate]  ,
	[UpdateUserID]  
FROM CancerGov..[ProtocolSponsor]

GO
