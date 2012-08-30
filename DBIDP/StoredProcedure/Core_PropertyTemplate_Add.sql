IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_PropertyTemplate_Add]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_PropertyTemplate_Add]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_PropertyTemplate_Add
	@PropertyName varchar(50)
	,@ValueType varchar(50)
	,@DefaultValue varchar(max)
	,@CreateUserID varchar(50)
AS
BEGIN
	BEGIN TRY
		if (dbo.Core_Function_PropertyTemplateExists(null, @PropertyName) =1)
			return 10300

		Insert into dbo.PropertyTemplate
		(PropertyTemplateID, PropertyName ,ValueType, DefaultValue, CreateUserID, CreateDate, UpdateUserID,UpdateDate )
		values
		(newid(), @PropertyName, @ValueType, @DefaultValue, @CreateUserID, getdate(), @CreateUserID, getdate())
		
	END TRY

	BEGIN CATCH
		RETURN 10703
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_PropertyTemplate_Add] TO [websiteuser_role]
GO
