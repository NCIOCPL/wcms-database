IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_LayoutTemplate_UpdatePrintFile]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_LayoutTemplate_UpdatePrintFile]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE  PROCEDURE [dbo].Core_LayoutTemplate_UpdatePrintFile
  @LayoutTemplateID uniqueidentifier
	,@PrintFileName varchar(100)
    ,@UpdateUserID varchar(50)
AS
BEGIN
	BEGIN TRY

		Update dbo.LayoutTemplate
		Set PrintFileName= @PrintFileName
		  ,[UpdateUserID]= @UpdateUserID
		  ,[UpdateDate] = getdate()
		Where   LayoutTemplateID = @LayoutTemplateID
		
	END TRY

	BEGIN CATCH
		RETURN 10407
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_LayoutTemplate_UpdatePrintFile] TO [websiteuser_role]
GO
