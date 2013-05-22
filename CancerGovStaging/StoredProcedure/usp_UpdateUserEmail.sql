IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_UpdateUserEmail]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_UpdateUserEmail]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--***********************************************************************
-- Create New Object 
--************************************************************************
/****** Object:  Stored Procedure dbo.usp_UpdateNCIView   Owner:Jhe Purpose: For admin side Script Date: 1/15/2002 16:00:49 pm ******/		
	/****** Object:  Stored Procedure dbo.usp_UpdateNCIView   Owner:Jhe Purpose: For admin side Script Date: 1/15/2002 16:00:49 pm ******/		
					
	/****** Object:  Stored Procedure dbo.usp_searchnewslettersubscriber
* Owner:Jhe 
* Purpose: For admin side Script Date: 10/07/2003 16:00:49 pm ******/


/****** 	Object:  Stored Procedure dbo.usp_UpdateLink
	Owner:	Jay He
	Script Date: 3/17/2003 14:43:49 pM 
******/

CREATE PROCEDURE dbo.usp_UpdateUserEmail
(
	@UserID 			UniqueIdentifier,
	@Email				varChar(200),
	@LoginName			varChar(40),
	@UpdateUserID  		VarChar(50)
)
AS
BEGIN

	UPDATE NCIusers
	set 	Email = @Email,
		LoginName = @LoginName,
		UpdateUserID= @UpdateUserID
	where  UserID = @UserID
	IF (@@ERROR <> 0)
	BEGIN
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	RETURN 0 

END

GO
GRANT EXECUTE ON [dbo].[usp_UpdateUserEmail] TO [webadminuser_role]
GO
