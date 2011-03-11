IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_Newsletter_CancelSubscription]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_Newsletter_CancelSubscription]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE dbo.usp_Newsletter_CancelSubscription (
	@newsletterID	uniqueidentifier,
	@userID	uniqueidentifier
)
AS
BEGIN
	DECLARE @IsSubscribed bit

	set @IsSubscribed = (
		select IsSubscribed 
		from CancergovStaging.dbo.UserSubscriptionMap 
		where newsletterid = @NewsletterID
		AND UserID = @UserID
	)

	if (@IsSubscribed = 1)
	BEGIN
		update CancergovStaging.dbo.UserSubscriptionMap
		set IsSubscribed = 0, UnsubscribeDate = getdate()
		WHERE NewsletterID = @newsletterID
		AND UserID = @userID
	END
	ELSE
	BEGIN
		RaisError('User is not subscribed',16,1)
	END
END

GO
GRANT EXECUTE ON [dbo].[usp_Newsletter_CancelSubscription] TO [websiteuser_role]
GO
