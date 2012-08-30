IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_AdminEditor_Delete]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_AdminEditor_Delete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************
* Purpose:	Removes an admin editor
* Author:	BryanP
* Date:		7/31/2007
* Params: 
*	
********************************************************/
CREATE PROCEDURE [dbo].[Core_AdminEditor_Delete] 
(
	@AdminEditorID uniqueidentifier,
	@UpdateUserID varchar(50)
)
AS
BEGIN
	DELETE AdminEditor
	WHERE AdminEditorID = @AdminEditorID	
END

GO
GRANT EXECUTE ON [dbo].[Core_AdminEditor_Delete] TO [websiteuser_role]
GO
