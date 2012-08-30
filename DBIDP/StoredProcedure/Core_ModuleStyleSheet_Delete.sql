IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_ModuleStyleSheet_Delete]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_ModuleStyleSheet_Delete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_ModuleStyleSheet_Delete
	@StyleSheetID uniqueidentifier
    ,@UpdateUserID varchar(50)
AS
BEGIN
	BEGIN TRY
		--Fixed a bug where we did not allow a user to delete a stylesheet if it had any GenericModuleStylesheetMap entries.
		--This was wrong.  It is ok to delete if there are entries, in fact we should clear them out, what we do need to
		--check is if there are any modules using the stylesheet.  That we cannot allow deletion.  We previously did not check
		--this so you could remove all mappings and try to delete the style sheet, but would get an error because a 
		--module was still using it.
		--BryanP 9/21/2007

		if (exists (select top 1 CSSID from Module where CSSID = @StyleSheetID))
			return 10106
		
		--Remove all of the map entries
		DELETE FROM GenericModuleStylesheetMap 
		WHERE StyleSheetID= @StyleSheetID

		--Remove the actual stylesheet
		Delete from dbo.ModuleStyleSheet
		where [StyleSheetID] = @StyleSheetID
	
	END TRY

	BEGIN CATCH
		RETURN 10105 -- Delete
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_ModuleStyleSheet_Delete] TO [websiteuser_role]
GO
