IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_SubscriberNewsletter]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_SubscriberNewsletter]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--***********************************************************************
-- Create New Object 
--************************************************************************

/****** Object:  Stored Procedure dbo.usp_UpdateNCIView   Owner:Jhe Purpose: For admin side Script Date: 1/15/2002 16:00:49 pm ******/		
					
					
CREATE PROCEDURE dbo.usp_SubscriberNewsletter
(
	@NewsletterID		UniqueIdentifier,
	@LoginName		varchar(40),
	@Email			varchar(200),
	@UpdateUserID		varchar(40)
)
AS
	SET NOCOUNT OFF;

	Declare @UserID uniqueidentifier

	If exists (select * from  usersubscriptionmap M, nciusers N where M.newsletterID = @NewsletterID and M.UserID = N.UserID and N.loginName =@LoginName)
	BEGIN
		If exists (select * from  usersubscriptionmap M, nciusers N where M.newsletterID = @NewsletterID and M.UserID = N.UserID and N.loginName =@LoginName and M.IsSubscribed =0)
		BEGIN
			Update UserSubscriptionMap
			set 	IsSubscribed = 1,
				UpdateDate	= getdate(),
				updateuserID	= @UpdateUserID,
				SubscriptionDate	= getdate()
			where newsletterID = @NewsletterID and UserID = (select UserID from NCIusers where loginname = @LoginName)
			IF (@@ERROR <> 0)
			BEGIN
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 
		END
	END
	ELse
	BEGIN	
		If exists (select * from nciusers  where loginName =@LoginName)
		BEGIN


			select  @UserID= UserID from nciusers  where loginName =@LoginName

			Insert into UserSubscriptionMap
			(NewsletterID, userID, EmailFormat,  SubscriptionDate, UpdateDate, UpdateUserID, IsSubscribed)
			values
			(@NewsletterID, @UserID, 'HTML', getdate(), getdate(), @UpdateUserID, 1)
			IF (@@ERROR <> 0)
			BEGIN
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 
		END
		Else 
		BEGIN


			select  @UserID= newid()

			insert into nciusers 
			(userID, loginName, email, password, registrationDate, UpdateDate, updateUserID, PasswordLastUpdated)
			values
			(@UserID, @LoginName, @Email, 'newsletter', getdate(), getdate(), @UpdateUserID,  getdate())

			Insert into UserSubscriptionMap
			(NewsletterID, userID, EmailFormat,  SubscriptionDate, UpdateDate, UpdateUserID, IsSubscribed)
			values
			(@NewsletterID, @UserID, 'HTML', getdate(), getdate(), @UpdateUserID, 1)
			IF (@@ERROR <> 0)
			BEGIN
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 
		END
	END


	RETURN 0

GO
GRANT EXECUTE ON [dbo].[usp_SubscriberNewsletter] TO [webadminuser_role]
GO
