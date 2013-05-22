IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_SearchSpecial]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_SearchSpecial]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



--***********************************************************************
-- Create New Object 
--************************************************************************

/****** Object:  Stored Procedure dbo.usp_RetrieveNCIView  
* Owner:Jhe 
* Purpose: For admin side Script Date: 10/07/2003 16:00:49 pm ******/



CREATE PROCEDURE [dbo].[usp_SearchSpecial] 
	(
	@Type			varchar(20),
	@UserName		varchar(50),
	@Diff			varchar(100),
	@PreviewURL		varchar(500)
)
AS
BEGIN	
	Declare
		@count 		int

	SELECT @count = COUNT(*) FROM UserGroupPermissionMap WHERE UserID = 
		(SELECT UserID FROM NCIUsers WHERE loginName =  @UserName  ) AND GroupID = 
		(SELECT GroupID FROM Groups WHERE GroupIDName = 'Site Wide Admin')


	if (@Type ='TOBEAPPROVED')
	BEGIN
		if (@count >0)
		BEGIN
			SELECT Distinct 'NCIViewID'= T.TaskID, 'Name'= Replace(T.Name,'''''',''''), T.Status, T.Importance, T.Notes, 'Updated'=Convert(varchar,T.UpdateDate,102), G.GroupName , T.UpdateUserID 
			from Task T, Groups G 
			WHERE G.GroupID=T.ResponsibleGroupID and T.Status ='Executing' 
				and T.Type=1
			ORDER BY 'Updated' Desc
		END
		else
		BEGIN
			SELECT Distinct 'NCIViewID'=T.TaskID, 'Name'= Replace(T.Name,'''''',''''), T.Status, T.Importance, T.Notes, 'Updated'=Convert(varchar,T.UpdateDate,102), G.GroupName  , T.UpdateUserID 
			from Task T, TaskStep S, UserGroupPermissionMap M, Groups G, [Permissions] P, NCIUsers U 
			WHERE T.TaskID = S.TaskID and T.ResponsibleGroupID = G.GroupID and G.GroupID = M.GroupID and M.PermissionID = P.PermissionID 
			and T.Type=1 and M.UserID = U.UserID AND U.LoginName=@UserName and 
			T.Status ='Executing' AND P.PermissionNAme='Approve' ORDER BY 'Updated' Desc
		END
	END					
	ELSE if (@Type ='ADMINHELP')
	BEGIN
		if (@Count >0)
		BEGIN
			SELECT N.NCIViewID, case LEFT(N.url , 7) when 'https:/'  then N.Title + '<br><a href="' + N.url+ '">' + N.url+ '</a>' when 'http://' then N.Title + '<br><a href="' + N.url+ '">' + N.url+ '</a>'
else  N.Title + '<br><a href="' + @PreviewURL + N.url + IsNull(NullIf( '?'+IsNull(N.URLArguments,''),'?'),'') + '">' + N.url + IsNull(NullIf( '?'+IsNull(N.URLArguments,''),'?'),'') + '</a>' end as 'Title/URL',
			'Short Title'=N.ShortTitle, N.Description, 'Owner Group'=G.GroupName, 'Updated'=Convert(varchar,N.UpdateDate,102), 'Expires'=Convert(varchar,N.ExpirationDate,102) 
			FROM NCIView N, Groups G 
			WHERE N.GroupID=G.GroupID AND N.NCISectionID in (SELECT distinct NCISectionID FROM NCISection)
			 AND N.Status ='Edit' ORDER BY 'Updated'
		END
		ELSE
		BEGIN
			SELECT N.NCIViewID, case LEFT(N.url , 7) when 'https:/'  then N.Title + '<br><a href="' + N.url+ '">' + N.url+ '</a>' when 'http://' then N.Title + '<br><a href="' + N.url+ '">' + N.url+ '</a>'
else  N.Title + '<br><a href="' + @PreviewURL + N.url + IsNull(NullIf( '?'+IsNull(N.URLArguments,''),'?'),'') + '">' + N.url + IsNull(NullIf( '?'+IsNull(N.URLArguments,''),'?'),'') + '</a>' end as 'Title/URL',
			'Short Title'=N.ShortTitle, N.Description, 'Owner Group'=G.GroupName, 'Updated'=Convert(varchar,N.UpdateDate,102), 'Expires'=Convert(varchar,N.ExpirationDate,102) 
			FROM NCIView N, Groups G 
			WHERE N.GroupID=G.GroupID AND N.NCISectionID in 
			(
				SELECT distinct N.SectionID FROM SectionGroupMap N, UserGroupPermissionMap M 
				WHERE N.GroupID = M.GroupID and M.UserID = (SELECT UserID FROM NCIUsers WHERE loginName = @UserName)
			)
			 AND N.Status ='Edit' ORDER BY 'Updated'
		END
	END
	ELSE if (@Type ='EXPIRINGSOON')
	BEGIN
		if (@Count >0)
		BEGIN
			SELECT N.NCIViewID, case LEFT(N.url , 7) when 'https:/'  then N.Title + '<br><a href="' + N.url+ '">' + N.url+ '</a>' when 'http://' then N.Title + '<br><a href="' + N.url+ '">' + N.url+ '</a>'
else  N.Title + '<br><a href="' + @PreviewURL + N.url + IsNull(NullIf( '?'+IsNull(N.URLArguments,''),'?'),'') + '">' + N.url + IsNull(NullIf( '?'+IsNull(N.URLArguments,''),'?'),'') + '</a>' end as 'Title/URL',
'Short Title'=N.ShortTitle, N.Description, 'Owner Group'=G.GroupName, 'Updated'=Convert(varchar,N.UpdateDate,102), 'Expires'=Convert(varchar,N.ExpirationDate,102) 
			FROM NCIView N, Groups G 
			WHERE N.GroupID=G.GroupID AND N.NCISectionID in 
			 (SELECT distinct NCISectionID FROM NCISection)
			and DATEDIFF(day,  GETDATE(), N.ExpirationDate) <=@Diff ORDER BY 'Expires'
		END
		ELSE
		BEGIN
			SELECT N.NCIViewID, case LEFT(N.url , 7) when 'https:/'  then N.Title + '<br><a href="' + N.url+ '">' + N.url+ '</a>' when 'http://' then N.Title + '<br><a href="' + N.url+ '">' + N.url+ '</a>'
else  N.Title + '<br><a href="' + @PreviewURL + N.url + IsNull(NullIf( '?'+IsNull(N.URLArguments,''),'?'),'') + '">' + N.url + IsNull(NullIf( '?'+IsNull(N.URLArguments,''),'?'),'') + '</a>' end as 'Title/URL',
'Short Title'=N.ShortTitle, N.Description, 'Owner Group'=G.GroupName, 'Updated'=Convert(varchar,N.UpdateDate,102), 'Expires'=Convert(varchar,N.ExpirationDate,102) 
			FROM NCIView N, Groups G 
			WHERE N.GroupID=G.GroupID AND N.NCISectionID in 
			(
				SELECT distinct N.SectionID FROM SectionGroupMap N, UserGroupPermissionMap M 
				WHERE N.GroupID = M.GroupID and M.UserID = (SELECT UserID FROM NCIUsers WHERE loginName = @UserName)
			)
			and DATEDIFF(day,  GETDATE(), N.ExpirationDate) <=@Diff ORDER BY 'Expires'
		END
	END					
	ELSE if (@Type = 'TWO')
	BEGIN
		SELECT N.NCIViewID, case LEFT(N.url , 7) when 'https:/'  then N.Title + '<br><a href="' + N.url+ '">' + N.url+ '</a>' when 'http://' then N.Title + '<br><a href="' + N.url+ '">' + N.url+ '</a>'
else  N.Title + '<br><a href="' + @PreviewURL + N.url + IsNull(NullIf( '?'+IsNull(N.URLArguments,''),'?'),'') + '">' + N.url + IsNull(NullIf( '?'+IsNull(N.URLArguments,''),'?'),'') + '</a>' end as 'Title/URL',
 'Short Title'=N.ShortTitle, N.Description,  'Owner Group'=G.GroupName, 'Created'=Convert(varchar, N.CreateDate,102), 'Expires'=Convert(varchar,N.ExpirationDate,102) 
		FROM NCIView N, Groups G 
		WHERE N.GroupID=G.GroupID AND N.NCISectionID = 
		(
			SELECT NCISectionID FROM NCISection WHERE Name =@UserName 
		)
		AND DATEDIFF(day, N.CreateDate, GETDATE()) <= @Diff
		ORDER BY N.CreateDate DESC, N.ShortTitle ASC
	END
	Else if (@Type ='REVIEWXHTML')
	BEGIN
		if (@count >0)
		BEGIN
			SELECT Distinct T.TaskID, 'Name'= Replace(T.Name,'''''',''''), 'Updated'=Convert(varchar,T.UpdateDate,126), G.GroupName , T.UpdateUserID, N.NCISectionID, NS.Name  as 'Section', @Diff+'/page/PagePreview.aspx?TaskID='+ Convert(varchar(40), T.TaskID) as URL
			from Task T, Groups G, NCIView N, NCISection  NS
			WHERE G.GroupID=T.ResponsibleGroupID and T.Status ='Executing' 
				and T.Type=2 and T.ObjectID = N.NCIViewID and N.NCISectionID = NS.NCISectionID
			ORDER BY 'Updated' Desc
		END
		else
		BEGIN
			SELECT Distinct T.TaskID, 'Name'= Replace(T.Name,'''''',''''), 'Updated'=Convert(varchar,T.UpdateDate,126), G.GroupName  , T.UpdateUserID , N.NCISectionID , NS.Name as 'Section', @Diff+'/page/PagePreview.aspx?TaskID='+ Convert(varchar(40), T.TaskID)  as URL
			from Task T, TaskStep S, UserGroupPermissionMap M, Groups G, [Permissions] P, NCIUsers U, NCIView N, NCISection  NS  
			WHERE T.TaskID = S.TaskID and T.ResponsibleGroupID = G.GroupID and G.GroupID = M.GroupID and M.PermissionID = P.PermissionID 
			and T.Type=2 and T.ObjectID = N.NCIViewID and M.UserID = U.UserID AND U.LoginName=@UserName and N.NCISectionID = NS.NCISectionID and 
			T.Status ='Executing' AND P.PermissionNAme='Approve' ORDER BY 'Updated' Desc
		END
	END		




END



GO
-- Permissions

GRANT EXECUTE ON  [dbo].[usp_SearchSpecial] TO [webadminuser_role]