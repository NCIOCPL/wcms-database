IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_AdminEditor_Update]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_AdminEditor_Update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************
* Purpose:	Updates an admin editor
* Author:	BryanP
* Date:		7/31/2007
* Params: 
*	
********************************************************/
CREATE PROCEDURE [dbo].[Core_AdminEditor_Update] 
(
	@AdminEditorID uniqueidentifier,
	@AdminEditorClass varchar(100),
	@Namespace varchar(256),
	@AssemblyName varchar(100),
	@UpdateUserID varchar(50)
)
AS
BEGIN
	UPDATE AdminEditor
	SET AdminEditorClass = @AdminEditorClass,
		Namespace = @NameSpace,
		AssemblyName = @AssemblyName
	WHERE AdminEditorID = @AdminEditorID
END

GO
GRANT EXECUTE ON [dbo].[Core_AdminEditor_Update] TO [websiteuser_role]
GO
