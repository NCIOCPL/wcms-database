IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_DeleteNCIObjectProperty]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_DeleteNCIObjectProperty]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--***********************************************************************
-- Create New Object 
--************************************************************************


CREATE PROCEDURE dbo.usp_DeleteNCIObjectProperty
(
	@ObjectInstanceID	UniqueIdentifier,
	@PropertyName		VarChar(50),
	@UpdateUserID		varchar(50)						
)
AS
BEGIN		
	Declare @NCIViewID UniqueIdentifier

	select @NCIViewID = V.NCIViewID from Viewobjects V, NCIObjects N where V.ObjectID = N.ParentNCIObjectID and N.ObjectInstanceID = @ObjectInstanceID
	
	Begin tran Tran_Create	

	Delete from NCIObjectProperty 
	where	 ObjectInstanceID= @ObjectInstanceID
		And PropertyName= @PropertyName
	IF (@@ERROR <> 0)
	BEGIN
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END
	
	UPDATE NCIView
		set status ='EDIT',
		      updatedate = getdate(),
		      UpdateUserID = @UpdateUserID
	WHERE NCIViewID = @NCIViewID			
	IF (@@ERROR <> 0)
	BEGIN
		Rollback tran Tran_Create
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	Commit tran Tran_Create

	RETURN 0 

END

GO
GRANT EXECUTE ON [dbo].[usp_DeleteNCIObjectProperty] TO [webadminuser_role]
GO
