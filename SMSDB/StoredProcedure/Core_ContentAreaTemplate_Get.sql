IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_ContentAreaTemplate_Get]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_ContentAreaTemplate_Get]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_ContentAreaTemplate_Get
    @ContentAreaTemplateID uniqueidentifier
AS
BEGIN
	BEGIN TRY

		SELECT
		  [TemplateName]
		  ,[FileName]
		  ,[CreateUserID]
		  ,[CreateDate]
		  ,[UpdateUserID]
		  ,[UpdateDate]
			,PrintFileName
		FROM dbo.ContentAreaTemplate
		Where   ContentAreaTemplateID = @ContentAreaTemplateID
		
	END TRY

	BEGIN CATCH
		RETURN 10501
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_ContentAreaTemplate_Get] TO [websiteuser_role]
GO
