IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_Newsletter_AddSubscription]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_Newsletter_AddSubscription]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE dbo.usp_Newsletter_AddSubscription (
	@newsletterID	uniqueidentifier,
	@userID	uniqueidentifier,
	@format	varchar(5),
	@keywordList	varchar(2000)
)
AS
BEGIN
	Declare @IsSubscribed bit

	set @IsSubscribed = (
		select IsSubscribed 
		from CancerGovStaging.dbo.UserSubscriptionMap
		WHERE newsletterID = @NewsletterID
		AND UserID = @UserID
	)

	IF (@IsSubscribed = 0) 
	BEGIN
		--Theoretically these people have already been inserted
		--But they unsubscribed so all they need is an update
		UPDATE CancerGovStaging.dbo.UserSubscriptionMap
		Set IsSubscribed = 1 
		WHERE newsletterID = @NewsletterID
		AND UserID = @UserID
		
	END
	ELSE
	BEGIN
		INSERT INTO CancerGovStaging.dbo.UserSubscriptionMap
			(NewsletterID, UserID, EmailFormat, KeywordList, IsSubscribed)
		VALUES
			(@newsletterID, @userID, @format, @keywordList,1)
	END
END

GO
GRANT EXECUTE ON [dbo].[usp_Newsletter_AddSubscription] TO [websiteuser_role]
GO
