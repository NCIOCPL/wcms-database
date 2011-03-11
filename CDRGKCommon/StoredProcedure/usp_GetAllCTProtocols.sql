IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetAllCTProtocols]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetAllCTProtocols]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/**********************************************************************************

	Object's name:	usp_GetAllCTProtocols
	Object's type:	Stored procedure
	
	
	Change History:
	

**********************************************************************************/


CREATE PROCEDURE dbo.usp_GetAllCTProtocols

AS

SELECT 	ProtocolID, 
	IDstring
FROM 	dbo.ProtocolAlternateID pa inner join dbo.AlternateIDType a on pa.idtypeid = a.idtypeID
WHERE 	IDType = 'NCTID'


GO
GRANT EXECUTE ON [dbo].[usp_GetAllCTProtocols] TO [websiteuser_role]
GO
