IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_InsertViewObjectLeftNav]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_InsertViewObjectLeftNav]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




--***********************************************************************
-- Create New Object 
--************************************************************************

CREATE PROCEDURE dbo.usp_InsertViewObjectLeftNav
(
	@NCIViewID       	UniqueIdentifier,
	@ObjectID		UniqueIdentifier,
	@Type			Char(10),
	@Description		varchar(200),
	@UpdateUserID		VarChar(40)
)
AS
BEGIN
	SET NOCOUNT ON;

	Declare 	@Priority		Int

	if (exists (select priority from viewobjects where  NCIViewID = @NCIViewID ))
	BEGIN
		select @Priority = max(priority) + 1  from viewobjects where  NCIViewID = @NCIViewID and Type <>'HEADER'
	END
	ELSE
	BEGIN	
		 select @Priority =1
	END


	/*
	** Add a viewobject 
	*/	
	BEGIN  TRAN   Tran_Create

	IF (@Type ='IMAGE')
	BEGIN
		INSERT INTO IMAGE 
		(ImageID, ImageName, ImageSource, UpdateUserID) 
		VALUES 
		(@ObjectID, @Type, @Description, @UpdateUserID)
		IF (@@ERROR <> 0)
		BEGIN
			Rollback tran Tran_Create
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 
	END
	ELSE if  (@Type ='NAVDOC' )
	BEGIN
		INSERT INTO Document
		(DocumentID, title, shorttitle, UpdateUserID) 
		VALUES 
		(@ObjectID, @Type, @Description, @UpdateUserID)
		IF (@@ERROR <> 0)
		BEGIN
			Rollback tran Tran_Create
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 
	END
	ELSE if  (@Type ='LIST' )
	BEGIN
		INSERT INTO List
		(ListID, ListName, ListDesc, UpdateUserID) 
		VALUES 
		(@ObjectID, @Type, @Description, @UpdateUserID)
		IF (@@ERROR <> 0)
		BEGIN
			Rollback tran Tran_Create
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END
	END

	INSERT INTO ViewObjects 
	(NCIViewID, ObjectID, Type, Priority, UpdateUserID) 
	VALUES 
	(@NCIViewID, @ObjectID, @Type, @Priority, @UpdateUserID)
	IF (@@ERROR <> 0)
	BEGIN
		Rollback tran Tran_Create
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


	COMMIT tran Tran_Create

	SET NOCOUNT OFF
	RETURN 0 

END

GO
GRANT EXECUTE ON [dbo].[usp_InsertViewObjectLeftNav] TO [webadminuser_role]
GO
