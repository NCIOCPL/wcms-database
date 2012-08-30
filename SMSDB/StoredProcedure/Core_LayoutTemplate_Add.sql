IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_LayoutTemplate_Add]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_LayoutTemplate_Add]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE  PROCEDURE [dbo].Core_LayoutTemplate_Add
    @TemplateName varchar(50)
	,@FileName varchar(50)
    ,@CreateUserID varchar(50)
	,@LayoutTemplateID uniqueidentifier output
AS
BEGIN
	BEGIN TRY
		if (dbo.Core_Function_LayoutTemplateExists(null,@TemplateName) =1)
			return 10400 -- Exists

		select @LayoutTemplateID= newid()

		insert into dbo.LayoutTemplate
		(
		  LayoutTemplateID
		  ,TemplateName
		  ,[FileName]
		  ,[CreateUserID]
		  ,[CreateDate]
		  ,[UpdateUserID]
		  ,[UpdateDate])
		values
		(
			@LayoutTemplateID, 
			@TemplateName,
			@FileName,
			@CreateUserID,
			getdate(),
			@CreateUserID,
			getdate()
		)
	
	END TRY

	BEGIN CATCH
		RETURN 10403
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_LayoutTemplate_Add] TO [websiteuser_role]
GO
