IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_Newsletter_AddUser2]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_Newsletter_AddUser2]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
	This will check to see if a user exists and if they do 
	then it returns the userid for the validation email.
	It also checks to see if they are already subscribed
	to the newsletter
*/
CREATE PROCEDURE dbo.usp_Newsletter_AddUser2 (
	@Email varchar(100),
	@NewsletterID uniqueidentifier
)
AS
BEGIN
	declare @userid uniqueidentifier,
		@IsSubscribed bit
	
	select @userid = (select top 1 userid from CancerGovStaging.dbo.nciusers where email=@email)

	IF (@USERID is NULL)
	BEGIN
		set @USERID = newid()
		--Create user
		INSERT INTO CancergovStaging.dbo.NCIUsers
				(UserID, LoginName, Email, [Password])
			VALUES
				(@userID, LEFT(@email,39), @email, 'newsletter')
		PRINT convert(varchar(36),@USERID) + ' Is new and not subscribed'
		SELECT @USERID as UserID
	END
	ELSE
	BEGIN
		set @IsSubscribed = (
			select IsSubscribed 
			from CancerGovStaging.dbo.UserSubscriptionMap
			where NewsletterID = @NewsletterID
			AND UserID = @UserID)
		IF (@IsSubscribed = 1)
		BEGIN
			--The user is already subscribed to this newsletter so we shall inform them of this
      		RAISERROR ( 'User is already subscribed', 16, 1)
      		RETURN 50000
		END
		ELSE
		BEGIN
		    SELECT @USERID as UserID--Not subscribed so return the user id so we can send them the validation email
		END	   
	END
END

GO
GRANT EXECUTE ON [dbo].[usp_Newsletter_AddUser2] TO [websiteuser_role]
GO
