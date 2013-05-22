IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_SearchNewsletterSubscriber]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_SearchNewsletterSubscriber]
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


CREATE PROCEDURE [dbo].[usp_SearchNewsletterSubscriber] 
	(
	@NewsletterID		uniqueidentifier,
	@LoginName		varchar(40),
	@Email			varchar(200),
	@LoginSelected		varchar(10)
)
AS
BEGIN	

	select 	@LoginName		= REPLACE(@LoginName,'''',''''''),
		@Email			= REPLACE(@Email,'''','''''')
		

	IF (len(@LoginName) > 0 and len(@Email) >0)
	BEGIN
		if (@LoginSelected ='AND')
		BEGIN
			select  N.UserID, N.LoginName, N.Email, M.IsSubscribed from NCIUsers N, UserSubscriptionMap M
			where N.UserID = M.UserID and M.NewsletterID = @NewsletterID 
				and (N.LoginName like  '%' + @LoginName + '%' ) and ( N.Email like '%' + @Email +'%') 
			Order by N.LoginName
		END
		ELSE if (@LoginSelected ='OR')
		BEGIN
			select  N.UserID, N.LoginName, N.Email, M.IsSubscribed from NCIUsers N, UserSubscriptionMap M
			where N.UserID = M.UserID and M.NewsletterID = @NewsletterID 
				and (N.LoginName like  '%' + @LoginName + '%' ) Or ( N.Email like '%' + @Email +'%') 
			Order by N.LoginName
		END

	END
	Else If(len(@LoginName) > 0 and len(@Email) = 0)
	BEGIN
		select N.UserID, N.LoginName, N.Email, M.IsSubscribed  from NCIUsers N, UserSubscriptionMap M
		where N.UserID = M.UserID and M.NewsletterID = @NewsletterID 
		and (N.LoginName like '%'+ @LoginName + '%' )
		Order by N.LoginName
	END
	Else IF (len(@LoginName) = 0 and len(@Email) > 0)
	BEGIN
		select  N.UserID, N.LoginName, N.Email, M.IsSubscribed from NCIUsers N, UserSubscriptionMap M
		where N.UserID = M.UserID and M.NewsletterID = @NewsletterID 
			and ( N.Email like '%' + @Email +'%') 
		Order by N.LoginName
	END
	Else IF (len(@LoginName) = 0 and len(@Email) = 0)
	BEGIN
		select  N.UserID, N.LoginName, N.Email, M.IsSubscribed from NCIUsers N, UserSubscriptionMap M
		where N.UserID = M.UserID and M.NewsletterID = @NewsletterID 
		Order by N.LoginName
	END
END

GO
GRANT EXECUTE ON [dbo].[usp_SearchNewsletterSubscriber] TO [webadminuser_role]
GO
