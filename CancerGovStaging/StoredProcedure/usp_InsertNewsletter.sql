IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_InsertNewsletter]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_InsertNewsletter]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO

/****** 	Object:  Stored Procedure dbo.usp_InsertNewsletter
	Owner:	Jay He
	Script Date: 3/19/2003 14:43:49 pM 
******/

CREATE PROCEDURE dbo.usp_InsertNewsletter
(
 	@NewsletterID		UniqueIdentifier,
	@OwnerGroupID	Int,
	@Section		UniqueIdentifier,
	@Title			varchar(200),
	@Description		varchar(2000),
	@From			varchar(1000),
	@ReplyTo		varchar(1000),
	@CreateUserID		varchar(50 ),
	@qcemail		varchar(1000)=NULL										
)
AS
BEGIN

	-- We only insert newsletter
	INSERT INTO  Newsletter
	(NewsletterID, OwnerGroupID, [Section], Title, [Description], ReplyTo, [From],CreateUserID, CreateDate, Status,   UpdateDate,  UpdateUserID,qcemail) 
	VALUES 
	(@NewsletterID, @OwnerGroupID, @Section, @Title, @Description, @ReplyTo, @From, @CreateUserID, getdate(), 'Edit',  getdate(), @CreateUserID,@qcemail) 
	IF (@@ERROR <> 0)
	BEGIN
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	RETURN 0 

END

GO
GRANT EXECUTE ON [dbo].[usp_InsertNewsletter] TO [webadminuser_role]
GO
