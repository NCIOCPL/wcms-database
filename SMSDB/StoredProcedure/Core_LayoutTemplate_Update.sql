IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_LayoutTemplate_Update]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_LayoutTemplate_Update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE  PROCEDURE [dbo].Core_LayoutTemplate_Update
    @LayoutTemplateID uniqueidentifier
	,@TemplateName varchar(50)
    ,@UpdateUserID varchar(50)
AS
BEGIN
	BEGIN TRY
		if (dbo.Core_Function_LayoutTemplateExists(null,@TemplateName) =1)
			return 10400 -- Exists

		Update dbo.LayoutTemplate
		Set TemplateName= @TemplateName
		  ,[UpdateUserID]= @UpdateUserID
		  ,[UpdateDate] = getdate()
		Where   LayoutTemplateID = @LayoutTemplateID
		
	END TRY

	BEGIN CATCH
		RETURN 10404
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_LayoutTemplate_Update] TO [websiteuser_role]
GO
