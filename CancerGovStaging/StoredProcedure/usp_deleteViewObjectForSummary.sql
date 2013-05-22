IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_deleteViewObjectForSummary]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_deleteViewObjectForSummary]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/**********************************************************************************

	Object's name:	usp_deleteViewObjectForSummary
	Object's type:	store proc
	Purpose:	delete view object for the summary
	Author:		11/30/2004	Lijia

**********************************************************************************/	
CREATE PROCEDURE [dbo].[usp_deleteViewObjectForSummary] 
	(
	@delObj uniqueidentifier  
	)
AS
BEGIN	

	
	DECLARE	@NCIViewObjectID uniqueidentifier,
		@NCIViewID 	uniqueidentifier,
		@return_status	int

	SELECT 	@NCIViewObjectID=NCIViewObjectID,
		@NCIViewID=NCIViewID
	FROM 	ViewObjects 
	WHERE 	ObjectID = @delObj
	
	IF @NCIViewObjectID IS NOT NULL AND @NCIViewID IS NOT NULL
	BEGIN
		BEGIN TRAN Tran_Delete
		EXEC @return_status= usp_deleteViewObject @NCIViewObjectID
		IF 	@return_status <> 0
		BEGIN
			RollBack TRAN Tran_Delete
			RAISERROR ( 80014, 16, 1)
			RETURN  
		END

		DELETE FROM prettyurl WHERE NCIViewID=@NCIViewID AND ObjectID=@delObj
		IF @@error>0
		BEGIN
			RollBack TRAN Tran_Delete
			RAISERROR ( 80014, 16, 1)
			RETURN  
		END
		COMMIT TRAN Tran_Delete
	END
END


GO
GRANT EXECUTE ON [dbo].[usp_deleteViewObjectForSummary] TO [gatekeeper_role]
GO
