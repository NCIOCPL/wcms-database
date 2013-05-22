IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_RetrieveVOCountByTypeANDGroupID]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_RetrieveVOCountByTypeANDGroupID]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.usp_RetrieveViewObject
   Owner:Jhe Purpose: For admin side Script Date: 1/15/2002 16:00:49 pm ******/

CREATE PROCEDURE dbo.usp_RetrieveVOCountByTypeANDGroupID
	(
	@GroupID	int,
	@Type		varchar(50),
	@Para1		varchar(250),
	@Para2		varchar(250)
	)
AS
BEGIN
	if (@Type ='LINK')
	BEGIN
		select Count(*) from nciview where url=@Para1
	END		

	if (@Type ='LIVEHELP')
	BEGIN
		select count(*) from UserGroupPermissionMap M, NCIUsers N 
		WHERE N.USERID= M.UserID AND N.LoginName=@Para1 and M.GroupID=@GroupID
	END

	if (@Type ='GROUPNAME')
	BEGIN
		select count(*) from Groups where GroupName =@Para1 and GroupID <>@GroupID
	END			

	if (@Type ='GROUPIDNAME')
	BEGIN
		select count(*) from Groups where GroupIDName =@Para1 and GroupID <>@GroupID
	END

	if (@Type ='USERGROUPMAP')
	BEGIN
		Select count(*) from UserGroupPermissionMap where GroupID=@GroupID 
		 and PermissionID=@Para1 and UserID=@Para2
	END

END
GO
GRANT EXECUTE ON [dbo].[usp_RetrieveVOCountByTypeANDGroupID] TO [webadminuser_role]
GO
