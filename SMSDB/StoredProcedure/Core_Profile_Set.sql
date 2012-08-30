IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_Profile_Set]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_Profile_Set]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************
* Purpose:	Updates a user's profile
* Author:	Bryanp
* Date:		08/07/2007
* Params: 
*	
********************************************************/
CREATE PROCEDURE [dbo].[Core_Profile_Set] 
    @UserID             uniqueidentifier,
    @PropertyValues			ntext
AS
BEGIN
	BEGIN TRY
		IF (EXISTS( SELECT *
					   FROM   dbo.[Profile]
					   WHERE  UserId = @UserId))

			UPDATE dbo.[Profile]
			SET		PropertyValues = @PropertyValues, 
					LastUpdatedDate= GetDate()
			WHERE  UserId = @UserId
		ELSE
			INSERT INTO  dbo.[Profile](UserId,  PropertyValues, LastUpdatedDate)
				 VALUES (@UserId,  @PropertyValues, GetDate())
		return 0
	END TRY
	BEGIN CATCH
		return 100002
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[Core_Profile_Set] TO [websiteuser_role]
GO
