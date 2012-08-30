IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_CMSGroup_Delete]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_CMSGroup_Delete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************
* Purpose:	This will delete a CMSGroup in the system
* Author:	Jhe
* Date:		8/21/2007
* Params: These are pretty self explanitory
*	
********************************************************/

CREATE PROCEDURE [dbo].[Core_CMSGroup_Delete]
    @GroupID uniqueidentifier,
	@UpdateUserID varchar(50)
AS
BEGIN
	BEGIN TRY
		if (exists (select 1 from [dbo].[GroupUserMap] Where GroupID = @GroupID))
			return 90020 --Group populated with user	

		if (exists (select 1 from [dbo].MemberNodeRoleMap Where MemberID = @GroupID))
			return 90021 --Group populated with permission	
		
		Delete from [dbo].[Group]
		Where GroupID = @GroupID

		Delete from [dbo].[Member]
		Where memberID = @GroupID

		RETURN 0
	END TRY

	BEGIN CATCH
		Print ERROR_MESSAGE()
		RETURN 90002
	END CATCH 
END


GO
GRANT EXECUTE ON [dbo].[Core_CMSGroup_Delete] TO [websiteuser_role]
GO
