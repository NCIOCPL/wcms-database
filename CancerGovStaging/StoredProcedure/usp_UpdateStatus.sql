IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_UpdateStatus]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_UpdateStatus]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.usp_UpdateNCIView   Owner:Jhe Purpose: For admin side Script Date: 1/15/2002 16:00:49 pm ******/		
					
					
CREATE PROCEDURE dbo.usp_UpdateStatus
(
	@NCIViewID		UniqueIdentifier
)
AS
	SET NOCOUNT OFF;


	Update NCIView
	set 	Status =		'EDIT',
		UpdateDate	= getdate()
	where NCIViewID = @NCIViewID
	IF (@@ERROR <> 0)
	BEGIN
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 


	RETURN 0
GO
GRANT EXECUTE ON [dbo].[usp_UpdateStatus] TO [webadminuser_role]
GO
