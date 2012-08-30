IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_Module_Delete]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_Module_Delete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_Module_Delete
	@ModuleID uniqueidentifier
	,@UpdateUserID varchar(50)
AS
BEGIN
	BEGIN TRY

		Delete from [dbo].[Module]
		  Where [ModuleID] = @ModuleID
		
	END TRY

	BEGIN CATCH
		RETURN 10305
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_Module_Delete] TO [websiteuser_role]
GO
