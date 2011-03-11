IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_Newsletter_GetSubscribers]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_Newsletter_GetSubscribers]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**********************************************************************************

	Object's name:	usp_Newsletter_GetSubscribers
	Object's type:	stored procedure
	Purpose:
	Author:		??		Bryan	
	Change History:	12/07/2004	Lijia add Priority

**********************************************************************************/

CREATE PROCEDURE dbo.usp_Newsletter_GetSubscribers (
	@newsletterID	uniqueidentifier,
	@viewID	uniqueidentifier
)
AS
BEGIN
	SELECT usm.UserID,
		u.Email, 
		usm.EmailFormat,
		usm.KeywordList,
		usm.Priority
	FROM 	CancerGovStaging.dbo.UserSubscriptionMap usm,
		CancerGovStaging.dbo.NCIUsers u
	WHERE 	usm.UserID = u.UserID 
	AND 	usm.NewsletterID = @newsletterID
	AND 	usm.IsSubscribed = 1
	AND 	usm.UserID NOT IN (
		SELECT UserID
		FROM CancerGovStaging.dbo.NewsletterSendLog
		WHERE NCIViewID = @viewID
		AND Result = 'SENT'
	)
	ORDER BY usm.Priority ASC

--This is for stats
-- 07/08/04 BryanP
INSERT INTO NLSubscribersSelected
(DateSelected, NumberSelected)
VALUES
(getdate(), @@RowCount)

END

GO
GRANT EXECUTE ON [dbo].[usp_Newsletter_GetSubscribers] TO [websiteuser_role]
GO
