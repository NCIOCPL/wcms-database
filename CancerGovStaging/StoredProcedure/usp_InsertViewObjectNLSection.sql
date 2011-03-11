IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_InsertViewObjectNLSection]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_InsertViewObjectNLSection]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/****** 	Object:  Stored Procedure dbo.usp_InsertViewObject    
	Purpose: This script can be used for  inserting view objects property value.	Script Date: 8/13/2003 11:43:49 pM ******/

CREATE PROCEDURE dbo.usp_InsertViewObjectNLSection
(
	@NCIViewID		UniqueIdentifier,
	@ObjectID		UniqueIdentifier,
	@Title			varChar(255 ),
	@ShortTitle		varChar( 50 ),
	@Description		varChar(2000 ),
	@HTMLBody          	text,
	@PlainBody		text,
	@Type			Char(10 ),
	@Priority		int,								
	@UpdateUserID		VarChar(40)
)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN  TRAN   Tran_CreateHotfixStudyContact


	INSERT INTO NLSection
	(NLSectionID, title, shorttitle, Description, HTMLBody, PlainBody, UpdateDate, UpdateUserID) 
	VALUES 
	(@ObjectID, @Title, @ShortTitle,  @Description, @HTMLBody, @PlainBody, getdate(), @UpdateUserID)
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

	COMMIT tran Tran_CreateHotfixStudyContact

	SET NOCOUNT OFF
	RETURN 0 

END
GO
GRANT EXECUTE ON [dbo].[usp_InsertViewObjectNLSection] TO [webadminuser_role]
GO
