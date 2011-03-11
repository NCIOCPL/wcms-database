IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_RetrieveNLIssueInUse]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_RetrieveNLIssueInUse]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.usp_RetrieveBestBetCategories   Owner:Jhe Purpose: For admin side Script Date: 1/15/2002 16:00:49 pm ******/

CREATE PROCEDURE dbo.usp_RetrieveNLIssueInUse
(
	@NewsletterID 	uniqueidentifier
)
AS
	SELECT  N.ShortTitle 
	FROM  NLIssue I, NCIView N
	WHERE  	N.NCIViewID=I.NCIViewID 
		and I.NewsletterID = @NewsletterID 
		order by N.ShortTitle
GO
GRANT EXECUTE ON [dbo].[usp_RetrieveNLIssueInUse] TO [webadminuser_role]
GO
