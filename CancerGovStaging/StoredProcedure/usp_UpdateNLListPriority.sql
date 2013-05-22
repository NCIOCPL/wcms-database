IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_UpdateNLListPriority]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_UpdateNLListPriority]
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

CREATE PROCEDURE dbo.usp_UpdateNLListPriority
	(
	@Priority	int,
	@ListID	uniqueidentifier,
	@NCIViewID	uniqueidentifier
	)
AS
BEGIN

	UPDATE NLListItem
	set	Priority=@Priority 
	WHERE ListID =@ListID and NCIViewID = @NCIViewID

				
END
GO
GRANT EXECUTE ON [dbo].[usp_UpdateNLListPriority] TO [webadminuser_role]
GO
