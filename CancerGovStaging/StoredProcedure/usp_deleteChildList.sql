IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_deleteChildList]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_deleteChildList]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
**  This procedure will attempt to delete list item, list
**
**  Author: Jay He 	02-28-02 Added deletion of Summary
**
**  Return Values
**  0         Success
**  70001     The guid argument was invalid
**  70003     ViewObject being deleted was a SUMMARY/ PDQ_DOC
**  70004     Failed during execution of deletion
**  70100 	Failed during exeuction of deleting digest page document object property DigestDocList
*/
CREATE PROCEDURE [dbo].[usp_deleteChildList] 
	(
	@ListID		uniqueidentifier 
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
	  (@ListID	 IS NULL) OR (NOT EXISTS (SELECT ListID FROM List WHERE @ListID	= @ListID))
	  )	
	BEGIN
		RAISERROR ( 70001, 16, 1)
		RETURN 70001
	END
	
	DECLARE 	@NCIViewID 	uniqueidentifier
			
	select 	@NCIViewID = NCIViewID from ViewObjects where ObjectID= (select parentlistID from list where listid= @ListID)

	BEGIN TRAN Tran_DeleteNCIViewObject

	/*
	** Delete Child List Items
	*/
	delete from listitem
	where listid = @ListID	
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_DeleteNCIViewObject
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	/*
	** Delete child Lists
	*/
	delete from list
	where listid = @ListID	
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_DeleteNCIViewObject
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	Update NCIView 
	Set Status ='EDIT'
	where NCIViewID = @NCIViewID
		IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_DeleteNCIViewObject
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	COMMIT TRAN Tran_DeleteNCIViewObject

	SET NOCOUNT OFF
	RETURN 0 

END
GO
GRANT EXECUTE ON [dbo].[usp_deleteChildList] TO [webadminuser_role]
GO
