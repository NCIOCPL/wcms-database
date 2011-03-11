IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_InsertDigestDocListChild]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_InsertDigestDocListChild]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** 	Object:  Stored Procedure dbo.usp_InsertViewObject    
	Purpose: This script can be used for  inserting view objects property value.	Script Date: 8/13/2003 11:43:49 pM ******/

CREATE PROCEDURE dbo.usp_InsertDigestDocListChild
(
	@ListID			UniqueIdentifier,
	@UpdateUserID		VarChar(40)
)
AS
BEGIN
	SET NOCOUNT ON;

	Declare @CListID UniqueIdentifier,
		@Priority int

	if (exists (select * from list where parentlistid = @ListID))
	BEGIN
		select  @Priority= max(priority) from list where parentlistid= @ListID
	END
	ELSE
	BEGIN
		select @Priority =0
	END	
	
	Select @CListID = newid()

	INSERT INTO List
	(ListID, ListName, ListDesc, ParentListID, Priority, UpdateUserID) 
	 VALUES
  	(@CListID, 'List' , 'List', @ListID, @Priority + 1, @UpdateUserID)
	IF (@@ERROR <> 0)
	BEGIN
		Rollback tran Tran_CreateHotfixStudyContact
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	SET NOCOUNT OFF
	RETURN 0 

END
GO
GRANT EXECUTE ON [dbo].[usp_InsertDigestDocListChild] TO [webadminuser_role]
GO
