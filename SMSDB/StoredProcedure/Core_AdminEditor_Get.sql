IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_AdminEditor_Get]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_AdminEditor_Get]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************
* Purpose:	Gets an admin editor
* Author:	BryanP
* Date:		7/31/2007
* Params: @EditorID -- The ID of the editor.
*	
********************************************************/
CREATE PROCEDURE [dbo].[Core_AdminEditor_Get] 
(
	@EditorID uniqueidentifier
)
AS	
BEGIN
	SELECT 
		[AdminEditorID],
		[Namespace],
		[AssemblyName],
		[AdminEditorClass]
	FROM [dbo].[AdminEditor]
	WHERE AdminEditorID = @EditorID	
END

GO
GRANT EXECUTE ON [dbo].[Core_AdminEditor_Get] TO [websiteuser_role]
GO
