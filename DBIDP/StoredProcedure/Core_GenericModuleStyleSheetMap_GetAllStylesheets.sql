IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_GenericModuleStyleSheetMap_GetAllStylesheets]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_GenericModuleStyleSheetMap_GetAllStylesheets]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].Core_GenericModuleStyleSheetMap_GetAllStylesheets
	@GenericModuleID uniqueidentifier
AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

			Select S.StyleSheetID, S.MainClassName, M.GenericModuleID
			From dbo.ModuleStyleSheet S
			left outer Join dbo.GenericModuleStyleSheetMap M
			on S.StyleSheetID= M.StyleSheetID 
			and  GenericModuleID= @GenericModuleID 
			order by S.MainClassName
		
		return 0
	END TRY

	BEGIN CATCH
		RETURN 17002
	END CATCH 

END



GO
GRANT EXECUTE ON [dbo].[Core_GenericModuleStyleSheetMap_GetAllStylesheets] TO [websiteuser_role]
GO
