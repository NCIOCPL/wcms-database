IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_InsertLink]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_InsertLink]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** 	Object:  Stored Procedure dbo.usp_InsertLink  
	Purpose: This script can be used for  inserting viewobjects.	Script Date: 4/30/2002 11:43:49 pM ******/

CREATE PROCEDURE dbo.usp_InsertLink
(
	@Title			varchar(255),
	@URL			varchar(1000),
	@NCIViewID       	UniqueIdentifier,
	@IsLinkExternal		bit,
	@UpdateUserID		VarChar(40)
)
AS
BEGIN
	SET NOCOUNT ON;

	Declare  @ObjectID		UniqueIdentifier

	select @ObjectID= newid()
		
	/*
	** Add a viewobject 
	*/	
	BEGIN  TRAN   Tran_Link

	INSERT INTO Link
	(LinkID, title, url, InternalOrExternal, UpdateUserID, updatedate) 
	VALUES 
	(@ObjectID, @Title, @URL, @IsLinkExternal,  @UpdateUserID, getdate())
	IF (@@ERROR <> 0)
	BEGIN
		Rollback tran Tran_Link
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 


	INSERT INTO ViewObjects 
	(NCIViewID, ObjectID, Type, Priority, UpdateUserID) 
	VALUES 
	(@NCIViewID, @ObjectID, 'LINK', 999, @UpdateUserID)
	IF (@@ERROR <> 0)
	BEGIN
		Rollback tran Tran_Link
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	COMMIT tran Tran_Link

	SET NOCOUNT OFF
	RETURN 0 

END
GO
GRANT EXECUTE ON [dbo].[usp_InsertLink] TO [webadminuser_role]
GO
