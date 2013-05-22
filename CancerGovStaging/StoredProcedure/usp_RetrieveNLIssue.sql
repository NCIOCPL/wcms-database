IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_RetrieveNLIssue]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_RetrieveNLIssue]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Object:  Stored Procedure dbo.usp_RetrieveBestBetCategories   Owner:Jhe Purpose: For admin side Script Date: 1/15/2002 16:00:49 pm ******/

CREATE PROCEDURE dbo.usp_RetrieveNLIssue
(
	@NewsletterID uniqueidentifier,
	@ShowAll int
)
AS
	/*SELECT I.NCIViewID, N.ShortTitle, N.Status as 'Page Status', I.Status as 'Email Status', N.Isonproduction, I.SendDate, I.Priority, I.UpdateDate,I.UpdateUserID   
	FROM NLIssue I, NCIView N
	WHERE I.newsletterID= @NewsletterID and I.Nciviewid= N.NCIviewID
	order by I.Priority
	*/
	-- Comment out 01052004 By Jay He

	if (@ShowAll =1)
	BEGIN
		SELECT I.NCIViewID, N.ShortTitle, N.Status as 'Page Status',  'Status' = I.Status,  I.IssueType, N.Isonproduction, I.SendDate, I.Priority, I.UpdateDate,I.UpdateUserID   
		FROM NLIssue I, NCIView N
		WHERE I.newsletterID= @NewsletterID and I.Nciviewid= N.NCIviewID
		order by I.Priority
	END
	ELSE
	BEGIN
		SELECT I.NCIViewID, N.ShortTitle, N.Status as 'Page Status',  'Status' = I.Status,  I.IssueType, N.Isonproduction, I.SendDate, I.Priority, I.UpdateDate,I.UpdateUserID   
		FROM NLIssue I, NCIView N
		WHERE I.newsletterID= @NewsletterID and I.Nciviewid= N.NCIviewID and I.Status <>'sent'
		order by I.Priority
	END

GO
GRANT EXECUTE ON [dbo].[usp_RetrieveNLIssue] TO [webadminuser_role]
GO
