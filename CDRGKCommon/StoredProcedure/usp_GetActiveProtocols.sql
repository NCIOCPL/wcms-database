IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetActiveProtocols]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetActiveProtocols]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/**********************************************************************************

	Object's name:	usp_GetActiveProtocols
	Object's type:	Stored procedure
	Purpose:	Get Active Protocols list
	 
	Change History:
	

**********************************************************************************/


CREATE PROCEDURE dbo.usp_GetActiveProtocols

AS

SELECT	P.ProtocolID, 
	P.CurrentStatus, 
	ISNULL(P.PatientTitle, P.HealthProfessionalTitle) As PatientTitle,
	P.HealthProfessionalTitle 
FROM 	dbo.Protocoldetail P 
Inner Join dbo.Document D 
ON 	P.ProtocolID = D.DocumentID 
WHERE 	D.IsActive =1 
ORDER BY P.ProtocolID

	


GO
GRANT EXECUTE ON [dbo].[usp_GetActiveProtocols] TO [websiteuser_role]
GO
