IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_RetrieveKeywordCount]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_RetrieveKeywordCount]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/* usp_deleteMacro for deleting macro. Only called by SubmitMacroForDeletionApproval
* Jay He 4/4/2003
*/

CREATE PROCEDURE [dbo].[usp_RetrieveKeywordCount]
(
	@Keyword	varchar(2000),
	@NewsletterID		uniqueidentifier,
	@KeywordID	uniqueidentifier
)
AS
BEGIN	

	select count(*) from NLKeyword where Keyword =@Keyword and 
	NewsletterID =@NewsletterID  and KeywordID != @KeywordID 					
	IF (@@ERROR <> 0)
	BEGIN
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 	
	

END
GO
GRANT EXECUTE ON [dbo].[usp_RetrieveKeywordCount] TO [webadminuser_role]
GO
