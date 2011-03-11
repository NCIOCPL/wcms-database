IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_RetrieveNLIssueDetail]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_RetrieveNLIssueDetail]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.usp_RetrieveBestBetCategories   Owner:Jhe Purpose: For admin side Script Date: 1/15/2002 16:00:49 pm ******/

CREATE PROCEDURE dbo.usp_RetrieveNLIssueDetail
(
	@NCIViewID uniqueidentifier
)
AS
	(SELECT  'ID'  = N.NLSectionID, 'Title'= N.ShortTitle, 'Description'=N.Description, V.Type, V.Priority 
		FROM NLSection N,  ViewObjects V 
		WHERE  N.NLSectionID = V.ObjectID and V.Type ='NLSECTION'
		AND V.NCIViewID=@NCIViewID
	)
	UNION		
	(
	SELECT  'ID' = L.ListID, 'Title'=L.ListName,  'Description'=L.ListDesc, V.Type, V.Priority
		FROM List L, ViewObjects V 
		WHERE L.ListID = V.ObjectID AND V.NCIViewID=@NCIViewID and V.Type ='NLLIST'
	)
	ORDER by V.Priority
GO
GRANT EXECUTE ON [dbo].[usp_RetrieveNLIssueDetail] TO [webadminuser_role]
GO
