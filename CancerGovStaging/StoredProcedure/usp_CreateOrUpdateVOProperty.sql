IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_CreateOrUpdateVOProperty]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_CreateOrUpdateVOProperty]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** 	Object:  Stored Procedure dbo.usp_InsertNewsletter
	Owner:	Jay He
	Script Date: 3/19/2003 14:43:49 pM 
******/

CREATE PROCEDURE dbo.usp_CreateOrUpdateVOProperty
(
	@NCIViewObjectID	UniqueIdentifier,
	@PropertyName		VarChar(50),
	@PropertyValue		VarChar(7800),
	@UpdateUserID		varchar(50)						
)
AS
BEGIN		
	Declare @NCIViewID UniqueIdentifier

	select @NCIViewID = NCIViewID from Viewobjects where NCIViewObjectID = @NCIViewObjectID
	
	Begin tran Tran_Create	

	if @PropertyName='KEYWORD'
	BEGIN
		INSERT INTO ViewObjectProperty
		(NCIViewObjectID, PropertyName, PropertyValue, UpdateUserID, UpdateDate) 
		VALUES 
		(@NCIViewObjectID, @PropertyName, @PropertyValue, @UpdateUserID, GetDate())
		IF (@@ERROR <> 0)
		BEGIN
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 
	END			
	ELSE 
	BEGIN
		if (not exists (select NCIViewObjectID from  ViewObjectProperty where  NCIViewObjectID=@NCIViewObjectID and PropertyName=@PropertyName))
		BEGIN
			INSERT INTO ViewObjectProperty
			(NCIViewObjectID, PropertyName, PropertyValue, UpdateUserID, UpdateDate) 
			VALUES 
			(@NCIViewObjectID, @PropertyName, @PropertyValue, @UpdateUserID, GetDate())
			IF (@@ERROR <> 0)
			BEGIN
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 
		END
		ELSE
		BEGIN
			Update ViewObjectProperty 
			set 	PropertyValue	=	@PropertyValue,
				UpdateDate	=	GetDate(),  
				UpdateUserID  	=	@UpdateUserID  
			WHERE NCIViewObjectID=@NCIViewObjectID 
				And PropertyName= @PropertyName
			IF (@@ERROR <> 0)
			BEGIN
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END
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
GRANT EXECUTE ON [dbo].[usp_CreateOrUpdateVOProperty] TO [webadminuser_role]
GO
