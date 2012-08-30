IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_LayoutTemplateZoneMap_Add]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_LayoutTemplateZoneMap_Add]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE  PROCEDURE [dbo].Core_LayoutTemplateZoneMap_Add
    @LayoutTemplateID uniqueidentifier
    ,@TemplateZoneID uniqueidentifier
    ,@CreateUserID varchar(50)
AS
BEGIN
	BEGIN TRY	
		if (not exists (select 1 from dbo.LayoutTemplateZoneMap where 
			LayoutTemplateID = @LayoutTemplateID and TemplateZoneID = @TemplateZoneID))
		BEGIN
			insert into dbo.LayoutTemplateZoneMap
			(
			  LayoutTemplateID
			  ,TemplateZoneID
			  ,[CreateUserID]
			  ,[CreateDate]
			  ,[UpdateUserID]
			  ,[UpdateDate])
			values
			( 
				@LayoutTemplateID,
				@TemplateZoneID,
				@CreateUserID,
				getdate(),
				@CreateUserID,
				getdate()
			)
		END
	END TRY

	BEGIN CATCH
		RETURN 11503
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_LayoutTemplateZoneMap_Add] TO [websiteuser_role]
GO
