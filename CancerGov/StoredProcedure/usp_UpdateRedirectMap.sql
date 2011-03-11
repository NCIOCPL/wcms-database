IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_UpdateRedirectMap]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_UpdateRedirectMap]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/**********************************************************************************

	Object's name:	usp_UpdateRedirectMap
	Object's type:	Stored procedure
	Purpose:	Get current URL
	
	Change History:
	9/21/2004	Lijia Chu	

**********************************************************************************/


CREATE PROCEDURE dbo.usp_UpdateRedirectMap
       	@OldURL VARCHAR(512),
	@Source VARCHAR(20)
AS


SET NOCOUNT OFF


BEGIN TRAN Tran_UpdateRedirectMap

UPDATE	RedirectMap
SET 	hitNum = hitNum + 1
WHERE	OldUrl=@oldUrl
AND	Source=@Source

IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN  Tran_UpdateRedirectMap
		RETURN 1
	END

Commit TRAN Tran_UpdateRedirectMap
RETURN 0



GO
GRANT EXECUTE ON [dbo].[usp_UpdateRedirectMap] TO [websiteuser_role]
GO
