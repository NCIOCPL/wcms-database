IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_InsertNLKeyword]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_InsertNLKeyword]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/****** 	Object:  Stored Procedure dbo.usp_InsertNewsletter
	Owner:	Jay He
	Script Date: 3/19/2003 14:43:49 pM 
******/

CREATE PROCEDURE dbo.usp_InsertNLKeyword
(
 	@NewsletterID		UniqueIdentifier,
	@Keyword		varchar(2000),
	@UpdateUserID		varchar(50)										
)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRAN Tran_InsertLinkView
	-- We only insert newsletter
	INSERT INTO  NLKeyword
	(KeywordID, NewsletterID, Keyword, UpdateDate,  UpdateUserID) 
	VALUES 
	(newid(), @NewsletterID, @Keyword, getdate(), @UpdateUserID) 
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_InsertLinkView
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	Update Newsletter
	set 	Status =		'EDIT',
		UpdateDate	= getdate(),  
		UpdateUserID  	=@UpdateUserID  
	where NewsletterID = @NewsletterID
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_InsertLinkView
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	COMMIT TRAN  Tran_InsertLinkView
	SET NOCOUNT OFF

	RETURN 0 

END
GO
GRANT EXECUTE ON [dbo].[usp_InsertNLKeyword] TO [webadminuser_role]
GO
