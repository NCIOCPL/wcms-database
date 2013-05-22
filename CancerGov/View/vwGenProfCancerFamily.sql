IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[vwGenProfCancerFamily]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[vwGenProfCancerFamily]
GO

--vwGenProfCancerFamily
CREATE VIEW [dbo].[vwGenProfCancerFamily] 
AS 

SELECT	DISTINCT Syndrome AS CancerFamily
FROM 	CancerGov..GenProfAreasOfSpecialization

GO
