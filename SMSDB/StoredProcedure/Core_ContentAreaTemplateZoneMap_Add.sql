IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_ContentAreaTemplateZoneMap_Add]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_ContentAreaTemplateZoneMap_Add]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE  PROCEDURE [dbo].Core_ContentAreaTemplateZoneMap_Add
    @ContentAreaTemplateID uniqueidentifier
    ,@TemplateZoneID uniqueidentifier
    ,@CreateUserID varchar(50)
AS
BEGIN
	BEGIN TRY
		if (not exists (select 1 from dbo.ContentAreaTemplateZoneMap where 
			ContentAreaTemplateID = @ContentAreaTemplateID and TemplateZoneID = @TemplateZoneID))
		BEGIN
			insert into dbo.ContentAreaTemplateZoneMap
			(
			  ContentAreaTemplateID
			  ,TemplateZoneID
			  ,[CreateUserID]
			  ,[CreateDate]
			  ,[UpdateUserID]
			  ,[UpdateDate])
			values
			( 
				@ContentAreaTemplateID,
				@TemplateZoneID,
				@CreateUserID,
				getdate(),
				@CreateUserID,
				getdate()
			)
		END

		return 0
	END TRY

	BEGIN CATCH
		RETURN 11603
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_ContentAreaTemplateZoneMap_Add] TO [websiteuser_role]
GO
