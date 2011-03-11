IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_InsertDocPart]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_InsertDocPart]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** 	Object:  Stored Procedure dbo.usp_InsertViewObject    
	Purpose: This script can be used for  inserting doc part.	Script Date: 1/30/2002 11:43:49 pM ******/

CREATE PROCEDURE dbo.usp_InsertDocPart
(
	@ObjectID		UniqueIdentifier,
	@DocumentID		UniqueIdentifier,
	@Priority		Int,
	@UpdateUserID		VarChar(40),
	@Heading		varchar(200),
	@Content		text,
	@ShowTitleOrNot	bit
)
AS
BEGIN
	
	Declare @NCIViewID	UniqueIdentifier

	select @NCIViewID = nciviewid from viewobjects where objectid = @DocumentID

	if (exists (select priority from docpart where documentid=@DocumentID))
	BEGIN
		select @Priority = max(priority) + 1 from docpart where documentid=@DocumentID
	END
	ELSE
	BEGIN	
		 select @Priority =1
	END

	
	BEGIN tran Tran_CreateHotfixStudyContact

	INSERT INTO Docpart
	(DocpartID, DocumentID, priority, heading, content, ShowTitleOrNot, UpdateUserID) 
	VALUES 
	(@ObjectID, @DocumentID, @Priority, @Heading, @Content, @ShowTitleOrNot, @UpdateUserID)
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

	RETURN 0 

END
GO
