IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_PropertyTemplate_GetAll]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_PropertyTemplate_GetAll]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_PropertyTemplate_GetAll
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
			order by 		[PropertyName]

	END TRY

	BEGIN CATCH
		RETURN 10702
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_PropertyTemplate_GetAll] TO [websiteuser_role]
GO
