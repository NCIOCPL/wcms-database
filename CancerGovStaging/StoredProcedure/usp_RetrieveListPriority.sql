IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_RetrieveListPriority]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_RetrieveListPriority]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.usp_RetrieveViewObject
   Owner:Jhe Purpose: For admin side Script Date: 1/15/2002 16:00:49 pm ****/
/*
CREATE PROCEDURE dbo.usp_RetrieveRightNav
AS
BEGIN
	
	*/

CREATE PROCEDURE dbo.usp_RetrieveListPriority
	(
	@ListID	uniqueidentifier
	)
AS
BEGIN

	SELECT ListID, NCIViewID, Priority From ListItem 
	WHERE ListID =@ListID
	ORDER	 BY Priority

				
END
GO
GRANT EXECUTE ON [dbo].[usp_RetrieveListPriority] TO [webadminuser_role]
GO
