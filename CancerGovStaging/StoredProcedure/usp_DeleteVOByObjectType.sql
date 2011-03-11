IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_DeleteVOByObjectType]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_DeleteVOByObjectType]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/* usp_deleteMacro for deleting macro. Only called by SubmitMacroForDeletionApproval
* Jay He 4/4/2003
*/

CREATE PROCEDURE [dbo].[usp_DeleteVOByObjectType]
(
	@NCIViewID 	uniqueidentifier,
	@ObjectID	uniqueidentifier,
	@Type		varchar(20),
	@UpdateUserID varchar(50) 
)
AS
BEGIN	
	SET NOCOUNT ON;


	BEGIN TRAN Tran_DeleteList

	if @Type ='VIEWOBJECTS'
	BEGIN
		DELETE FROM  ViewObjects 
		WHERE NCIViewID = @NCIViewID and ObjectID = @ObjectID
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN  Tran_DeleteList
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
			Rollback tran Tran_DeleteList
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 
	END
	ELSE if @Type ='VIEWPROPERTY'
	BEGIN
		Delete from ViewProperty 
		WHERE NCIViewID = @NCIViewID and ViewPropertyID = @ObjectID
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN  Tran_DeleteList
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
			Rollback tran Tran_DeleteList
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 
	END

	if @Type ='NLLISTITEM'
	BEGIN
		DELETE FROM  NLListItem 
		WHERE NCIViewID = @NCIViewID and ListID = @ObjectID
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN  Tran_DeleteList
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 	
	END



	COMMIT TRAN  Tran_DeleteList

	SET NOCOUNT OFF
	RETURN 0 

END
GO
GRANT EXECUTE ON [dbo].[usp_DeleteVOByObjectType] TO [webadminuser_role]
GO
