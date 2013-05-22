IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[vwGenProfCancerFamily]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[vwGenProfCancerFamily]
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
--vwGenProfCancerFamily
CREATE VIEW [dbo].[vwGenProfCancerFamily] 
AS 

SELECT	DISTINCT Syndrome AS CancerFamily
FROM 	GenProfAreasOfSpecialization


GO
