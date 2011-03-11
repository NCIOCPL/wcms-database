IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_UpdatePriority]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_UpdatePriority]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.usp_UpdateNCIView   Owner:Jhe Purpose: For admin side Script Date: 1/15/2002 16:00:49 pm ******/		
					
					
CREATE PROCEDURE dbo.usp_UpdatePriority
(
	@Priority		int,
	@NCIViewObjectID	UniqueIdentifier
)
AS
	SET NOCOUNT OFF;


	BEGIN TRAN Tran_DeleteList

	UPDATE ViewObjects 
	SET 	Priority = @Priority 
	WHERE NCIViewObjectID = @NCIViewObjectID
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN  Tran_DeleteList
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	Update NCIView
	set 	Status =		'EDIT',
		UpdateDate	= getdate()
	where NCIViewID = (select nciviewid from viewobjects where nciviewobjectid =@NCIViewObjectID)
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN  Tran_DeleteList
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	Commit TRAN Tran_DeleteList
	RETURN 0
GO
GRANT EXECUTE ON [dbo].[usp_UpdatePriority] TO [webadminuser_role]
GO
