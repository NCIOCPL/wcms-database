IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_ModuleInstance_GetAvailableModules]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_ModuleInstance_GetAvailableModules]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_ModuleInstance_GetAvailableModules
	@ModuleInstanceID uniqueidentifier
AS
BEGIN
	Declare @ModuleID uniqueidentifier,
			@GenericModuleID uniqueidentifier

	select @ModuleID = M.ModuleID,  @GenericModuleID = M.GenericModuleID
	from dbo.ModuleInstance MI,[dbo].[Module] M
	where Mi.ModuleInstanceID = @ModuleInstanceID and MI.ModuleID= M.ModuleID

	BEGIN TRY

		SELECT [ModuleID]
			  ,[ModuleName]
		FROM [dbo].[Module]
		Where GenericModuleID = @GenericModuleID
			and ModuleID != @ModuleID
		
	END TRY

	BEGIN CATCH
		RETURN 11309
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_ModuleInstance_GetAvailableModules] TO [websiteuser_role]
GO
