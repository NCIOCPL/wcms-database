IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_AddBenchmarkObject]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_AddBenchmarkObject]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** 	Object:  Stored Procedure dbo.dbo.usp_addDirectory -- Jay He
	Purpose: This script can be used for adding Search. This will be a transactional script, which creates a nciview and several viewobjects in document table.
	Script Date: 12/27/2002 15:43:49 pM ******/

CREATE PROCEDURE dbo.usp_AddBenchmarkObject
(
	@ViewID		UniqueIdentifier,
	@Type			varchar(15),
	@Priority		int,
	@UpdateUserID		VarChar(40)
)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRAN Tran_AddEForm

	Declare @ObjectID UniqueIdentifier
	
	SET  @ObjectID = newid()

	if (@Type ='DOCUMENT')
	BEGIN
		INSERT INTO Document  (DocumentID, Title, ShortTitle, updateUserID, UpdateDate)
		VALUES
		(@ObjectID, 'Document', 'Document', @UpdateUserID, getdate())
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_AddEForm
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 
	END
	ELSE
	BEGIN
		INSERT INTO ExternalObject 
		(ExternalObjectID, Title, updateUserID, UpdateDate)
		VALUES
		(@ObjectID,  @Type, @UpdateUserID, getdate())
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_AddEForm
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 
	END

	
	INSERT INTO Viewobjects
	(NCIViewID, ObjectID, Type, Priority, updateUserID, UpdateDate)
	VALUES 
	(@ViewID, @ObjectID,  @Type, @Priority, @UpdateUserID,  GETDATE())
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_AddEForm
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END

	UPDATE NCIView
	Set 	Status ='EDIT',
		UpdateUserId= @UpdateUserID
	where nciviewid=@ViewID

	COMMIT TRAN Tran_AddEForm
	SET NOCOUNT OFF
	RETURN 0 

END
GO
GRANT EXECUTE ON [dbo].[usp_AddBenchmarkObject] TO [webadminuser_role]
GO
