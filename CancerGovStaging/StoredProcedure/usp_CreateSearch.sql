IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_CreateSearch]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_CreateSearch]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--***********************************************************************
-- Create New Object 
--************************************************************************


CREATE PROCEDURE dbo.usp_CreateSearch
(
	@NCIViewID       	UniqueIdentifier,
	@DocumentID       	UniqueIdentifier,
	@UpdateUserID		VarChar(40),
	@xml			VarChar(4000),
	@Type			varchar(50),
	@Title			varchar(255),
	@Short			varchar(50)
)
AS
BEGIN
	SET NOCOUNT ON;

	Declare @NCIViewObjectID UniqueIdentifier,
		@Priority	int

	if (exists (Select * from Viewobjects where nciviewid= @NCIViewID))
	BEGIN
		Select @Priority = max(priority) from Viewobjects where nciviewid= @NCIViewID and Type <>'HEADER'
	END
	ELSE
	BEGIN
		select @Priority = 0
	END

	select @NCIViewObjectID = newid()

	BEGIN TRAN Tran_AddEForm
	/*
	** STEP - A
	** Add several viewobjects for the above-created view .
	*/		 
	
	INSERT INTO Document  (DocumentID, title, shorttitle, data, updateUserID, UpdateDate)
	VALUES
	(@DocumentID, @Title, @Short, @xml, @UpdateUSerID, getdate())
	IF (@@ERROR <> 0)
	BEGIN
			ROLLBACK TRAN Tran_AddEForm
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
	END 

	/*
	** STEP - C
	** Add above documentID into viewobject for the above-created view 
	*/
	
	SET @NCIViewObjectID = newid()

	INSERT INTO ViewObjects 
	(NCIViewObjectID,NCIViewID, ObjectID, Type, Priority, UpdateDate, UpdateUserID) 
	VALUES 
	(@NCIViewObjectID,@NCIViewID, @DocumentID, @Type,  @Priority + 1, GETDATE(), @UpdateUserID)
	IF (@@ERROR <> 0)
	BEGIN
			ROLLBACK TRAN Tran_AddEForm
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
	END


	COMMIT TRAN Tran_AddEForm
	SET NOCOUNT OFF
	RETURN 0 

END

GO
GRANT EXECUTE ON [dbo].[usp_CreateSearch] TO [webadminuser_role]
GO
