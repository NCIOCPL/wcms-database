IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_LayoutTemplate_GetAll]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_LayoutTemplate_GetAll]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE  PROCEDURE [dbo].Core_LayoutTemplate_GetAll
AS
BEGIN
	BEGIN TRY

		SELECT [LayoutTemplateID]
		  ,[TemplateName]
		  ,[FileName]
		  ,[CreateUserID]
		  ,[CreateDate]
		  ,[UpdateUserID]
		  ,[UpdateDate]
		 ,[PrintFileName]
		FROM dbo.LayoutTemplate
		order by TemplateName
		
	END TRY

	BEGIN CATCH
		RETURN 10402
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_LayoutTemplate_GetAll] TO [websiteuser_role]
GO
