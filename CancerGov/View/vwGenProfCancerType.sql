IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[vwGenProfCancerType]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[vwGenProfCancerType]
GO
--vwGenProfCancerType
CREATE VIEW [dbo].[vwGenProfCancerType] 
AS 

SELECT	[ID], [Name]
FROM CancerGov..GenProfCancerTypeSite

GO
