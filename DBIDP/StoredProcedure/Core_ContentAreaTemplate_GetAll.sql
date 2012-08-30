IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_ContentAreaTemplate_GetAll]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_ContentAreaTemplate_GetAll]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE  PROCEDURE [dbo].Core_ContentAreaTemplate_GetAll
AS
BEGIN
	BEGIN TRY

		SELECT ContentAreaTemplateID
		  ,[TemplateName]
		  ,[FileName]
		  ,[CreateUserID]
		  ,[CreateDate]
		  ,[UpdateUserID]
		  ,[UpdateDate]
		,PrintFileName
		FROM dbo.ContentAreaTemplate
		order by [TemplateName]

	END TRY

	BEGIN CATCH
		RETURN 10502
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_ContentAreaTemplate_GetAll] TO [websiteuser_role]
GO
