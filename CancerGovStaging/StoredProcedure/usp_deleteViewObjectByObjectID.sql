IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_deleteViewObjectByObjectID]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_deleteViewObjectByObjectID]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
**  This procedure will attempt to delete a view object from the system.  This will remove
**  the viewobject entry and all other child elements that reside in the database system. This
**  means that we will be using an external process for cleaning files off the server that are
**  not currently being used.
**
**  Issues:  
**      Finally should we check at the end of this script for orphaned "add a link" views and delete them
**
**  Author:
**  Jay He 	02-28-02 Added deletion of Summary
**
**  Return Values
**  0         Success
*/
CREATE PROCEDURE [dbo].[usp_deleteViewObjectByObjectID] 
	(
	@ObjectID uniqueidentifier   -- Note this is the guid for ObjectID
	)
AS
BEGIN	
	SET NOCOUNT ON
	/*
	** STEP - A
	** First Validate that the guid provided is valid
	** if not return and 70001 error
	*/		
	if(	
	  (@ObjectID IS NULL) OR (NOT EXISTS (SELECT NCIViewID FROM ViewObjects where ObjectID=@ObjectID)) 
	  )	
	BEGIN
		RAISERROR ( 70001, 16, 1)
		RETURN 70001
	END
	
	DECLARE 	@NCIViewObjectID uniqueidentifier,
			@NCIViewID 	uniqueidentifier,
			@return_status 	int

	select 	@NCIViewID = NCIViewID,  @NCIViewObjectID =	NCIViewObjectID from ViewObjects where ObjectID=@ObjectID


	BEGIN TRAN Tran_Delete

	/* 
	** STEP - B
	** Call usp_deleteViewObject
	*/
	exec @return_status= usp_deleteViewObject @NCIViewObjectID
	IF @return_status <> 0
	BEGIN
		RollBack TRAN Tran_Delete
		RAISERROR ( 80014, 16, 1)
		RETURN  
	END

	Update NCIView 
	Set Status ='EDIT'
	where NCIViewID = @NCIViewID
	IF (@@ERROR <> 0)
	BEGIN
		RollBack TRAN Tran_Delete
		RAISERROR ( 80014, 16, 1)
		RETURN  
	END

	Commit TRAN Tran_Delete
	
	SET NOCOUNT OFF
	RETURN 0 

END
GO
GRANT EXECUTE ON [dbo].[usp_deleteViewObjectByObjectID] TO [webadminuser_role]
GO
