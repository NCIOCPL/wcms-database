IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_RetrieveNLKeyword]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_RetrieveNLKeyword]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.usp_RetrieveBestBetCategories   Owner:Jhe Purpose: For admin side Script Date: 1/15/2002 16:00:49 pm ******/

CREATE PROCEDURE dbo.usp_RetrieveNLKeyword
(
	@NewsletterID uniqueidentifier
)
AS
	SELECT KeywordID, Keyword, UpdateDate,UpdateUserID   
	FROM NLKeyword
	WHERE newsletterID= @NewsletterID
	Order by Keyword
GO
GRANT EXECUTE ON [dbo].[usp_RetrieveNLKeyword] TO [webadminuser_role]
GO
