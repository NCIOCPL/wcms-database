IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_RetrieveMultiDocOld]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_RetrieveMultiDocOld]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.usp_RetrieveBestBetCategories   Owner:Jhe Purpose: For admin side Script Date: 1/15/2002 16:00:49 pm ******/

CREATE PROCEDURE dbo.usp_RetrieveMultiDocOld
(
	@NCIViewID uniqueidentifier
)
AS
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
	ORDER by V.Priority
GO
