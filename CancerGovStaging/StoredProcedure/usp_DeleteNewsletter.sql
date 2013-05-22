IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_DeleteNewsletter]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_DeleteNewsletter]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/****** 	Object:  Stored Procedure dbo.usp_InsertNewsletter
	Owner:	Jay He
	Script Date: 3/19/2003 14:43:49 pM 
******/

CREATE PROCEDURE dbo.usp_DeleteNewsletter
(
 	@NewsletterID		UniqueIdentifier
)
AS
BEGIN
	SET NOCOUNT ON;

	if(	
	  (  @NewsletterID IS NULL) OR (NOT EXISTS (Select newsletterID from Newsletter Where newsletterID = @NewsletterID ))
	  )	
	BEGIN
		RAISERROR ( 80100, 16, 1)
		RETURN
	END

	-- We need to delete newsletter issue and keywords before deleting newsletter
	/*
	** Add a parentlist
	*/	
	BEGIN  TRAN   Tran_CreateOrUpdatePrettyURL

	delete from NLKeyword where newsletterID=@NewsletterID
	IF (@@ERROR <> 0)
	BEGIN
		Rollback tran Tran_CreateOrUpdatePrettyURL
		RAISERROR ( 80109, 16, 1)
		RETURN 
	END 
	
	delete from NLIssue where newsletterID=@NewsletterID
	IF (@@ERROR <> 0)
	BEGIN
		Rollback tran Tran_CreateOrUpdatePrettyURL
		RAISERROR ( 80109, 16, 1)
		RETURN 
	END 


	Delete from Newsletter
	where NewsletterID	 = @NewsletterID	
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
GRANT EXECUTE ON [dbo].[usp_DeleteNewsletter] TO [webadminuser_role]
GO
