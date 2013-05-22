IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_TemplateZone_Add]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_TemplateZone_Add]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE  PROCEDURE [dbo].Core_TemplateZone_Add
    @ZoneName varchar(50)
    ,@TemplateZoneTypeID  int
    ,@CreateUserID varchar(50)
	,@TemplateZoneID uniqueidentifier output
AS
BEGIN
	BEGIN TRY
		if (dbo.Core_Function_TemplateZoneExists(null,@ZoneName ) =1)
		BEGIN
			Declare @OldTypeID	int	,
					@count int 	

			select @TemplateZoneID = TemplateZoneID, @OldTypeID = TemplateZoneTypeID  From  dbo.TemplateZone
			Where ZoneName = @ZoneName
			
			if (@OldTypeID != @TemplateZoneTypeID)
			BEGIN
				Select @count =0

				Select @count = @count + count(*) from dbo.ContentAreaTemplateZoneMap where TemplateZoneID = @TemplateZoneID

				Select @count = @count + count(*) from  dbo.LayoutTemplateZoneMap where TemplateZoneID = @TemplateZoneID

				if (@count=1 and not exists(select 1 from dbo.ZoneInstance where TemplateZoneID = @TemplateZoneID))
				BEGIN
					print '2'

					Update dbo.TemplateZone
					Set TemplateZoneTypeID = @TemplateZoneTypeID
						,[UpdateUserID] = @CreateUserID
						,[UpdateDate] = getdate()
					Where ZoneName = @ZoneName
				END
			END
		END
		ELSE
		BEGIN
			select @TemplateZoneID = newid()

			insert into dbo.TemplateZone
			(
			   TemplateZoneID
			  ,ZoneName
			  ,TemplateZoneTypeID
			  ,[CreateUserID]
			  ,[CreateDate]
			  ,[UpdateUserID]
			  ,[UpdateDate])
			values
			(
				@TemplateZoneID,
				@ZoneName, 
				@TemplateZoneTypeID,
				@CreateUserID,
				getdate(),
				@CreateUserID,
				getdate()
			)
		END
	END TRY

	BEGIN CATCH
		RETURN 10603
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_TemplateZone_Add] TO [websiteuser_role]
GO
