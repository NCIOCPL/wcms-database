IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_GenericModule_Delete]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_GenericModule_Delete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_GenericModule_Delete
	@GenericModuleID uniqueidentifier
    ,@UpdateUserID varchar(50)
AS
BEGIN
	BEGIN TRY
		if (exists (select 1 from dbo.Module where GenericModuleID= @GenericModuleID))
			return 10206		

		Delete from dbo.GenericModuleStyleSheetMap
		Where GenericModuleID = @GenericModuleID

		Delete from dbo.GenericModule
		Where GenericModuleID = @GenericModuleID
	
	END TRY

	BEGIN CATCH
		RETURN 10205 -- Delete
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_GenericModule_Delete] TO [websiteuser_role]
GO
