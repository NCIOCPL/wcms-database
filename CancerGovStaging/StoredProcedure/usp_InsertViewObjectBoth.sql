IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_InsertViewObjectBoth]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_InsertViewObjectBoth]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/****** 	Object:  Stored Procedure dbo.usp_InsertViewObject    
	Purpose: This script can be used for  inserting viewobjects.	Script Date: 1/30/2002 11:43:49 pM ******/

CREATE PROCEDURE dbo.usp_InsertViewObjectBoth
(
	@NCIViewID       	UniqueIdentifier,
	@ObjectID		UniqueIdentifier,
	@Type			Char(10),
	@Priority		Int,
	@UpdateUserID		VarChar(40),
	@Title			varchar(200),
	@ShortTitle		varchar(200)
)
AS
BEGIN
	SET NOCOUNT ON;

	if (exists (select priority from ViewObjects where nciViewID = @NCIViewID))
	BEGIN
		select @Priority = max(priority) + 1 from ViewObjects w where nciViewID = @NCIViewID and Type <>'HEADER'
	END
	ELSE
	BEGIN	
		 select @Priority =1
	END
	

	/*
	** Add a viewobject 
	*/	
	BEGIN  TRAN   Tran_CreateHotfixStudyContact

	INSERT INTO Document
	(DocumentID, title, shorttitle, UpdateUserID) 
	VALUES 
	(@ObjectID, @Title, @ShortTitle, @UpdateUserID)
	IF (@@ERROR <> 0)
	BEGIN
		Rollback tran Tran_CreateHotfixStudyContact
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 


	INSERT INTO ViewObjects 
	(NCIViewID, ObjectID, Type, Priority, UpdateUserID) 
	VALUES 
	(@NCIViewID, @ObjectID, @Type, @Priority, @UpdateUserID)
	IF (@@ERROR <> 0)
	BEGIN
		Rollback tran Tran_CreateHotfixStudyContact
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	UPDATE NCIView
	Set 	status	='EDIT',
		updateuserID = @UpdateUserID
	where nciviewid = @NCIViewID
	IF (@@ERROR <> 0)
	BEGIN
		Rollback tran Tran_CreateHotfixStudyContact
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	COMMIT tran Tran_CreateHotfixStudyContact

	SET NOCOUNT OFF
	RETURN 0 

END

GO
