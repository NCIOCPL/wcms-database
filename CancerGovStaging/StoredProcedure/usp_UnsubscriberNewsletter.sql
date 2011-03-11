IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_UnsubscriberNewsletter]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_UnsubscriberNewsletter]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--***********************************************************************
-- Create New Object 
--************************************************************************
/****** Object:  Stored Procedure dbo.usp_UpdateNCIView   Owner:Jhe Purpose: For admin side Script Date: 1/15/2002 16:00:49 pm ******/		
					
					
CREATE PROCEDURE dbo.usp_UnsubscriberNewsletter
(
	@NewsletterID		UniqueIdentifier,
	@UserID		UniqueIdentifier,
	@UpdateUserID		varchar(40)
)
AS
	SET NOCOUNT OFF;


	Update UserSubscriptionMap
	set 	IsSubscribed = 0,
		UpdateDate	= getdate(),
		updateuserID	= @UpdateUserID,
		UnsubscribeDate	= getdate()
	where newsletterID = @NewsletterID and UserID = @UserID
	IF (@@ERROR <> 0)
	BEGIN
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 


	RETURN 0

GO
GRANT EXECUTE ON [dbo].[usp_UnsubscriberNewsletter] TO [webadminuser_role]
GO
