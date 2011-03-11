IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_UpdateListItemPriority]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_UpdateListItemPriority]
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

CREATE PROCEDURE dbo.usp_UpdateListItemPriority
	(
	@Priority	int,
	@ListID	uniqueidentifier,
	@NCIViewID	uniqueidentifier
	)
AS
BEGIN

	update ListItem
	set 	priority = @Priority 
	WHERE ListID =@ListID and NCIViewID = @NCIViewID
				
	RETURN 0 
END
GO
GRANT EXECUTE ON [dbo].[usp_UpdateListItemPriority] TO [webadminuser_role]
GO
