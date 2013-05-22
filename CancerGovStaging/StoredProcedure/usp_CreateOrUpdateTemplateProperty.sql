IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_CreateOrUpdateTemplateProperty]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_CreateOrUpdateTemplateProperty]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** 	Object:  Stored Procedure dbo.usp_InsertNewsletter
	Owner:	Jay He
	Script Date: 3/19/2003 14:43:49 pM 
******/

CREATE PROCEDURE dbo.usp_CreateOrUpdateTemplateProperty
(
	@NCITemplateID	UniqueIdentifier,
	@PropertyName		VarChar(50),
	@PropertyValue		VarChar(7800),
	@ValueType		VarChar(50),
	@Description		VarChar(250),
	@Comments		VarChar(2500),
	@Editable		Bit ,
	@IsDefaultValue	VarChar(2500),
	@UpdateUserID		varchar(50)						
)
AS
BEGIN						

	if (not exists (select propertyname from  TemplateProperty where NCITemplateID=@NCITemplateID  and PropertyName=@PropertyName))
	BEGIN
		insert into TemplateProperty 
		(NCITemplateID, PropertyName, PropertyValue, ValueType, [Description], Comments, Editable, IsDefaultValue, UpdateUserID) 
		values 
		(@NCITemplateID, @PropertyName, @PropertyValue, @ValueType, @Description, @Comments, @Editable, @IsDefaultValue, @UpdateUserID)
		IF (@@ERROR <> 0)
		BEGIN
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 
	END
	ELSE
	BEGIN
		Update TemplateProperty 
		set 	PropertyValue	=	@PropertyValue, 
			ValueType	=	@ValueType, 
			[Description]	=	@Description, 
			Comments	=	@Comments, 
			Editable		=	@Editable, 
			IsDefaultValue	=	@IsDefaultValue, 
			UpdateDate	= 	getdate(),  
			UpdateUserID  	=	@UpdateUserID  
		where NCITemplateID=@NCITemplateID  and PropertyName=@PropertyName
		IF (@@ERROR <> 0)
		BEGIN
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 
	END

	RETURN 0 

END
GO
GRANT EXECUTE ON [dbo].[usp_CreateOrUpdateTemplateProperty] TO [webadminuser_role]
GO
