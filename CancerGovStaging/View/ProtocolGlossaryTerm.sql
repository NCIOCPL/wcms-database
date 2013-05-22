IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[ProtocolGlossaryTerm]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[ProtocolGlossaryTerm]
GO

/****** Object:  VIEW [dbo].[ProtocolGlossaryTerm]    Script Date: 10/8/2001 11:57:35 PM ******/
CREATE VIEW [dbo].[ProtocolGlossaryTerm] AS 
SELECT 
	[ProtocolID],
	[GlossaryTermID],
	[AbstractText],
	[UpdateDate]  ,
	[UpdateUserID]  
FROM CancerGov..[ProtocolGlossaryTerm]

GO
