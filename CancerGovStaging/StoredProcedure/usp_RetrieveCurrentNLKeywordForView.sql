IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_RetrieveCurrentNLKeywordForView]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_RetrieveCurrentNLKeywordForView]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.usp_RetrieveBestBetCategories   Owner:Jhe Purpose: For admin side Script Date: 1/15/2002 16:00:49 pm ******/

CREATE PROCEDURE dbo.usp_RetrieveCurrentNLKeywordForView
(
	@ObjectID uniqueidentifier
)
AS
	SELECT V.NCIViewObjectID, V.PropertyName, V.PropertyValue, 'Update'= V.UpdateUserID +' ' + Convert(varchar,V.UpdateDate,101) 
	from 	ViewObjectProperty V, ViewObjects O 
	where 	V.PropertyName ='KEYWORD'
	 	AND O.NCIViewObjectID = V.NCIViewObjectID AND O.ObjectID = @ObjectID
GO
GRANT EXECUTE ON [dbo].[usp_RetrieveCurrentNLKeywordForView] TO [webadminuser_role]
GO
