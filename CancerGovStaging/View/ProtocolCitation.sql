IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[ProtocolCitation]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[ProtocolCitation]
GO

/****** Object:  VIEW [dbo].[ProtocolCitation]    Script Date: 10/8/2001 11:57:35 PM ******/
CREATE VIEW [dbo].[ProtocolCitation] AS 
SELECT 
	[ProtocolID],
	[CitationID],
	[CitationType],
	[UpdateDate]  ,
	[UpdateUserID]  
FROM CancerGov..[ProtocolCitation]

GO
