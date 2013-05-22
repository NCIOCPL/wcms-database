IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_RetrieveNewsletter]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_RetrieveNewsletter]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Object:  Stored Procedure dbo.usp_RetrieveBestBetCategories   Owner:Jhe Purpose: For admin side Script Date: 1/15/2002 16:00:49 pm ******/

CREATE PROCEDURE dbo.usp_RetrieveNewsletter
(
	@NewsletterID uniqueidentifier
)
AS
	SELECT  OwnerGroupID, Title, [Section], [Description],   ReplyTo, 5 as GroupSentTo,  [From], CreateUserID,CreateDate, Status, UpdateDate,UpdateUserID,qcemail   
	FROM Newsletter  
	WHERE newsletterID= @NewsletterID

GO
GRANT EXECUTE ON [dbo].[usp_RetrieveNewsletter] TO [webadminuser_role]
GO
