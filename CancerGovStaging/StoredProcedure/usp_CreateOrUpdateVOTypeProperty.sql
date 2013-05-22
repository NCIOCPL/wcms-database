IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_CreateOrUpdateVOTypeProperty]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_CreateOrUpdateVOTypeProperty]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** 	Object:  Stored Procedure dbo.usp_InsertNewsletter
	Owner:	Jay He
	Script Date: 3/19/2003 14:43:49 pM 
******/

CREATE PROCEDURE dbo.usp_CreateOrUpdateVOTypeProperty
(
	@NCIObjectID		UniqueIdentifier,
	@PropertyName		VarChar(50),
	@PropertyValue		VarChar(7800),
	@ValueType		VarChar(50),
	@Description		VarChar(250),
	@Comments		VarChar(2500),
	@Editable		bit,
	@IsDefaultValue	VarChar(2500),
	@UpdateUserID		varchar(50)						
)
AS
BEGIN						

	if (not exists (select NCIObjectID from  ViewObjectTypeProperty where NCIObjectID=@NCIObjectID and PropertyName=@PropertyName))
	BEGIN
		insert into ViewObjectTypeProperty 	
		(NCIObjectID, PropertyName, PropertyValue, ValueType, [Description], Comments, Editable, IsDefaultValue, UpdateUserID) 
		values 
		(@NCIObjectID, @PropertyName, @PropertyValue, @ValueType, @Description, @Comments, @Editable, @IsDefaultValue, @UpdateUserID)
		IF (@@ERROR <> 0)
		BEGIN
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 
	END
	ELSE
	BEGIN
		Update ViewObjectTypeProperty 
			set PropertyValue	=@PropertyValue, 
			ValueType		=@ValueType, 
			[Description]		=@Description, 
			Comments		=@Comments, 
			Editable			=@Editable, 
			IsDefaultValue		=@IsDefaultValue, 
			UpdateUserID  	=	@UpdateUserID  
		 where NCIobjectID=@NCIObjectID and PropertyName= @PropertyName
		IF (@@ERROR <> 0)
		BEGIN
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 
	END

	RETURN 0 

END
GO
GRANT EXECUTE ON [dbo].[usp_CreateOrUpdateVOTypeProperty] TO [webadminuser_role]
GO
