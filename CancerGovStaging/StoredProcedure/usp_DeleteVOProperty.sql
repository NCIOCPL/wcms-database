IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_DeleteVOProperty]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_DeleteVOProperty]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/* usp_deleteMacro for deleting macro. Only called by SubmitMacroForDeletionApproval
* Jay He 4/4/2003
*/

CREATE PROCEDURE [dbo].[usp_DeleteVOProperty]
(
	@NCIViewObjectID 	uniqueidentifier,
	@PropertyName		varchar(50),
	@PropertyValue		varchar(7800),
	@UpdateUserID varchar(50) 
)
AS
BEGIN	
	SET NOCOUNT ON;

	Declare @NCIViewID uniqueidentifier

	select @NCIViewID = nciviewid from viewobjects where NCIViewObjectID = @NCIViewObjectID

	BEGIN TRAN Tran_DeleteList

	if @PropertyName='KEYWORD'
	BEGIN
		Delete from ViewObjectProperty 
		where NCIViewObjectID=@NCIViewObjectID and PropertyName ='Keyword' and PropertyValue=@PropertyValue
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN  Tran_DeleteList
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 	
	END
	ELSE
	BEGIN
		Delete from ViewObjectProperty 
		where NCIViewObjectID=@NCIViewObjectID and PropertyName =@PropertyName
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN  Tran_DeleteList
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 	
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






	COMMIT TRAN  Tran_DeleteList

	SET NOCOUNT OFF
	RETURN 0 

END
GO
GRANT EXECUTE ON [dbo].[usp_DeleteVOProperty] TO [webadminuser_role]
GO
