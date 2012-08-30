IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_AdminEditor_Add]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_AdminEditor_Add]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************
* Purpose:	Adds a new admin editor
* Author:	Bryanp
* Date:		7/31/2007
* Params: 
*	
********************************************************/
CREATE PROCEDURE [dbo].[Core_AdminEditor_Add] 
(
	@AdminEditorClass varchar(100),
	@Namespace varchar(256),
	@AssemblyName varchar(100),
	@CreateUserID varchar(50)
)
AS
BEGIN
	INSERT INTO AdminEditor
	(AdminEditorID, AdminEditorClass, Namespace, AssemblyName)
	VALUES
	(newid(), @AdminEditorClass, @Namespace, @AssemblyName)
END

GO
GRANT EXECUTE ON [dbo].[Core_AdminEditor_Add] TO [websiteuser_role]
GO
