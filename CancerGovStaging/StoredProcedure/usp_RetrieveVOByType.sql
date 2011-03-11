IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_RetrieveVOByType]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_RetrieveVOByType]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






--***********************************************************************
-- Create New Object 
--************************************************************************




--***********************************************************************
-- Create New Object 
--************************************************************************

/****** Object:  Stored Procedure dbo.usp_RetrieveViewObject
   Owner:Jhe Purpose: For admin side Script Date: 1/15/2002 16:00:49 pm ******/

CREATE PROCEDURE dbo.usp_RetrieveVOByType
	(
	@Type		varchar(50),
	@Title		varchar(50)
	)
AS
BEGIN

	if (@Type= 'ASSIGNPERMISSION')
	BEGIN
		SELECT GroupID, GroupIDName FROM Groups ORDER BY GroupIDName ASC
		
		SELECT UserID, LoginName FROM NCIUsers 
		where UserID in 
			(	SELECT Distinct N.UserID  FROM NCIusers N, UserGroupPermissionMap M, Groups G 
			WHERE N.UserID = M.UserID and M.GroupID = G.GroupId and (G.TypeID =1 or G.TypeID=2) 
			)
		ORDER BY LoginName ASC
		
		SELECT PermissionID, PermissionName FROM Permissions ORDER BY PermissionName ASC
	END

	if (@Type= 'CANCERLIT')
	BEGIN
		select groupID from groups where GroupName='Cancer Lit'
	END

	if (@Type= 'CONTENTHEADERVIEW')
	BEGIN
		SELECT HeaderID, Name, UpdateUserID, IsApproved, dbo.udf_isvalidXHTML(data, 'c:\\Temp\\xhtml1-transitional.dtd') as isvalidXHTML from Header where Type ='ContentHeader' order by Name 
	END	

	if (@Type= 'CONTENTHEADERRELATED')
	BEGIN
		SELECT N.NCIViewID, H.HeaderID, N.Title, H.Name as Header from Header H, ViewObjects V, NCIView N 
		where  H.HeaderID= @Title and N.NCIviewID =V.NCIViewID and V.ObjectID= H.HeaderID and V.Type='HEADER' and H.Type ='ContentHeader' order by H.Name, N.Title
	END
	
	if (@Type= 'DEFAULTSITE')
	BEGIN
		select NCISiteID from NCISite where Name='Cancer.gov'
	END

	if (@Type= 'DIRECTORY')
	BEGIN	
		SELECT D.DirectoryID, N.NCISectionID, D.DirectoryName, 'Section'=N.Name, 'Update'=Convert(varchar,D.UpdateDate,101) + ' by ' + D.UpdateUserID 
		FROM NCIsection N, Directories D, SectionDirectoryMap M 
		WHERE D.DirectoryID = M.DirectoryID and M.SectionID= N.NCISectionID ORDER BY D.UpdateDate DESC
	END


				
	if (@Type= 'GROUPVIEW')
	BEGIN
		SELECT G.GroupID, G.GroupName, G.GroupIDName, G.AdminEmail, T.TypeName, 'Parent'=isnull(S.GroupName,''), 
		'Update'= G.UpdateUserID +' ' + Convert(varchar, G.UpdateDate,101) 
		from Groups G inner join GroupTypes T
		on T.TypeID = G.TypeID 
		left join Groups S 
		on G.ParentGroupID = S.GroupID Order by G.GroupName
	END

	if (@Type= 'GROUP')
	BEGIN
		--select GroupName, GroupID, GroupIDName  from Groups  Order by GroupName
		select GroupName, GroupID, GroupIDName  from Groups  where groupid in (select distinct groupid from SectionGroupMap) Order by GroupName
	END

	if (@Type= 'GROUPALL')
	BEGIN
		select GroupName, GroupID, GroupIDName  from Groups  Order by GroupName
	END

	if (@Type= 'GROUPID')
	BEGIN
		SELECT GroupID FROM Groups WHERE GroupIDName = @Title
	END

	if (@Type= 'GROUPNAME') -- used in security.cs
	BEGIN
		SELECT GroupID FROM Groups WHERE GroupName = @Title
	END

	if (@Type= 'GROUPSEND')
	BEGIN
		select GroupName, GroupID, GroupIDName  from Groups  Order by GroupName

		SELECT UserID, LoginName 
		FROM NCIUsers 
		where UserID in 
			(SELECT Distinct N.UserID  FROM NCIusers N, UserGroupPermissionMap M, Groups G 
			WHERE N.UserID = M.UserID and M.GroupID = G.GroupId and (G.TypeID =1 or G.TypeID=2) )
		ORDER BY LoginName 
	END

	if (@Type= 'GROUPSEARCH')
	BEGIN
		select 'ID'= GroupID, 'Name'= GroupName, 'Type'='Group' from Groups where groupName like '%' +@Title+ '%'
	END
			
	if (@Type= 'GROUPTYPE')
	BEGIN
		select TypeName, TypeID from GroupTypes order by TypeName
	END

	if (@Type= 'GROUPSECTION')
	BEGIN
		SELECT G.GroupID, N.NCISectionID, G.GroupName, 'Section'=N.Name, 'Updated'=Convert(varchar,S.UpdateDate,101) + ' by ' + S.UpdateUserID 
		FROM NCIsection N, Groups G, SectionGroupMap S 
		WHERE S.SectionID = N.NCISectionID and S.GroupID=G.GroupID
		ORDER BY S.UpdateDate DESC
	END




	if (@Type= 'HEADERVIEW')
	BEGIN
		SELECT HeaderID, Name, ContentType, UpdateUserID, IsApproved from Header where Type ='Header' order by Name
	END	
	
	if (@Type= 'HEADER')
	BEGIN
		SELECT Distinct ContentType from Header where Type= 'Header' order by ContentType
	END

	if (@Type= 'HEADERRELATED')
	BEGIN		
		SELECT N.NCIViewID, H.HeaderID, N.Title, H.Name as Header, H.ContentType  from Header H, ViewObjects V, NCIView N 
		where N.NCIviewID =V.NCIViewID and V.ObjectID= H.HeaderID and V.Type='Header' and H.Type='Header' order by  H.Name, N.Title
	END	

	if (@Type= 'LIVEHELP')
	BEGIN		
		Select PropertyValue from SiteProperties WHERE PropertyName='LiveHelp'
	END

	if (@Type= 'MESSAGE')
	BEGIN		
		SELECT MessageID,'Subject'='<a href=Message.aspx?MessageID=' + CONVERT(Varchar(38), MessageID) +'>' + Subject + '</a>',  
			NCIUsers.LoginName AS [From], 'Send Date'=SendDate 
		FROM NCIMessage, NCIUsers 
		WHERE NCIUsers.UserID = NCIMessage.SenderID AND RecipientID 
			= (SELECT UserID FROM NCIUsers WHERE LoginName = @Title) 
		order by senddate
	END			

	if (@Type= 'NCISECTION')
	BEGIN
		--SELECT NCISectionID, Name, SectionHomeViewID, URL, 'Update'= UpdateUserID +' ' + Convert(varchar, UpdateDate,101)  from NCISection order by orderlevel
		-- update 04/12/2004 for Redesign, include parentsection
		/*SELECT N.NCISectionID, N.Name, N.SectionHomeViewID, NS.Name as 'SiteName', isnull(S.Name,'') as 'ParentName', N.URL, 
		'Update'= N.UpdateUserID +' ' + Convert(varchar, N.UpdateDate,101)  
		from NCISite NS, NCISection N left join NCISection S 
		on  N.ParentSectionID = S.NCISectionID
		where NS.NCISiteID = N.SiteID
		order by N.orderlevel
		*/
		select  S.NCISectionID, S.SectionHomeViewID, S.Name, O.NCIObjectID, NS.Name as 'SiteName', isnull(N.Name,'') as 'ParentName', S.URL, 
		'Update'= S.UpdateUserID +' ' + Convert(varchar, S.UpdateDate,101)  
		from NCISite NS, NCIObjects O, NCISection S left join NCISection N 
		on  S.ParentSectionID = N.NCISectionID
		where O.ObjectType='LeftNav' and O.parentNCIobjectID = S.NCISectionID and  NS.NCISiteID = S.SiteID
		Order By S.OrderLevel
	END	


	if (@Type= 'NCISECTIONLEFTNAV')
	BEGIN
		select  S.Name, O.NCIObjectID
		from NCISite NS, NCIObjects O, NCISection S left join NCISection N 
		on  S.ParentSectionID = N.NCISectionID
		where O.ObjectType='LeftNav' and O.parentNCIobjectID = S.NCISectionID and  NS.NCISiteID = S.SiteID
		Order By S.Name
	END	

	if (@Type= 'NCISECTIONHOMELEFTNAV')
	BEGIN
		select  S.Name, O.NCIObjectID
		from NCISite NS, NCIObjects O, NCISection S 
		where O.ObjectType='LeftNav' and O.parentNCIobjectID = S.SectionHomeViewID and  NS.NCISiteID = S.SiteID
		Order By S.Name
	END	

	if (@Type= 'NCISECTIONGET')
	BEGIN
		SELECT NCISectionID FROM NCISection WHERE Name =@Title
	END
			
	if (@Type= 'NCISECTIONNAME')
	BEGIN
		SELECT Distinct N.Name FROM NCISection N, SectionGroupMap M, Groups G 
		where N.NCISectionID= M.SectionID and M.GroupID = G.GroupID and G.GroupName =@Title ORDER BY Name ASC
	END	

	if (@Type= 'NCISECTIONID')
	BEGIN
		SELECT Distinct N.Name, N.NCISectionID FROM NCISection N, SectionGroupMap S, UserGroupPermissionMap M, [Permissions] P, NCIUsers U 
		WHERE N.NCISectionID =S.SectionID and S.GroupID= M.GroupID and M.PermissionID = P.PermissionID and M.UserID = U.UserID AND 
			U.LoginName=@Title AND P.PermissionNAme='ADD'  ORDER BY N.Name ASC
	END			
	
	if (@Type= 'NCISITE')
	BEGIN
		SELECT NCISiteID, [Name], [Description], 'Update'= UpdateUserID +' ' + Convert(varchar, UpdateDate,101)   FROM NCISite
	END

	if (@Type= 'NCIOBJECT')
	BEGIN
		SELECT NCIObjectID, Name, TableName,'Update'= UpdateUserID +' ' + Convert(varchar, UpdateDate,101) from NCIObject Order by Name
	END

	if (@Type= 'NEWSLETTER')
	BEGIN
		SELECT Distinct G.GroupName, G.GroupID FROM Groups G, UserGroupPermissionMap M, [Permissions] P, NCIUsers U
		 WHERE  G.GroupID = M.GroupID and M.PermissionID = P.PermissionID and M.UserID = U.UserID AND U.LoginName=@Title 
		AND P.PermissionNAme='ADD'  and G.groupid in (select distinct groupid from SectionGroupMap)  ORDER BY G.GroupName ASC
	END	

	if (@Type= 'NEWSLETTERTITLE')
	BEGIN
		SELECT Distinct N.Title, N.NewsletterID FROM Newsletter N, UserGroupPermissionMap M, [Permissions] P, NCIUsers U 
		WHERE  N.OwnerGroupID = M.GroupID and M.PermissionID = P.PermissionID and M.UserID = U.UserID AND
			 U.LoginName=@Title AND P.PermissionNAme='ADD'  ORDER BY N.Title ASC
	END

	if (@Type= 'NEWSLETTERSECTION')
	BEGIN
		SELECT Distinct N.Name, N.NCISectionID FROM NCISection N, SectionGroupMap M, Groups G 
		where N.NCISectionID= M.SectionID and M.GroupID = G.GroupID and G.GroupID  =@Title ORDER BY N.Name ASC
	END


						
		
	if (@Type= 'NEWSLETTERGROUP')
	BEGIN
		select Distinct G.GroupName, G.GroupID From Groups G, GroupTypes T 
		Where G.TypeID = T.TypeID and T.TypeName ='subscription' order by G.GroupName
	END

	if (@Type= 'NEWSLETTERSECTIONBYNAME')
	BEGIN
		SELECT Distinct N.Name, N.NCISectionID FROM NCISection N, SectionGroupMap M, Groups G 
		where N.NCISectionID= M.SectionID and M.GroupID = G.GroupID and G.GroupName =@Title  ORDER BY Name ASC
	END			

	if (@Type ='NEWUSER')
	BEGIN
		SELECT UserID, LoginName AS [User ID], Email, Convert(varchar,RegistrationDate,101) AS [Create Date], Convert(varchar,UpdateDate,101) AS [Updated Date] , 
		UpdateUserID FROM NCIUsers
		where  LoginName =@Title
	END	

	if (@Type ='PERMISSION')
	BEGIN
		SELECT PermissionID, PermissionName FROM Permissions ORDER BY PermissionName ASC
	END

	if (@Type ='PRETTYURL')
	BEGIN
		select RealURL from prettyURL where proposedURL=@Title or currentURL=@Title
	END					

	if (@Type ='PRETTYURLDRUGINFO')
	BEGIN
		select p.CurrentURL, p.NCIViewID from CancerGov.dbo.prettyURL p 
			inner join CancerGov.dbo.NCIView n on n.nciviewid= p.nciviewid
		 where p.isroot=1 and p.isprimary=1 and n.ncisectionid='F2901263-4A99-44A8-A1DA-92B16E173E86'

	END	
	if (@Type= 'SEARCHSECTION')
	BEGIN
		SELECT distinct S.Name, S.NCISectionID FROM NCISection S, SectionGroupMap N, UserGroupPermissionMap M 
		WHERE S.NCISectionID = N.SectionID and N.GroupID = M.GroupID and 
		M.UserID = (SELECT UserID FROM NCIUsers WHERE loginName =@Title)
	END

	if (@Type= 'SECTION')
	BEGIN
		SELECT Name, NCISectionID, ParentSectionID  FROM NCISection where ncisectionid in (select distinct ncisectionid from SectionGroupMap) Order by  Name
	END

	if (@Type= 'SUBSCRIPTION')
	BEGIN	
		select Distinct n.newsletterid, n.title, 'Owner' = g.groupname , s.Name as 'Section', n.replyto, n.status ,n.qcemail  
		from newsletter n, groups g, ncisection s 
		where s.NCIsectionID = n.Section and  n.ownergroupid =g.groupid order by n.title
	END

	if (@Type= 'SUBSCRIPTIONLOGIN')
	BEGIN		
		select Distinct n.newsletterid, n.title, 'Owner' = g.groupname , s.Name as 'Section ', n.replyto, n.status,n.qcemail  
		from newsletter n, groups g,  nciusers u, usergrouppermissionmap ugp, ncisection s  where  s.NCIsectionID = n.Section and n.ownergroupid =g.groupid 
		and u.UserID = ugp.UserID and ugp.groupID=g.groupid and u.LoginName=@Title order by n.title
	END	

	
	if (@Type= 'TASK')
	BEGIN
		if ( @Title='1')
		BEGIN
			SELECT Distinct ' '='<a href=PagePreview.aspx?TaskID='+ CONVERT(varchar(38), TaskID) + '>Edit</a>',  'Name'=Replace(Name, '''''',''''), Status, 
			Importance, Notes, 'Updated'=UpdateDate 
			from Task t where type=@Title ORDER BY UpdateDate Desc
		END
		ELSE
		BEGIN

			SELECT Distinct ' '='<a href=NCIViewRedirect.aspx?ReturnURL=&NCIViewID='+ CONVERT(varchar(38), ObjectID) + '>Edit</a>', '<a href=PagePreview.aspx?TaskID='+ CONVERT(varchar(38), TaskID) + '>'+ Replace(Name, '''''','''') +'</a>' as Name, Status, 
			Importance, Notes, 'Updated'=UpdateDate   , (select top 1 updateuserid from dbo.taskstep s where t.taskid = s.taskid and isauto = 0 and s.status in ('completed','Canceled') order by orderlevel) as ReviewUser,
	(select top 1 a.argumentvalue from taskstepargument a
	inner join taskstep ts on ts.stepID = a.stepID
	where ts.taskid=t.taskID and a.ForProcedureX=1 and a.argumentordinal=5 order by a.updatedate desc) as submitter 
			from Task t where type=@Title ORDER BY UpdateDate Desc
		END
	END



	if (@Type= 'TASKLOGIN')
	BEGIN
		SELECT Distinct ' '='<a href=PagePreview.aspx?TaskID='+ CONVERT(varchar(38), T.TaskID) + '>Edit</a>', 'Name'=Replace(T.Name, '''''',''''), T.Status, 
		T.Importance, T.Notes, 'Updated'=T.UpdateDate 
		 from Task T, TaskStep S, UserGroupPermissionMap M, Groups G, [Permissions] P, NCIUsers U 
		WHERE T.TaskID = S.TaskID and T.ResponsibleGroupID = G.GroupID and G.GroupID = M.GroupID 
		and M.PermissionID = P.PermissionID and M.UserID = U.UserID AND U.LoginName=@Title ORDER BY T.UpdateDate Desc
					
	END

	if (@Type= 'TEMPLATE')
	BEGIN

		SELECT NCITemplateID, Name, URL, Description, 'Update'= UpdateUserID +' ' + Convert(varchar, UpdateDate,101), ClassName 
		from NCITemplate where isnew=1
		Order by Name
	END	

	if (@Type= 'TEMPLATENEWPAGE')
	BEGIN

		SELECT Name 
		from NCITemplate 
		Where isnew=1
		Order by Name
	END	

	
	if (@Type= 'TEMPLATETYPE')
	BEGIN		
		Select NCITemplateID, addURL, EditURL from NCITemplate WHERE Name =@Title
	END			

	

	if (@Type ='URL')
	BEGIN
		SELECT NCIViewID, Title, ShortTitle, Description, URL FROM NCIView WHERE URL = @Title
	END

	if (@Type ='USERLOGIN')
	BEGIN
		SELECT [Password], userID FROM NCIusers WHERE loginName=@Title
	END	

	if (@Type ='USER')
	BEGIN
		SELECT LoginName AS [User ID], Email, Convert(varchar,RegistrationDate,101) AS [Create Date], Convert(varchar,UpdateDate,101) AS [Updated Date] , 
		UpdateUserID FROM NCIUsers
		where UserID in 
			(	SELECT Distinct N.UserID  FROM NCIusers N, UserGroupPermissionMap M, Groups G 
			WHERE N.UserID = M.UserID and M.GroupID = G.GroupId and (G.TypeID =1 or G.TypeID=2) 
			)
		 ORDER BY LoginName
	END	

	if (@Type ='USERSEARCH')
	BEGIN
		select 'ID' =Convert(Varchar(36),UserID), 'Name' =LoginName, 'Type'='User' from NCIUsers where loginName like '%' + @Title+ '%'
	END	

	if (@Type ='ULOGIN')
	BEGIN
		SELECT Distinct N.UserID, N.Password, N.email FROM NCIusers N, UserGroupPermissionMap M, Groups G 
		WHERE N.UserID = M.UserID and M.GroupID = G.GroupId and (G.TypeID =1 or G.TypeID=2)  and loginName=@Title
	END	

	if (@Type= 'VIEWSTATUS')
	BEGIN
		SELECT N.NCIViewID, case LEFT(N.url , 7) when 'https:/'  then N.Title + '<br><a href="' + N.url+ '">' + N.url+ '</a>' when 'http://' then N.Title + '<br><a href="' + N.url+ '">' + N.url+ '</a>'
else  N.Title + '<br><a href="' + @Title + N.url + IsNull(NullIf( '?'+IsNull(N.URLArguments,''),'?'),'') + '">' + N.url + IsNull(NullIf( '?'+IsNull(N.URLArguments,''),'?'),'') + '</a>' end as 'Title/URL',
 'Short Title'=N.ShortTitle, N.Description, 'Owner Group'=G.GroupName, 'Updated'=Convert(varchar,N.UpdateDate,102) + ' by ' + N.UpdateUserID, 
		'Expires'=Convert(varchar,N.ExpirationDate,102) 
		FROM NCIView N, Groups G 
		WHERE N.GroupID=G.GroupID AND N.Status='EDIT' ORDER BY N.UpdateDate DESC, N.ShortTitle ASC
	END

	if (@Type= 'VIEWSTATUSWITHSECTION')
	BEGIN
		SELECT N.NCIViewID, case LEFT(N.url , 7) when 'https:/'  then N.Title + '<br><a href="' + N.url+ '">' + N.url+ '</a>' when 'http://' then N.Title + '<br><a href="' + N.url+ '">' + N.url+ '</a>'
else  N.Title + '<br><a href="' +  N.url + IsNull(NullIf( '?'+IsNull(N.URLArguments,''),'?'),'') + '">' + N.url + IsNull(NullIf( '?'+IsNull(N.URLArguments,''),'?'),'') + '</a>' end as 'Title/URL',
 'Short Title'=N.ShortTitle, N.Description, 'Owner Group'=G.GroupName, 'Updated'=Convert(varchar,N.UpdateDate,102) + ' by ' + N.UpdateUserID, 
		'Expires'=Convert(varchar,N.ExpirationDate,102) 
		FROM NCIView N, Groups G, NCISection S WHERE N.NCISectionID = S.NCISectionID and N.GroupID=G.GroupID AND 
		 S.Name=@Title And N.Status='EDIT' ORDER BY N.UpdateDate DESC, N.ShortTitle ASC
	END	
END



GO
GRANT EXECUTE ON [dbo].[usp_RetrieveVOByType] TO [webadminuser_role]
GO
