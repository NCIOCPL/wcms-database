IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_CMSGroup_Add]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_CMSGroup_Add]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************
* Purpose:	This will add a new CMSUser to the system
* Author:	Jhe
* Date:		8/21/2007
* Params: These are pretty self explanitory
*	
********************************************************/
CREATE  PROCEDURE [dbo].Core_CMSGroup_Add
	@GroupName  varchar(50),
	@CreateUserID varchar(50)
AS
BEGIN
		
	BEGIN TRY

		IF (Exists(SELECT GroupName FROM [Group] WHERE GroupName = @GroupName))
			RETURN 90010 --Group With GroupName already Exists

		declare @groupid uniqueidentifier,
				@memberType  int

		set @groupid = newid()
		set @memberType =2 
	
		insert into [dbo].member (memberid, memberType) values (@groupid, @memberType)
		
		INSERT [dbo].[Group]
		(GroupID, [GroupName],
		[CreateDate], [CreateUserID], [UpdateDate],[UpdateUserID])
		Values
		(@groupID, @GroupName,
		getdate(),@CreateUserID, getdate(),@CreateUserID)
		
		RETURN 0
	END TRY

	BEGIN CATCH
		Print 		ERROR_MESSAGE()
		RETURN 90001
	END CATCH 
END


GO
GRANT EXECUTE ON [dbo].[Core_CMSGroup_Add] TO [websiteuser_role]
GO
