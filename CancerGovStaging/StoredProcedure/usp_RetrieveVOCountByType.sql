IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_RetrieveVOCountByType]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_RetrieveVOCountByType]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--***********************************************************************
-- Create New Object 
--************************************************************************

/****** Object:  Stored Procedure dbo.usp_RetrieveViewObject
   Owner:Jhe Purpose: For admin side Script Date: 1/15/2002 16:00:49 pm ******/

CREATE PROCEDURE dbo.usp_RetrieveVOCountByType
	(
	@Type		varchar(50),
	@Para1		varchar(250),
	@Para2		varchar(250)
	)
AS
BEGIN
	declare @count int 

	if (@Type ='ADMIN')
	BEGIN
		SELECT COUNT(*) FROM UserGroupPermissionMap WHERE 
				UserID = (SELECT UserID FROM NCIUsers WHERE loginName =@Para1 ) 
			AND 	GroupID = (SELECT GroupID FROM Groups WHERE GroupIDName = 'Site Wide Admin')
	END
		

	if (@Type ='LINK')
	BEGIN
		select Count(*) from nciview where url=@Para1
	END		

	
	if (@Type ='NCISECTION')
	BEGIN
		SELECT @count = COUNT(*) FROM UserGroupPermissionMap WHERE 
				UserID = (SELECT UserID FROM NCIUsers WHERE loginName =@Para1 ) 
			AND 	GroupID = (SELECT GroupID FROM Groups WHERE GroupIDName = 'Site Wide Admin')

		if (@count =0)
		BEGIN
			SELECT count(*) 
			FROM SectionGroupMap N, UserGroupPermissionMap M 
			WHERE N.GroupID = M.GroupID and M.UserID =
				(SELECT UserID FROM NCIUsers WHERE loginName = @Para1)
		END
		ELSE
		BEGIN
			SELECT count(*) FROM NCISection
		END
	END	

	if (@Type ='NEWUSER')
	BEGIN
		Select count(*) from nciusers where loginName=@Para1
	END

	if (@Type ='PU')
	BEGIN
		select count(*) from prettyURL where proposedURL=@Para1 or currentURL=@Para1
	END					


	if (@Type ='USERGROUPMAP')
	BEGIN
		select count(*) from sectiongroupmap g, nciusers u, usergrouppermissionmap p 
		where  p.userid = u.userid and u.loginname=@Para1 and p.groupid=g.groupid
	END
			
	if (@Type ='USERLOGIN')
	BEGIN
		Select count(*) from nciusers where DateDiff(day, passwordLastUpdated, getdate()) > @Para1 and loginName=@Para2
	END

END

GO
GRANT EXECUTE ON [dbo].[usp_RetrieveVOCountByType] TO [webadminuser_role]
GO
