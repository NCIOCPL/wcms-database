IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_RetrieveNLKeywordInUse]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_RetrieveNLKeywordInUse]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.usp_RetrieveBestBetCategories   Owner:Jhe Purpose: For admin side Script Date: 1/15/2002 16:00:49 pm ******/

CREATE PROCEDURE dbo.usp_RetrieveNLKeywordInUse
(
	@KeywordID uniqueidentifier
)
AS
	(SELECT  NL.ShortTitle as Name
	FROM NLKeyword K,  ViewObjects V, NLIssue I, ViewObjectProperty VO, NLSection NL
	WHERE  	V.NCIViewID=I.NCIViewID 
		and VO.NCIViewObjectID =V.NCIViewObjectID 
		and I.NewsletterID = K.NewsletterID 
		and K.KeywordID =@KeywordID
		and VO.PropertyName ='KEYWORD' 
		and VO.PropertyValue = K.Keyword
		and V.Type ='NLSECTION'
		and NL.NLSectionID = V.ObjectID
	)
	Union
	(
	SELECT  L.ListName as Name
	FROM NLKeyword K,  ViewObjects V, NLIssue I, ViewObjectProperty VO, List L
	WHERE  	V.NCIViewID=I.NCIViewID 
		and VO.NCIViewObjectID =V.NCIViewObjectID 
		and I.NewsletterID = K.NewsletterID 
		and K.KeywordID =@KeywordID
		and VO.PropertyName ='KEYWORD' 
		and VO.PropertyValue = K.Keyword
		and V.Type ='NLLIST'
		and L.ListID = V.ObjectID
	)
	order by Name
GO
GRANT EXECUTE ON [dbo].[usp_RetrieveNLKeywordInUse] TO [webadminuser_role]
GO
