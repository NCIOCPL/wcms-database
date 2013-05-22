IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[vwGenProfState]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[vwGenProfState]
GO

--vwGenProfState
CREATE VIEW [dbo].[vwGenProfState] 
AS 

SELECT	DISTINCT PL.State AS StateAbbr, S.ShortName +' - '+ S.[Name] AS [Name]
FROM 	CancerGov..GenProfPracticeLocations AS PL INNER JOIN CancerGov..State AS S
	ON PL.State = S.ShortName
WHERE 	State IS NOT NULL

GO
