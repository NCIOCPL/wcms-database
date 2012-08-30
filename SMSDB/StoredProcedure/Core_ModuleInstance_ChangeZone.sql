IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_ModuleInstance_ChangeZone]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_ModuleInstance_ChangeZone]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_ModuleInstance_ChangeZone
	@ModuleInstanceID uniqueidentifier,
	@ZoneInstanceID uniqueidentifier,
	@UpdateUserID varchar(50)
AS
BEGIN
	Declare @Priority int

	if (exists (select Priority from dbo.ModuleInstance Where ZoneInstanceID = @ZoneInstanceID))
	BEGIN
		select @Priority = max(Priority) + 1 from dbo.ModuleInstance 
		Where ZoneInstanceID = @ZoneInstanceID
	END
	ELSE
	BEGIN
		select @Priority=1
	END 	


	BEGIN TRY

		Update dbo.ModuleInstance
		Set ZoneInstanceID = @ZoneInstanceID
			,Priority = @Priority 
			,UpdateUserID = @UpdateUserID
			,UpdateDate = getdate()
		Where ModuleInstanceID = @ModuleInstanceID

		
	END TRY

	BEGIN CATCH
		RETURN 11311
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_ModuleInstance_ChangeZone] TO [websiteuser_role]
GO
