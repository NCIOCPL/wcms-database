IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_PropertyTemplate_Get]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_PropertyTemplate_Get]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_PropertyTemplate_Get
	@PropertyTemplateID uniqueidentifier
AS
BEGIN
	BEGIN TRY
	SELECT [PropertyTemplateID]
			  ,[PropertyName]
			  ,[ValueType]
			  ,[DefaultValue]
			  ,[CreateUserID]
			  ,[CreateDate]
			  ,[UpdateUserID]
			  ,[UpdateDate]
		  FROM [dbo].[PropertyTemplate]
		Where 		[PropertyTemplateID]= @PropertyTemplateID

	END TRY

	BEGIN CATCH
		RETURN 10701
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_PropertyTemplate_Get] TO [websiteuser_role]
GO
