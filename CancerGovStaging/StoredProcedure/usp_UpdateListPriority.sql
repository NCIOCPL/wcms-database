IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_UpdateListPriority]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_UpdateListPriority]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.usp_UpdateNCIView   Owner:Jhe Purpose: For admin side Script Date: 1/15/2002 16:00:49 pm ******/		
					
					
CREATE PROCEDURE dbo.usp_UpdateListPriority
(
	@Priority		int,
	@ListID	UniqueIdentifier
)
AS
	SET NOCOUNT OFF;


	
	UPDATE List
	SET 	Priority = @Priority 
	WHERE ListID = @ListID
	IF (@@ERROR <> 0)
	BEGIN
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	RETURN 0
GO
GRANT EXECUTE ON [dbo].[usp_UpdateListPriority] TO [webadminuser_role]
GO
