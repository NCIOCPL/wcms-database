IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_InsertInfoBox]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_InsertInfoBox]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



--***********************************************************************
-- Create New Object 
--************************************************************************
/****** 	Object:  Stored Procedure dbo.usp_InsertViewObject    
	Purpose: This script can be used for  inserting viewobjects.	Script Date: 1/30/2002 11:43:49 pM ******/

CREATE PROCEDURE dbo.usp_InsertInfoBox
(
	@ObjectInstanceID	UniqueIdentifier,
	@NCIObjectID       	UniqueIdentifier,
	@Type			Char(10),
	@Description		varchar(200),
	@UpdateUserID		VarChar(40)
)
AS
BEGIN
	SET NOCOUNT ON;

	Declare 	@Priority		Int,
			@NewObjectID	UniqueIdentifier

	select @NewObjectID= newid()

	if (exists (select priority from nciobjects where  ParentNCIObjectID = @NCIObjectID ))
	BEGIN
		select @Priority = max(priority) + 1  from nciobjects where  ParentNCIObjectID = @NCIObjectID 
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
		(@NewObjectID, @Type, @Description, @UpdateUserID)
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
		(@NewObjectID, @Type, @Description, @UpdateUserID)
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
		(@NewObjectID, @Type, @Description, @UpdateUserID)
		IF (@@ERROR <> 0)
		BEGIN
			Rollback tran Tran_Create
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END
	END

	INSERT INTO NCIObjects 
	(ObjectInstanceID, NCIObjectID, ParentNCIObjectID,ObjectType, Priority, UpdateUserID) 
	VALUES 
	(@ObjectInstanceID, @NewObjectID, @NCIObjectID, @Type, @Priority, @UpdateUserID)
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
	WHERE NCIViewID = (select NCIViewID from Viewobjects where objectID =@NCIObjectID)		
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
GRANT EXECUTE ON [dbo].[usp_InsertInfoBox] TO [webadminuser_role]
GO
