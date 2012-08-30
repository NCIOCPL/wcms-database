IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_ContentAreaTemplate_UpdatePrintFile]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_ContentAreaTemplate_UpdatePrintFile]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE  PROCEDURE [dbo].Core_ContentAreaTemplate_UpdatePrintFile
  @ContentAreaTemplateID uniqueidentifier
	,@PrintFileName varchar(100)
    ,@UpdateUserID varchar(50)
AS
BEGIN
	BEGIN TRY

		Update dbo.ContentAreaTemplate
		Set PrintFileName= @PrintFileName
		  ,[UpdateUserID]= @UpdateUserID
		  ,[UpdateDate] = getdate()
		Where   ContentAreaTemplateID = @ContentAreaTemplateID
		
	END TRY

	BEGIN CATCH
		RETURN 10507
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_ContentAreaTemplate_UpdatePrintFile] TO [websiteuser_role]
GO
