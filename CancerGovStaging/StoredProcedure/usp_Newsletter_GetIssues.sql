IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_Newsletter_GetIssues]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_Newsletter_GetIssues]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE dbo.usp_Newsletter_GetIssues
AS
BEGIN

	SELECT 	nl.NewsletterID,
		nli.NCIViewID,
		v.Title,
		nl.[From],
		nl.ReplyTo,
		nl.qcemail,
		nli.Status,
		nli.IssueType,
		nli.Priority,
		nli.SendDate

	FROM 
		CancerGovStaging.dbo.NLIssue nli
		Join CancerGovStaging.dbo.Newsletter nl
			ON nli.NewsletterID = nl.NewsletterID
		Join CancerGov.dbo.NCIView v
			ON nli.NciViewID = v.NCIViewID
			AND v.Status = 'PRODUCTION'
	WHERE nl.NewsletterID = nli.NewsletterID
		AND nli.Status IN ('UNSENT', 'RESEND')
		AND getdate() >= nli.SendDate
	Order by nli.Priority

END


GO
GRANT EXECUTE ON [dbo].[usp_Newsletter_GetIssues] TO [websiteuser_role]
GO
