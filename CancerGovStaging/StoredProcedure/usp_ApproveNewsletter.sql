IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_ApproveNewsletter]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_ApproveNewsletter]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/****** 	Object:  Stored Procedure dbo.usp_InsertNewsletter
	Owner:	Jay He
	Script Date: 3/19/2003 14:43:49 pM 
******/

CREATE PROCEDURE dbo.usp_ApproveNewsletter
(
 	@NewsletterID		UniqueIdentifier,
 	@UpdateUserID		varchar(50)										
)
AS
BEGIN

	-- We only insert newsletter
	Update Newsletter
	set 
		Status		='APPROVED',   
		UpdateDate	= getdate(),  
		UpdateUserID  	=@UpdateUserID  
	where NewsletterID = @NewsletterID
	IF (@@ERROR <> 0)
	BEGIN
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	RETURN 0 

END
GO
GRANT EXECUTE ON [dbo].[usp_ApproveNewsletter] TO [webadminuser_role]
GO
