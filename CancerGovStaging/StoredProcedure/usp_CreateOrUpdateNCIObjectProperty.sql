IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_CreateOrUpdateNCIObjectProperty]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_CreateOrUpdateNCIObjectProperty]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--***********************************************************************
-- Create New Object 
--************************************************************************

/****** 	Object:  Stored Procedure dbo.usp_InsertNewsletter
	Owner:	
******/

CREATE PROCEDURE dbo.usp_CreateOrUpdateNCIObjectProperty
(
	@ObjectInstanceID	UniqueIdentifier,
	@PropertyName		VarChar(50),
	@PropertyValue		VarChar(7800),
	@UpdateUserID		varchar(50)						
)
AS
BEGIN		
	Declare @NCIViewID UniqueIdentifier

	select @NCIViewID = V.NCIViewID from Viewobjects V, NCIObjects N where V.ObjectID = N.ParentNCIObjectID and N.ObjectInstanceID = @ObjectInstanceID
	
	Begin tran Tran_Create	

	if (not exists (select ObjectInstanceID from  NCIObjectProperty where  ObjectInstanceID=@ObjectInstanceID and PropertyName=@PropertyName))
	BEGIN
		INSERT INTO NCIObjectProperty
		(ObjectInstanceID, PropertyName, PropertyValue, UpdateUserID, UpdateDate) 
		VALUES 
		(@ObjectInstanceID, @PropertyName, @PropertyValue, @UpdateUserID, GetDate())
		IF (@@ERROR <> 0)
		BEGIN
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 
	END
	ELSE
	BEGIN
		Update NCIObjectProperty 
		set 	PropertyValue	=	@PropertyValue,
			UpdateDate	=	GetDate(),  
			UpdateUserID  	=	@UpdateUserID  
		WHERE  ObjectInstanceID= @ObjectInstanceID 
			And PropertyName= @PropertyName
		IF (@@ERROR <> 0)
		BEGIN
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
GRANT EXECUTE ON [dbo].[usp_CreateOrUpdateNCIObjectProperty] TO [webadminuser_role]
GO
