IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_PropertyTemplate_Update]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_PropertyTemplate_Update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_PropertyTemplate_Update
	@PropertyTemplateID uniqueidentifier
	,@PropertyName varchar(50)
	,@ValueType varchar(50)
	,@DefaultValue varchar(max)
	,@UpdateUserID varchar(50)
AS
BEGIN
	BEGIN TRY
		if (dbo.Core_Function_PropertyTemplateExists(@PropertyTemplateID, @PropertyName) =1)
			return 10700

		Update dbo.PropertyTemplate
		Set PropertyName = @PropertyName
			,ValueType = @ValueType
			,DefaultValue = @DefaultValue
			,UpdateUserID = @UpdateUserID
			,UpdateDate = getdate()
		Where PropertyTemplateID = @PropertyTemplateID
		
	END TRY

	BEGIN CATCH
		RETURN 10704
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_PropertyTemplate_Update] TO [websiteuser_role]
GO
