IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_RetrieveVOByTypeANDGroupID]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_RetrieveVOByTypeANDGroupID]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.usp_RetrieveViewObject
   Owner:Jhe Purpose: For admin side Script Date: 1/15/2002 16:00:49 pm ******/

CREATE PROCEDURE dbo.usp_RetrieveVOByTypeANDGroupID
	(
	@GroupID	int,
	@Type		varchar(50),
	@Para1		varchar(250),
	@Para2		varchar(250)
	)
AS
BEGIN
	Declare @count int

	

	
	if (@Type= 'ADMINHELP')
	BEGIN	
		SELECT @count = COUNT(*) FROM UserGroupPermissionMap WHERE 
				UserID = (SELECT UserID FROM NCIUsers WHERE loginName =@Para1 ) 
			AND 	GroupID = (SELECT GroupID FROM Groups WHERE GroupIDName = 'Site Wide Admin')

		if (@count =0)
		BEGIN
			PRint 'exp 0'
			SELECT TOP 3 ShortTitle, link='DocPreView.aspx?NCIViewID='+ CONVERT(varchar(38), NCIViewID)  
			from NCIView WHERE Status ='Edit' and NCISectionID in (
					SELECT distinct N.SectionID 
					FROM SectionGroupMap N, UserGroupPermissionMap M 
					WHERE N.GroupID = M.GroupID and M.UserID =
						 (SELECT UserID FROM NCIUsers WHERE loginName = @Para1)
			)   ORDER BY UpdateDate DESC
		END
		ELSE
		BEGIN
			PRint 'exp 1'
			SELECT TOP 3 ShortTitle, link='DocPreView.aspx?NCIViewID='+ CONVERT(varchar(38), NCIViewID)  
			from NCIView WHERE Status ='Edit' and NCISectionID in (
				SELECT distinct NCISectionID FROM NCISection
			)    ORDER BY UpdateDate DESC
		END
	END

	if (@Type= 'EXPIRINGSOON')
	BEGIN	
		SELECT @count = COUNT(*) FROM UserGroupPermissionMap WHERE 
				UserID = (SELECT UserID FROM NCIUsers WHERE loginName =@Para1 ) 
			AND 	GroupID = (SELECT GroupID FROM Groups WHERE GroupIDName = 'Site Wide Admin')

		if (@count =0)
		BEGIN
			PRint 'exp 0'
			SELECT TOP 3 ShortTitle,  'Link'=url + IsNull(NullIf( '?'+IsNull(URLArguments,''),'?'),'')   
			from NCIView 
			WHERE DATEDIFF(day,  GETDATE(), ExpirationDate) <=@Para2 and NCISectionID in (
					SELECT distinct N.SectionID 
					FROM SectionGroupMap N, UserGroupPermissionMap M 
					WHERE N.GroupID = M.GroupID and M.UserID =
						 (SELECT UserID FROM NCIUsers WHERE loginName = @Para1)
			)  ORDER BY ExpirationDate
		END
		ELSE
		BEGIN
			PRint 'exp 1'
			SELECT TOP 3 ShortTitle,  'Link'=url + IsNull(NullIf( '?'+IsNull(URLArguments,''),'?'),'')   
			from NCIView 
			WHERE DATEDIFF(day,  GETDATE(), ExpirationDate) <=@Para2 and NCISectionID in (
				SELECT distinct NCISectionID FROM NCISection
			)  ORDER BY ExpirationDate
		END
	END

	if (@Type= 'TOBEAPPROVED')
	BEGIN	
		SELECT @count = COUNT(*) FROM UserGroupPermissionMap WHERE 
				UserID = (SELECT UserID FROM NCIUsers WHERE loginName =@Para1 ) 
			AND 	GroupID = (SELECT GroupID FROM Groups WHERE GroupIDName = 'Site Wide Admin')

		if (@count =0)
		BEGIN
			PRint 'exp 0'
			SELECT Distinct Link='PagePreview.aspx?TaskID='+ CONVERT(varchar(38), T.TaskID), ShortTitle=T.Name, T.UpdateDate  
			from Task T, TaskStep S, UserGroupPermissionMap M, Groups G, [Permissions] P, NCIUsers U 
			WHERE T.TaskID = S.TaskID and T.ResponsibleGroupID = G.GroupID and G.GroupID = M.GroupID and M.PermissionID = P.PermissionID 
				and M.UserID = U.UserID AND U.LoginName=@Para1 and T.Status ='Executing' AND 
				P.PermissionNAme='Approve'  and T.Type=1
				ORDER BY T.UpdateDate Desc
		END
		ELSE
		BEGIN
			PRint 'exp 1'
			SELECT Distinct Link='PagePreview.aspx?TaskID='+ CONVERT(varchar(38), TaskID), ShortTitle=Name, UpdateDate  from Task 
			WHERE Status ='Executing'  and Type=1 ORDER BY UpdateDate Desc
		END
	END

					

	if (@Type ='GROUP')
	BEGIN
		select GroupName, GroupIDName, AdminEmail, ParentGroupID, TypeID, IsActive from Groups where GroupID=@GroupID	

		select GroupName, GroupID from Groups where groupID !=@GroupID order by GroupName
	
		select distinct S.Name, S.NCISectionID from SectionGroupMap M, NCISection S where S.NCISectionID= M.SectionID and M.GroupID =@GroupID
				
	END			

	if (@Type ='GROUPINFO')
	BEGIN
		select GroupName, GroupIDName, AdminEmail, ParentGroupID, TypeID, IsActive from Groups where GroupID=@GroupID				
	END		

	if (@Type ='GROUPSECTION')
	BEGIN
		SELECT Distinct N.Name, N.NCISectionID FROM NCISection N, SectionGroupMap S 
		where  N.NCISectionID = S.SectionID and S.GroupID =@GroupID order by N.Name
	END	

	if (@Type ='INBOX')
	BEGIN
		execute 
		(
			'SELECT TOP  ' + @Para1 +'  MessageID, NCIUsers.LoginName AS [From], Subject, SendDate AS [Send Date] 
			FROM NCIMessage, NCIUsers 
			WHERE NCIUsers.UserID = NCIMessage.SenderID AND RecipientID = 
				(SELECT UserID FROM NCIUsers WHERE LoginName =''' + @Para2 + ''') 
			ORDER BY [Send Date] DESC'
		)
	END		


	if (@Type ='GROUPMAP')
	BEGIN
		SELECT DISTINCT UserID FROM UserGroupPermissionMap WHERE GroupID = @GroupID
	END				

	if (@Type ='PERMISSION')
	BEGIN
			Select distinct N.LoginName as [User Name], M.UserId As UserID, M.GroupID As GroupID, G.GroupName As [Group Name] 
			from UserGroupPermissionMap M, NCIUsers N, Groups G
			where G.GroupID= M.GroupID and M.UserID= N.UserId and M.groupID=@GroupID Order by [User Name]
			
			SELECT UserID As ID, LoginName As Name FROM NCIUsers 
			where UserID not in (select distinct UserID from UserGroupPermissionMap where GroupID =@GroupID ) ORDER BY LoginName
	END
	
	
END
GO
GRANT EXECUTE ON [dbo].[usp_RetrieveVOByTypeANDGroupID] TO [webadminuser_role]
GO
