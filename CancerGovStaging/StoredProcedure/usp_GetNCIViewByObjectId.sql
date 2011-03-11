IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetNCIViewByObjectId]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetNCIViewByObjectId]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/**********************************************************************************

	Object's name:	usp_GetNCIViewByObjectId
	Object's type:	Stored procedure
	Purpose:	Get NCIView by Object ID
	
	Change History:
	10/13/2004	Lijia Chu	

**********************************************************************************/


CREATE PROCEDURE dbo.usp_GetNCIViewByObjectId
	@docGuid	uniqueidentifier
AS

SELECT TOP 1 NCIViewID 
FROM 	ViewObjects 
WHERE 	ObjectID = @docguid



	


GO
GRANT EXECUTE ON [dbo].[usp_GetNCIViewByObjectId] TO [gatekeeper_role]
GO
GRANT EXECUTE ON [dbo].[usp_GetNCIViewByObjectId] TO [websiteuser_role]
GO
