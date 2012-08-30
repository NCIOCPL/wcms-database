IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_CMSGroup_AssignUserToGroup]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_CMSGroup_AssignUserToGroup]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************
* Purpose:	This will get CMSGroup in the system
* Author:	Jhe
* Date:		8/21/2007
* Params:   @UserIDs is a string containing a list of UserIDs which is separated by comma
*	
********************************************************/


CREATE PROCEDURE [dbo].Core_CMSGroup_AssignUserToGroup
	@GroupID	uniqueIdentifier,
	@UserIDs	varchar(max),
	@CreateUserID  varchar(50)
AS
BEGIN

	BEGIN TRY

		if (not exists (select 1 from [dbo].[Group] Where  GroupID = @GroupID))
				return 90110 --Group doesn't exists 

		if (rtrim(ltrim(@UserIDs)) = '' )
				return 90111 --user list doesn't exists 

		DECLARE	@CTE TABLE (
			ID uniqueIdentifier
		);

		--Create table
		INSERT INTO @CTE
			(
				ID
			)
		SELECT	
			item
		FROM dbo.udf_ListToGuid (	@UserIDs, ',')

		if ( exists (select 1 from [dbo].GroupUserMap M, @CTE C Where  M.GroupID = @GroupID and M.UserID =C.ID))
				return 90112 --Group/User mapping exists 

		Insert into GroupUserMap
			(GroupID,UserID,[CreateDate],[CreateUserID],[UpdateDate],[UpdateUserID])
		Select @GroupID, ID, getdate(),@CreateUserID,getdate(), @CreateUserID
		From @CTE


/*
		-- loop through child to update each one child's binary
		DECLARE @UserID uniqueIdentifier,
			@LoopCounter int,
			@rtnVal int

		set @LoopCounter = 1

		Select 	@UserID = ID
		From @CTE --FROM dbo.Core_Function_GetChildNodes(@NodeID)
		WHERE RowNumber = @LoopCounter

		--Loop each and insert into table
		While @@rowcount <> 0
		BEGIN
			
			Insert into GroupUserMap
			(GroupID,UserID,[CreateDate],[CreateUserID],[UpdateDate],[UpdateUserID])
			values
			(@GroupID, @UserID,getdate(),@CreateUserID,getdate(),@CreateUserID)

			IF @@error <> 0
				select @ErrorMessage =@ErrorMessage + Convert(varchar(36), @UserID) + ','
			
			SET @LoopCounter = @LoopCounter + 1

			Select 	@UserID = ID
			FROM @CTE
			WHERE RowNumber = @LoopCounter
		END
		-- End Loop
*/

	END TRY

	BEGIN CATCH
		Print Error_Message()
		RETURN 90103
	END CATCH 
END



GO
GRANT EXECUTE ON [dbo].[Core_CMSGroup_AssignUserToGroup] TO [websiteuser_role]
GO
