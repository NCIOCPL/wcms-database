IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_CMSGroup_Update]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_CMSGroup_Update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************
* Purpose:	This will update CMSGroup in the system
* Author:	Jhe
* Date:		8/21/2007
* Params: These are pretty self explanitory
*	
********************************************************/

CREATE PROCEDURE dbo.Core_CMSGroup_Update
    @GroupID	uniqueidentifier,
	@GroupName  varchar(50) = null,
	@isActive bit = null,
	@UpdateUserID varchar(50)
AS

BEGIN
	BEGIN TRY
		
		if (@isActive is null)
		BEGIN
			
			if (exists (select 1 from [dbo].[Group] Where [GroupName] = @GroupName and GroupID <> @GroupID))
				return 90030 --Group name already exists 

			UPDATE [dbo].[Group]
			SET 
			  [GroupName] = @GroupName
			  ,[UpdateDate] = getdate()
			  ,[UpdateUserID] = @UpdateUserID
			WHERE [GroupID] = @GroupID
	    END
		ELSE If (@GroupName is null)
		BEGIN
			UPDATE [dbo].[Group]
			SET 
			  [UpdateDate] = getdate()
			  ,[UpdateUserID] = @UpdateUserID
			  , isactive = @isActive  
			  , DisableDate =
				case when @isActive = 0 then getdate()
					else DisableDate
					end
			WHERE [GroupID] = @GroupID
		END

		RETURN 0

	END TRY

	BEGIN CATCH
		Print 	ERROR_MESSAGE()
		RETURN 90003
	END CATCH 
END



GO
GRANT EXECUTE ON [dbo].[Core_CMSGroup_Update] TO [websiteuser_role]
GO
