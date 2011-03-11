IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_UpdateNCIObjectPriority]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_UpdateNCIObjectPriority]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



--***********************************************************************
-- Create New Object 
--************************************************************************
/****** Object:  Stored Procedure dbo.usp_UpdateNCIView   Owner:Jhe Purpose: For admin side Script Date: 1/15/2002 16:00:49 pm ******/		
					
					
CREATE PROCEDURE dbo.usp_UpdateNCIObjectPriority
(
	@Priority		int,
	@ObjectInstanceID	UniqueIdentifier
)
AS
	SET NOCOUNT OFF;


	BEGIN TRAN Tran_DeleteList

	UPDATE NCIObjects
	SET 	Priority = @Priority 
	WHERE ObjectInstanceID = @ObjectInstanceID
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN  Tran_DeleteList
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	Update NCIView
	set 	Status =		'EDIT',
		UpdateDate	= getdate()
	where NCIViewID = (select nciviewid from viewobjects where type ='InfoBox' and objectID =
		(select parentnciobjectID from nciobjects where objectinstanceID = @ObjectInstanceID)
	)
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN  Tran_DeleteList
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	Commit TRAN Tran_DeleteList
	RETURN 0

GO
GRANT EXECUTE ON [dbo].[usp_UpdateNCIObjectPriority] TO [webadminuser_role]
GO
