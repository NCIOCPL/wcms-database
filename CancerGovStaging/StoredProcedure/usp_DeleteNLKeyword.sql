IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_DeleteNLKeyword]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_DeleteNLKeyword]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/****** 	Object:  Stored Procedure dbo.usp_InsertViewObject    
	Purpose: This script can be used for  inserting view objects property value.	Script Date: 8/13/2003 11:43:49 pM 
***/

CREATE PROCEDURE dbo.usp_DeleteNLKeyword
(
	@KeywordID		UniqueIdentifier,
	@UpdateUserID		varchar(50)
)
AS
BEGIN
	SET NOCOUNT ON;

	Declare @NewsletterID UniqueIdentifier

	if(	
	  (@KeywordID IS NULL) OR (NOT EXISTS (Select KeywordID from NLKeyword Where KeywordID = @KeywordID ))
	  )	
	BEGIN
		RAISERROR ( 80100, 16, 1)
		RETURN
	END

	select @NewsletterID=NewsletterID  from NLKeyword  where keywordID=@KeywordID
	IF (@@ERROR <> 0)
	BEGIN
		RAISERROR ( 80100, 16, 1)
		RETURN
	END

	/*
	** Add a parentlist
	*/	
	BEGIN  TRAN   Tran_CreateOrUpdatePrettyURL

	delete from NLKeyword where keywordid=@KeywordID
	IF (@@ERROR <> 0)
	BEGIN
		Rollback tran Tran_CreateOrUpdatePrettyURL
		RAISERROR ( 80109, 16, 1)
		RETURN 
	END 
	
	update Newsletter set status='EDIT' where newsletterID=@NewsletterID
	IF (@@ERROR <> 0)
	BEGIN
		Rollback tran Tran_CreateOrUpdatePrettyURL
		RAISERROR ( 80109, 16, 1)
		RETURN 
	END 

	COMMIT tran  Tran_CreateOrUpdatePrettyURL

	SET NOCOUNT OFF
	RETURN 0 

END
GO
GRANT EXECUTE ON [dbo].[usp_DeleteNLKeyword] TO [webadminuser_role]
GO
