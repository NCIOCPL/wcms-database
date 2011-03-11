IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_RetrieveNLKeywordForView]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_RetrieveNLKeywordForView]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.usp_RetrieveBestBetCategories   Owner:Jhe Purpose: For admin side Script Date: 1/15/2002 16:00:49 pm ******/

CREATE PROCEDURE dbo.usp_RetrieveNLKeywordForView
(
	@ObjectID uniqueidentifier
)
AS
	SELECT K.KeywordID, K.Keyword
	FROM NLKeyword K,  ViewObjects V, NLIssue I
	WHERE  V.NCIViewID=I.NCIViewID and I.NewsletterID = K.NewsletterID and V.ObjectID =@ObjectID and 
		K.Keyword not in 
		(	
			SELECT  V.PropertyValue
			from 	ViewObjectProperty V, ViewObjects O 
			where 	V.PropertyName ='KEYWORD'
	 		AND O.NCIViewObjectID = V.NCIViewObjectID AND O.ObjectID = @ObjectID
		)
	ORDER BY K.Keyword
GO
GRANT EXECUTE ON [dbo].[usp_RetrieveNLKeywordForView] TO [webadminuser_role]
GO
