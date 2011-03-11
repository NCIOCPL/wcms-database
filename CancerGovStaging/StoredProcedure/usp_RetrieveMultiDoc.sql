IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_RetrieveMultiDoc]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_RetrieveMultiDoc]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



--***********************************************************************
-- Create New Object 
--************************************************************************
/****** Object:  Stored Procedure dbo.usp_RetrieveBestBetCategories   Owner:Jhe Purpose: For admin side Script Date: 1/15/2002 16:00:49 pm ******/

CREATE PROCEDURE dbo.usp_RetrieveMultiDoc
(
	@NCIViewID uniqueidentifier
)
AS
		SELECT D.DocumentID, D.Title, D.Description, V.Type, V.Priority 
		FROM DOCUMENT D, ViewObjects V 
		WHERE D.DocumentID = V.ObjectID and V.Type in ('DOCUMENT', 'HDRDOC') 
		AND V.NCIViewID=@NCIViewID
		ORDER by V.Priority
/*
	(SELECT D.DocumentID, D.Title, D.Description, V.Type, V.Priority 
		FROM DOCUMENT D, ViewObjects V 
		WHERE D.DocumentID = V.ObjectID and V.Type in ('DOCUMENT', 'HDRDOC') 
		AND V.NCIViewID=@NCIViewID
	)
	UNION		
	(
	SELECT  'DocumentID' = L.LinkID, L.Title, 'Link', V.Type, V.Priority
		FROM Link L, ViewObjects V 
		WHERE L.LinkID = V.ObjectID AND V.NCIViewID=@NCIViewID
	)
	UNION		
	(
	SELECT  'DocumentID' = N.NCIViewID,  N.Title, N.Description, V.Type, V.Priority
		FROM NCIView N, ViewObjects V 
		WHERE N.NCIViewID = V.ObjectID AND V.NCIViewID=@NCIViewID
	)

	ORDER by V.Priority
*/

GO
GRANT EXECUTE ON [dbo].[usp_RetrieveMultiDoc] TO [webadminuser_role]
GO
