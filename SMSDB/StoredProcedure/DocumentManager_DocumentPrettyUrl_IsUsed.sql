IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DocumentManager_DocumentPrettyUrl_IsUsed]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[DocumentManager_DocumentPrettyUrl_IsUsed]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************
* Purpose:	Checks to see if a pretty url is being used by any documents.  
*			This should replace DocumentManager_DocumentPrettyUrl_Exist...(Since that check the node pretty urls and
*			the purpose of the new pretty url providers is to not have to check in the db like this.
* Author:	BryanP
* Date:		11/6/07
* Params: 
*	
********************************************************/
CREATE PROCEDURE [dbo].[DocumentManager_DocumentPrettyUrl_IsUsed] 
	@PrettyUrl varchar(512),
	@IsUsed bit OUTPUT
AS
BEGIN
	SET @IsUsed = 0

	if (EXISTS(SELECT DocumentPrettyUrlID FROM dbo.DocumentPrettyURL where PrettyURL = @PrettyURL))
		SET @IsUsed = 1

END

GO
GRANT EXECUTE ON [dbo].[DocumentManager_DocumentPrettyUrl_IsUsed] TO [websiteuser_role]
GO
