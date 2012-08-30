IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_ZoneInstance_Add]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_ZoneInstance_Add]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE  PROCEDURE [dbo].Core_ZoneInstance_Add
	@NodeID uniqueidentifier
	,@CanInherit bit = 0
	,@TemplateZoneID uniqueidentifier
    ,@UpdateUserID varchar(50)
	,@ZoneInstanceID uniqueidentifier output
AS
BEGIN
	BEGIN TRY
		if (exists (select 1 from dbo.ZoneInstance where NodeID= @NodeID and TemplateZoneID = @TemplateZoneID))
			return 11300 -- Exists

		select @ZoneInstanceID = newid()

		INSERT INTO [dbo].[ZoneInstance]
           ([ZoneInstanceID]
           ,[NodeID]
           ,[CanInherit]
           ,[TemplateZoneID]
           ,[CreateUserID]
           ,[CreateDate]
           ,[UpdateUserID]
           ,[UpdateDate])
		VALUES
		(
			@ZoneInstanceID, 
			@NodeID,
			@CanInherit,
			@TemplateZoneID,
			@UpdateUserID,
			getdate(),
			@UpdateUserID,
			getdate()
		)
		
		Declare @rtnValue int

		exec @rtnValue = dbo.Core_Node_SetStatus @NodeID, @UpdateUserID
		if (@rtnValue >0)
			return @rtnValue
		
		return 0	

	END TRY

	BEGIN CATCH
		RETURN 11303
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_ZoneInstance_Add] TO [websiteuser_role]
GO
