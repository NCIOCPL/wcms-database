IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_UpdateParentListPriority]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_UpdateParentListPriority]
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

CREATE PROCEDURE dbo.usp_UpdateParentListPriority
	(
	@Priority	int,
	@ListID	uniqueidentifier
	)
AS
BEGIN

	update List
	set 	priority = @Priority 
	WHERE ListID =@ListID 
				
	RETURN 0 
END
GO
GRANT EXECUTE ON [dbo].[usp_UpdateParentListPriority] TO [webadminuser_role]
GO
