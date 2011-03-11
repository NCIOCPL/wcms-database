IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_RetrieveParentListPriority]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_RetrieveParentListPriority]
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

CREATE PROCEDURE dbo.usp_RetrieveParentListPriority
	(
	@ParentListID	uniqueidentifier
	)
AS
BEGIN

	SELECT ListID, Priority From List
	WHERE ParentListID =@ParentListID
	ORDER BY Priority
				
END
GO
GRANT EXECUTE ON [dbo].[usp_RetrieveParentListPriority] TO [webadminuser_role]
GO
