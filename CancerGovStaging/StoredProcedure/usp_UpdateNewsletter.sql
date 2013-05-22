IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_UpdateNewsletter]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_UpdateNewsletter]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO

/****** 	Object:  Stored Procedure dbo.usp_InsertNewsletter
	Owner:	Jay He
	Script Date: 3/19/2003 14:43:49 pM 
******/

CREATE PROCEDURE dbo.usp_UpdateNewsletter
(
 	@NewsletterID		UniqueIdentifier,
 	@OwnerGroupID	Int,
	@Title			varchar(2000),
	@Description		varchar(200),
	@From			varchar(1000),
	@ReplyTo		varchar(1000),
	@UpdateUserID		varchar(50),
 	@Section		UniqueIdentifier,
	@qcemail		varchar(1000)=NULL								
)
AS
BEGIN

	-- We only insert newsletter
	Update Newsletter
	set 	Section 		=@Section,
		OwnerGroupID	=@OwnerGroupID, 
		Title		=@Title, 
		Description	=@Description,
		[From]		=@From,
		ReplyTo	=@ReplyTo,
		Status		='EDIT',   
		UpdateDate	= getdate(),  
		UpdateUserID  	=@UpdateUserID ,
		qcemail		= @qcemail
	where NewsletterID = @NewsletterID
	IF (@@ERROR <> 0)
	BEGIN
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	RETURN 0 

END

GO
GRANT EXECUTE ON [dbo].[usp_UpdateNewsletter] TO [webadminuser_role]
GO
