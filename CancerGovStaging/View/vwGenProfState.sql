IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[vwGenProfState]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[vwGenProfState]
GO
/*	NCI - National Cancer Institute
*	
*	Purpose:	
*
*	Objects Used:
*
*	Change History:
*	?/?/2001 	Alex Pidlisnyy	Script Created
*	2/26/2002 	Alex Pidlisnyy	Remove databse prefix "CancerGov.."
*
*/

--vwGenProfState
CREATE VIEW [dbo].[vwGenProfState] 
AS 

SELECT	DISTINCT PL.State AS StateAbbr, 
	S.ShortName +' - '+ S.[Name] AS [Name]
FROM 	GenProfPracticeLocations AS PL 
	INNER JOIN State AS S
		ON PL.State = S.ShortName
WHERE 	State IS NOT NULL

/*
old version
SELECT	DISTINCT PL.State AS StateAbbr, S.ShortName +' - '+ S.[Name] AS [Name]
FROM 	CancerGov..GenProfPracticeLocations AS PL INNER JOIN CancerGov..State AS S
	ON PL.State = S.ShortName
WHERE 	State IS NOT NULL
*/


GO
