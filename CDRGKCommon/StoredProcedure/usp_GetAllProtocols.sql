IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetAllProtocols]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetAllProtocols]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/**********************************************************************************

	Object's name:	usp_GetAllProtocols
	Object's type:	Stored procedure
	Purpose:	Get Pretty Url
	
	Change History:


**********************************************************************************/


CREATE PROCEDURE dbo.usp_GetAllProtocols

AS

SELECT 	ProtocolID, 
	PrimaryProtocolID 
FROM	dbo.Protocoldetail

	


GO
GRANT EXECUTE ON [dbo].[usp_GetAllProtocols] TO [websiteuser_role]
GO
