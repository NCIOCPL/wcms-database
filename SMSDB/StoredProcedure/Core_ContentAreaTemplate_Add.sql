IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_ContentAreaTemplate_Add]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_ContentAreaTemplate_Add]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE  PROCEDURE [dbo].Core_ContentAreaTemplate_Add
    @TemplateName varchar(50)
	,@FileName varchar(50)
    ,@CreateUserID varchar(50)
	,@ContentAreaTemplateID uniqueidentifier output
AS
BEGIN
	BEGIN TRY
		if (dbo.Core_Function_ContentAreaTemplateExists(null,@TemplateName) =1)
			return 10500 -- Exists

		select @ContentAreaTemplateID= newid()

		insert into dbo.ContentAreaTemplate
		(
		  ContentAreaTemplateID
		  ,TemplateName
		  ,[FileName]
		  ,[CreateUserID]
		  ,[CreateDate]
		  ,[UpdateUserID]
		  ,[UpdateDate])
		values
		(
			@ContentAreaTemplateID, 
			@TemplateName,
			@FileName,
			@CreateUserID,
			getdate(),
			@CreateUserID,
			getdate()
		)

	END TRY

	BEGIN CATCH
		RETURN 10503
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_ContentAreaTemplate_Add] TO [websiteuser_role]
GO
