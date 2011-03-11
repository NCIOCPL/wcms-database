IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_InsertDocumentForCancerHome]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_InsertDocumentForCancerHome]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO

--***********************************************************************
-- Create New Object 
--************************************************************************

/****** 	Object:  Stored Procedure dbo.usp_InsertViewObjectBasicDocument    
*	Purpose: This script can be used for  inserting viewobjects for new template: BasicDocument
*	Script Date: 5/12/2004 15:43:49 pM 
*	Author: Jay He
******/

CREATE PROCEDURE dbo.usp_InsertDocumentForCancerHome
(
	@NCIViewID       	UniqueIdentifier,
	@ObjectID		UniqueIdentifier,
	@Description		varchar(200),
	@UpdateUserID		VarChar(40)
)
AS
BEGIN
	SET NOCOUNT ON;

	Declare 	@Priority		Int,
			@Type varchar(50)

	select @Type = 'DOCUMENT'

	select @Priority =0
	

	/*
	** Add a viewobject 
	*/	
	BEGIN  TRAN   Tran_Create

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
GRANT EXECUTE ON [dbo].[usp_InsertDocumentForCancerHome] TO [webadminuser_role]
GO
