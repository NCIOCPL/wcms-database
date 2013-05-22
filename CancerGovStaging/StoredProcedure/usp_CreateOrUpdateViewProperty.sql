IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_CreateOrUpdateViewProperty]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_CreateOrUpdateViewProperty]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** 	Object:  Stored Procedure dbo.usp_InsertNewsletter
	Owner:	Jay He
	Script Date: 3/19/2003 14:43:49 pM 
******/

CREATE PROCEDURE dbo.usp_CreateOrUpdateViewProperty
(
	@NCIViewID	UniqueIdentifier,
	@PropertyName		VarChar(50),
	@PropertyValue		VarChar(7800),
	@UpdateUserID		varchar(50)						
)
AS
BEGIN		
	Declare @count int

	select @count = count(*) from ViewProperty 
	where propertyname=@PropertyName and NCIViewID =@NCIViewID
	
	BEGIN tran Tran_Create
	
	if ( @Count >0)
	BEGIN
		Update ViewProperty 
		set 	PropertyValue =@PropertyValue 
		where 	NCIViewID=@NCIViewID 
			and PropertyName=@PropertyName
		IF (@@ERROR <> 0)
		BEGIN
			Rollback tran Tran_Create
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 
	END
	else
	BEGIN
		Insert into ViewProperty 
		(NCIViewID, PropertyName, PropertyValue, UpdateUserID) 
		values 
		(@NCIViewID, @PropertyName, @PropertyValue, @UpdateUserID) 
		IF (@@ERROR <> 0)
		BEGIN
			Rollback tran Tran_Create
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 
	END

	UPDATE NCIView
		set status ='EDIT',
		      updatedate = getdate(),
		      UpdateUserID = @UpdateUserID
	WHERE NCIViewID = @NCIViewID			
	IF (@@ERROR <> 0)
	BEGIN
		Rollback tran Tran_Create
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	Commit tran Tran_Create

	RETURN 0 

END
GO
GRANT EXECUTE ON [dbo].[usp_CreateOrUpdateViewProperty] TO [webadminuser_role]
GO
