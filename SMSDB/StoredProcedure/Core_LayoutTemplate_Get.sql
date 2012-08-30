IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_LayoutTemplate_Get]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_LayoutTemplate_Get]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_LayoutTemplate_Get
    @LayoutTemplateID uniqueidentifier
AS
BEGIN
	BEGIN TRY

		SELECT [LayoutTemplateID]
		  ,[TemplateName]
		  ,[FileName]
		  ,[PrintFileName]
		  ,[CreateUserID]
		  ,[CreateDate]
		  ,[UpdateUserID]
		  ,[UpdateDate]
		FROM dbo.LayoutTemplate
		Where   LayoutTemplateID = @LayoutTemplateID
		
	END TRY

	BEGIN CATCH
		RETURN 10401
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_LayoutTemplate_Get] TO [websiteuser_role]
GO
