IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[vwGenProfCancerType]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[vwGenProfCancerType]
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

--vwGenProfCancerType
CREATE VIEW [dbo].[vwGenProfCancerType] 
AS 

SELECT	[ID], [Name]
FROM GenProfCancerTypeSite


GO
