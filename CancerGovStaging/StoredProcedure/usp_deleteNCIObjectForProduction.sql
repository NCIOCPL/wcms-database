IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_deleteNCIObjectForProduction]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_deleteNCIObjectForProduction]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



--***********************************************************************
-- Create New Object 
--************************************************************************


CREATE PROCEDURE [dbo].[usp_deleteNCIObjectForProduction] 
	(
	@ObjectInstanceID uniqueidentifier,
	@Type 		varchar(10),
	 @UpdateUserID varchar(50)
	)
AS
BEGIN	
	SET NOCOUNT ON
		
	if (
	  ( @ObjectInstanceID is NULL) OR (NOT EXISTS (SELECT NCIObjectID FROM CancerGov..NCIobjects WHERE ObjectInstanceID = @ObjectInstanceID )) 
	  )	
	BEGIN
		RAISERROR ( 70001, 16, 1)
		RETURN 70001
	END

	Declare @ObjectID uniqueidentifier,
		@NCIViewID UniqueIdentifier

	select @NCIViewID = V.NCIViewID,  @ObjectID = N.NCIObjectID 
	from CancerGov..Viewobjects V, CancerGov..NCIObjects N where V.ObjectID = N.ParentNCIObjectID and N.ObjectInstanceID = @ObjectInstanceID
	
	BEGIN TRAN Tran_DeleteNCIViewObject

		if (@Type ='IMAGE')
		BEGIN
			delete from CancerGov..[image]
			where imageid = @ObjectID
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN Tran_DeleteNCIViewObject
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 	
		END
		ELSE IF (@Type ='LIST')
		BEGIN
			delete from CancerGov..listitem
			where listid in (select listid from list   where parentlistid = @ObjectID)
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN Tran_DeleteNCIViewObject
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 

			
			delete from CancerGov..list where parentlistid = @ObjectID
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN Tran_DeleteNCIViewObject
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 
			
			delete from CancerGov..listitem
			where listid = @ObjectID
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN Tran_DeleteNCIViewObject
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 	
			
			delete from CancerGov..list
			where listid = @ObjectID
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN Tran_DeleteNCIViewObject
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 	
		END 
		ELSE IF (@Type ='NAVDOC')
		BEGIN
			delete from CancerGov..document
			where documentid = @ObjectID
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN Tran_DeleteNCIViewObject
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 	
		END
	
		-- Delete NCIobjectProperty First
		delete from CancerGov..NCIObjectProperty
		where objectInstanceID = @ObjectInstanceID
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_DeleteNCIViewObject
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 	

		-- Delete NCIobjectProperty First
		delete from CancerGov..NCIObjects
		where objectInstanceID = @ObjectInstanceID
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_DeleteNCIViewObject
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 	

		UPDATE CancerGov..NCIView
			set status ='EDIT',
			      updatedate = getdate(),
			      UpdateUserID = @UpdateUserID
		WHERE NCIViewID = @NCIViewID	
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
GRANT EXECUTE ON [dbo].[usp_deleteNCIObjectForProduction] TO [webadminuser_role]
GO
