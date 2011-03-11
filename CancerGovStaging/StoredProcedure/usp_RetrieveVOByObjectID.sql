IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_RetrieveVOByObjectID]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_RetrieveVOByObjectID]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






/**********************************************************************************

	Object's name:	usp_RetrieveVOByObjectID
	Object's type:	Stored Procedure
	Purpose:	Update Categories
	Change History:	7/16/2003	Jay He	
			11/04/2004	Lijia add ChangeComments
			11/18/2004	Lijia add qcemail
**********************************************************************************/

CREATE PROCEDURE dbo.usp_RetrieveVOByObjectID
	(
	@ObjectID	uniqueidentifier,
	@Type		varchar(50),
	@Title		varchar(255)
	)
AS
BEGIN
	
	if(	
		  @ObjectID IS NULL
	  )	
	BEGIN
		RAISERROR ( 70001, 16, 1)
		RETURN 70001
	END
		
	if (@Type= 'BENCHMARK')
	BEGIN
		select path from externalobject where externalobjectid= @ObjectID
	END

	if (@Type= 'BESTBET')
	BEGIN
		select CatName,  ListID,  CatProfile, Weight, Status, IsOnProduction ,ChangeComments, isSpanish, isExactMatch from BestBetCategories WHERE categoryID =@ObjectID
	END

	if (@Type= 'BESTBETLIST')
	BEGIN
		select  B.CategoryID, 'Name'= B.CatName from bestbetCategories B, ListItem I WHERE I.ListID = B.ListID and  I.NCIViewID= @ObjectID
			
		select  B.CategoryID, 'Name'= B.CatName from Cancergov..bestbetCategories B, Cancergov..ListItem I WHERE I.ListID = B.ListID and  I.NCIViewID= @ObjectID
	END		

	if (@Type= 'BESTBETSYN')
	BEGIN
		SELECT SynName,  IsNegated, Notes, isExactMatch FROM BestBetSynonyms WHERE synonymID =@ObjectID
	END

	if (@Type= 'CHECKDRAFTLISTITEM')
	BEGIN
		select li.NCIViewID, N.ShortTitle from listItem li, list l, NCIView N 
		where N.IsOnProduction=0 and N.NCIViewID = li.NCIViewID and
		 	li.listID =  l.listID  and l.parentlistID in (
				Select convert(uniqueidentifier, PropertyValue) 
				from CancerGovStaging..ViewObjectProperty VOP, ViewObjects VO
				Where  VO.NCIViewID=@ObjectID and PropertyName ='DigestRelatedListID' 
					and VOP.NCIViewObjectID = VO.NCIViewObjectID )
		 union 
		select li.NCIViewID, N.ShortTitle  from listItem li, list l, NCIView N, ViewObjects VO 
		where VO.NCIViewID = @ObjectID and N.IsOnProduction=0 and N.NCIViewID = li.NCIViewID and
		 li.listID =  l.listID and l.listID = VO.ObjectID  
		union
		select li.NCIViewID, N.ShortTitle from listItem li, NCIView N, ViewObjects VO, NCIObjects O 
		where VO.NCIViewID = @ObjectID and N.IsOnProduction=0 and N.NCIViewID = li.NCIViewID and
		 li.listID =O.NCIObjectID and VO.ObjectID = O.ParentNCIObjectID  
	END

	if (@Type= 'CHECKDRAFTLISTITEMFORBESTBET')
	BEGIN
		select li.NCIViewID, N.ShortTitle from listItem li, list l, NCIView N , bestbetcategories B
		where B.CategoryID = @ObjectID and N.IsOnProduction=0 and N.NCIViewID = li.NCIViewID and
		 li.listID =  l.listID and l.listID = B.ListID
	END

	if (@Type= 'CLICKLOGGING')
	BEGIN
		select propertyvalue from ViewProperty where propertyname='Clicklogging' and NCIViewID=@ObjectID
	END		

	if (@Type= 'CONTENTHEADER')
	BEGIN
		select Name, ContentType, Data,  IsNull(ContentType,'') as css from Header where headerID = @ObjectID
	END

	if (@Type= 'CONTENTHEADERNOT')
	BEGIN
		SELECT Name, HeaderID FROM Header 
		where Type ='ContentHeader' and HeaderID not in 
			(select objectID from ViewObjects where NCIViewID=@ObjectID)
				and HeaderID in (select headerID from CancerGov..Header)
		ORDER BY Name
	END			

	if (@Type= 'CONTENTHEADERVO')
	BEGIN
		SELECT H.HeaderID, H.Name, V.UpdateUserID, V.UpdateDate from Header H, ViewObjects V 
		where V.NCIViewID=@ObjectID and V.Type ='Header' and V.ObjectID=H.HeaderID and H.Type='ContentHeader'
	END		

	if (@Type= 'DIGEST')
	BEGIN
		select ListID, Priority from List where parentListID =(Select V.PropertyValue from ViewObjectProperty V,  ViewObjects VO	
		where V.NCIViewObjectID = VO.NCIViewObjectID
		and  VO.ObjectID=@ObjectID and V.PropertyName=  'DigestRelatedListID') order by Priority
	END		

	if (@Type= 'DIRECTORY')
	BEGIN	
		SELECT D.DirectoryID, D.DirectoryName, 'Section'=N.Name, 'Updated'=Convert(varchar,D.UpdateDate,101) + ' by ' + D.UpdateUserID 
		FROM NCIsection N, Directories D, SectionDirectoryMap M 
		WHERE D.DirectoryID = M.DirectoryID and M.SectionID= N.NCISectionID and N.NCISectionID=@ObjectID
		ORDER BY D.UpdateDate DESC
	END

	if (@Type= 'DISPLAYHISTORY')
	BEGIN	
		if (exists (select nciviewid from nciview where nciviewid =@ObjectID))
		BEGIN
			SELECT Distinct Changecomments, UpdateDate, UpdateUserID 
			FROM CancerGov..AuditNCIView
			WHERE NCIViewID =@ObjectID and (ChangeComments is not null and  len(ChangeComments) >0)
			ORDER BY UpdateDate DESC
		END
		else 	if (exists (select categoryID from bestbetcategories where categoryID =@ObjectID))
		BEGIN
			SELECT Distinct Changecomments, UpdateDate, UpdateUserID 
			FROM CancerGov..Auditbestbetcategories
			WHERE categoryID =@ObjectID and (ChangeComments is not null and  len(ChangeComments) >0)
			ORDER BY UpdateDate DESC
		END
	END

	if (@Type= 'DOCUMENT')
	BEGIN
		select Title, ShortTitle, Description, GroupID, DataType, DataSize, IsWirelessPage, TOC, Data, CreateDate, ReleaseDate, ExpirationDate, PostedDate, DisplayDateMode, UpdateDate, UpdateUserID     
		From Document where DocumentID =@ObjectID
	END

	if (@Type= 'DOCUMENTHDR')
	BEGIN
		SELECT L.ListID, L.ListName, L.ListDesc FROM ViewObjects V, List L 
		WHERE L.ListID = V.ObjectID and V.Type='HDRLIST' AND V.NCIViewID=@ObjectID
	END	

	if (@Type= 'DOC')
	BEGIN
		SELECT V.ObjectID, S.Name, N.NCITemplateID,  T.Name as TName
		FROM NCITemplate T, NCISection S, NCIView N, ViewObjects V 
		WHERE N.NCITemplateID = T.NCITemplateID AND N.NCISectionID = S.NCISectionID AND N.NCIViewID= V.NCIViewID
		 AND V.TYPE= 'DOCUMENT' AND N.NCIViewID =@ObjectID
	END	


	if (@Type= 'DOCPART')
	BEGIN
		select heading, content, ShowTitleOrNot from docpart where docpartid=@ObjectID
	END

	if (@Type= 'DOCBYNCIVIEWID')
	BEGIN
		SELECT D.documentID, D.shorttitle from document D, ViewObjects v 
		where V.Type='Document' and D.DocumentID=V.ObjectID and V.NCIViewID=@ObjectID  order by priority
	END

	if (@Type= 'DOCPARTBYDOCID')
	BEGIN
		select docpartid, heading,content from docpart where documentID=@ObjectID order by priority
	END

	if (@Type= 'EFORMXSL')
	BEGIN				
		SELECT S.SegmentData FROM EFormsSegments S, ViewObjects V 
		WHERE S.SegmentID = V.ObjectID and V.Type='EFormWCode' and  V.NCIViewID =@ObjectID
		
		SELECT S.SegmentData FROM EFormsSegments S, ViewObjects V 
		WHERE S.SegmentID = V.ObjectID and V.Type='EFormWHelp' and  V.NCIViewID =ObjectID
		
		SELECT S.SegmentID, S.SegmentName, S.SegmentNumber, V.Type FROM EFormsSegments S, ViewObjects V 
		WHERE S.SegmentID = V.ObjectID and  V.NCIViewID =@ObjectID ORDER by S.SegmentName
	END

	if (@Type= 'EFORMXSL')
	BEGIN				
		SELECT S.SegmentData, S.SegmentInfo, S.SegmentName FROM EFormsSegments S, ViewObjects V 
		WHERE S.SegmentID = V.ObjectID and V.Type='EFormXSL' and  V.NCIViewID =@ObjectID
	END

	if (@Type= 'EXTERNALOBJECT')
	BEGIN
		--select path from externalobject where externalobjectid=@ObjectID
		SELECT V.Type, E.Title, E.Format, E.Path, E.Text, E.Description from ExternalObject E, ViewObjects V 
		Where V.ObjectID= E.ExternalObjectID and E.ExternalObjectID= @ObjectID
	END

	if (@Type= 'FEATURED')
	BEGIN
		SELECT PropertyValue from ViewProperty where PropertyName ='FEATURED' AND NCIViewID=@ObjectID
	END		

	if (@Type ='GETINFOBOXLIST') -- used in security.cs
	BEGIN
		select NV.groupID, NV.NCISectionID, NV.NCIViewID from nciObjects N, ViewObjects V, NCIView NV
		where N.ParentNCIObjectID = V.ObjectID and V.Type='INFOBOX' and NV.NCIViewID = V.NCIViewID
			and N.NCIObjectID = @ObjectID
	END

	if (@Type ='GETLIST') -- used in security.cs
	BEGIN
		SELECT GroupID, NCISectionID, NCIViewID FROM NCIView WHERE 
		NCIViewID = (SELECT top 1 NCIViewID FROM ViewObjects WHERE ObjectID = @ObjectID)
	END

	if (@Type ='GETCHILDLIST') -- used in security.cs
	BEGIN
		if ( exists (SELECT NCIViewID FROM ViewObjects WHERE ObjectID = (SELECT ParentListID from LIST WHERE LISTID=@ObjectID)))
		BEGIN
			SELECT GroupID, NCISectionID, NCIViewID FROM NCIView WHERE 
			NCIViewID = (SELECT top 1 NCIViewID FROM ViewObjects WHERE ObjectID = (SELECT ParentListID from LIST WHERE LISTID=@ObjectID))
		END
		ELSE
		BEGIN
			select 5 as groupID, '0C0D1AD1-BD1C-4003-BF15-9F4BC1983DC1' as  NCISectionID, newid() as nciviewid
		END
	END

	if (@Type= 'GETDIGESTLIST')  -- used in security.cs
	BEGIN
		select nciviewID from viewobjects where nciviewobjectid =(
			select nciviewobjectID from  viewobjectproperty vo, list l
			where l.listid=@ObjectID and Convert(varchar(36), l.parentlistid) = vo.propertyvalue 
			and vo.propertyname ='DigestRelatedListID'
			)
	END	

	if (@Type= 'GETPDF')-- used in delete pdf
	BEGIN
		SELECT URL FROM NCIView WHERE NCIViewID = @ObjectID  and NCITemplateID = 
			(select ncitemplateID from ncitemplate where [name]='PDF')
	END	

	if (@Type= 'HEADER')
	BEGIN
		select Name, ContentType, Data, IsNull(ContentType,'') as css from Header where headerID = @ObjectID
	END

	if (@Type= 'HEADERVO')
	BEGIN
		SELECT H.HeaderID, H.Name, H.ContentType, V.UpdateUserID, V.UpdateDate 
		from Header H, ViewObjects V 
		where H.Type='Header' and V.NCIViewID=@ObjectID and V.Type ='Header' and V.ObjectID=H.HeaderID
	END
		
	if (@Type ='HEADERNOT')
	BEGIN
		SELECT Name, HeaderID FROM Header where IsApproved=1 and Type ='Header' and HeaderId not in
		 (select objectID from ViewObjects where NCIViewID=@ObjectID and type ='Header') 
		order by Name
	END			

	if (@Type= 'IMAGE')
	BEGIN
		SELECT ImageName, ImageSource, ImageAltText,TextSource, Url, Width, Height, Border, UpdateDate, UpdateUserID          
		 FROM IMAGE WHERE IMAGEID=@ObjectID
	END

	if (@Type= 'INCLUDE')
	BEGIN
		SELECT N.Title, N.ShortTitle, N.Description, V.ObjectID, S.Name 
		FROM NCIView N, ViewObjects V, NCISection S 
		WHERE N.NCISectionID = S.NCISectionID AND N.NCIViewID= V.NCIViewID AND V.TYPE in ('INCLUDE', 'TXTINCLUDE') AND N.NCIViewID =@ObjectID
	END	

	if (@Type ='INCLUDEVIEW')
	BEGIN
		SELECT I.ImageID, I.ImageName,  I.UpdateDate, I.UpdateUserID, V.Priority  from [image] I, ViewObjects V 
		where I.ImageID= V.ObjectID and V.NCIViewID =@ObjectID order by V.Priority
	END	

	if (@Type ='ISPRINTAVAILABLE')
	BEGIN
		select propertyvalue from ViewProperty where propertyname='IsPrintAvailable' and NCIViewID=@ObjectID
	END				

	if (@Type= 'KEYWORD')
	BEGIN
		select  N.NewsletterID, N.OwnerGroupID, N.[Section], N.Title, N.[Description],  N.[From],  N.ReplyTo, N.CreateUserID, N.CreateDate, N.Status, N.UpdateDate, N.UpdateUserID,  K.Keyword
		from Newsletter N, NLKeyword K 
		where N.newsletterID = K.newsletterID and K.KeywordID = @ObjectID
	END

	if (@Type= 'LISTNAME')
	BEGIN
		SELECT ListName FROM List WHERE ListID = @ObjectID
	END

	if (@Type= 'LIST')
	BEGIN
		SELECT ListName, ListDesc, NCIViewID, DescDisplay =IsNull(DescDisplay,0), ReleaseDateDisplay = IsNull(ReleaseDateDisplay, 0), 
			ReleaseDateDisplayLoc= IsNull(ReleaseDateDisplayLoc,0) 
		FROM List 
		WHERE ListID = @ObjectID
	END

	if (@Type= 'LISTID')
	BEGIN
		SELECT ObjectID FROM ViewObjects WHERE TYPE='LIST' AND NCIViewID = @ObjectID
	END			

	if (@Type= 'LISTITEM')
	BEGIN
		SELECT NCIView.NCIViewID, NCIView.Title, NCIView.ShortTitle, NCIView.[Description], NCIView.CreateDate, 
			ListItem.IsFeatured, ListItem.Priority, Link='../Page/NCIViewRedirect.aspx?NCIViewID='+ CONVERT(varchar(38), NCIView.NCIViewID) 
			+ '&ReturnURL='  
		From NCIView INNER JOIN ListItem 
				ON NCIView.NCIViewID = ListItem.NCIViewID 
		WHERE ListItem.ListID =@ObjectID
		 ORDER BY ListItem.Priority
	END

	if (@Type ='MACRO')
	BEGIN
		select status from TSMacros where MacroID = @ObjectID
	END

	if (@Type= 'MESSAGE')
	BEGIN
		SELECT NCIUsers.LoginName AS [From], Subject, Message, SendDate AS [Send Date] 
		FROM NCIMessage, NCIUsers  
		WHERE NCIUsers.UserID = NCIMessage.SenderID AND NCIMessage.MessageID =  @ObjectID
 
		SELECT NCIMessageAttachment.Name AS [Attachment Name], NCIMessageAttachment.AttachmentText AS [Attachment Text] 
		FROM NCIMessageAttachment 
		WHERE NCIMessageAttachment.MessageID =  @ObjectID
	END		


	if (@Type= 'MESSAGESUB')
	BEGIN
		SELECT NCIMessage.Subject AS Subject, NCIUsers.LoginName AS SenderName 
		FROM NCIMessage, NCIUsers 
		WHERE NCIMessage.MessageID =@ObjectID AND NCIMessage.SenderID = NCIUsers.UserID
	END			

	if (@Type= 'NAVDOC')
	BEGIN
		SELECT D.DocumentID, D.ShortTitle,  V.Type, V.Priority 
		FROM DOCUMENT D, ViewObjects V 
		WHERE D.DocumentID = V.ObjectID and V.Type ='NAVDOC'
		AND V.NCIViewID=@ObjectID 
		ORDER by V.Priority
	END

	if (@Type= 'NCISECTION')
	BEGIN
		--SELECT NCISectionID, Name, SectionHomeViewID, URL, 'Update'= UpdateUserID +' ' + Convert(varchar, UpdateDate,101)  from NCISection order by orderlevel
		-- update 04/12/2004 for Redesign, include parentsection
		
		SELECT N.NCISectionID, N.Name, N.SectionHomeViewID, NS.Name as 'SiteName', isnull(S.Name,'') as 'ParentName', N.URL, 
		'Update'= N.UpdateUserID +' ' + Convert(varchar, N.UpdateDate,101)  
		from NCISite NS, NCISection N left join NCISection S 
		on  N.ParentSectionID = S.NCISectionID
		where NS.NCISiteID = N.SiteID and N.SiteID = @ObjectID
		order by N.orderlevel
	END	

	if (@Type= 'NCIOBJECTPROPERTY')
	BEGIN
		SELECT Distinct PropertyName, PropertyValue
		from NCIObjectProperty
		where ObjectInstanceID= @ObjectID
	END			
	

	if (@Type= 'NCIUSER')
	BEGIN
		Select LoginName from NCIUsers where UserID= @ObjectID
	END


	if (@Type= 'NCIVIEWOBJECTID')
	BEGIN

		SELECT NCIViewObjectID FROM ViewObjects WHERE objectID = @ObjectID
	END	


	if (@Type= 'NEWSLETTER')
	BEGIN
		select OwnerGroupID, [Section], Title, [Description],   [From], ReplyTo,CreateUserID, CreateDate, Status, UpdateDate, UpdateUserID
		 from Newsletter where newsletterID=@ObjectID
	END


	if (@Type= 'NEWSLETTERSUB')
	BEGIN
		/*
		select n.UserID, n.loginname, n.email, u.EmailFormat, u.subscriptionDate, u.KeywordList from usersubscriptionmap u, nciusers n 
		where u.userID = n.userID and u.newsletterID=@ObjectID and IsSubscribed = 1 order by n.loginname
		*/
		select  '<a href=DeleteNewsletterSubscriber.aspx?NewsletterID='+ convert(varchar(36), newsletterID) +'&UserID='+ convert(varchar(36), n.userID)  +'>Delete</a>' as 'Delete',   
			n.UserID, n.loginname, n.email, u.EmailFormat, u.subscriptionDate, u.KeywordList 
		from usersubscriptionmap u, nciusers n 
		where u.userID = n.userID and u.newsletterID=@ObjectID and u.IsSubscribed = 1 
			and left(ltrim(n.loginname),1) = @Title
		order by n.loginname
	END	


	if (@Type= 'NEWSLETTERISSUETYPE')
	BEGIN
			select IssueType
			 from NLIssue 
			where nciviewid=@ObjectID
	END

	if (@Type= 'NLISSUE')
	BEGIN
		select NewsletterID, Priority, Status, SendDate, UpdateUserID,UpdateDate                                             
		 from NLIssue where nciviewid=@ObjectID
	END


	if (@Type ='NLLIST')
	BEGIN
		SELECT ListName, ListDesc, NCIViewID, DescDisplay =IsNull(DescDisplay,0), ReleaseDateDisplay = IsNull(ReleaseDateDisplay, 0), ReleaseDateDisplayLoc= IsNull(ReleaseDateDisplayLoc,0) FROM List WHERE ListID = @ObjectID
	END


	if (@Type= 'NLLISTITEM')
	BEGIN
		SELECT NCIViewID, Title, ShortTitle, [Description], IsFeatured, Priority, Link='NCIViewRedirect.aspx?NCIViewID='+ CONVERT(varchar(36), NCIViewID) + '&ReturnURL='
		 From NLListItem where ListID =@ObjectID ORDER BY Priority
	END

	if (@Type= 'NLSECTION')
	BEGIN
		select Title, ShortTitle, Description, HTMLBody, PlainBody from NLSection where NLSectionID=@ObjectID
	END		

	if (@Type= 'OWNERGROUP')
	BEGIN
		select ownergroupID from newsletter where newsletterid=@ObjectID
	END

	if (@Type= 'PARENTLIST')
	BEGIN
		--SELECT ListID, ListName, ListDesc, ParentListID, Priority FROM LIST WHERE ParentListID = @ObjectID
		--Order By Priority
		select L.ListID, L.ListName, L.ListDesc, V.Priority from List L, Viewobjects V
		Where V.NCIViewID = @ObjectID and V.ObjectID = L.ListID and V.Type <> 'HDRLIST'
		Order by V.Priority
	END

	if (@Type= 'PERMISSION')
	BEGIN
		Select distinct G.GroupName as [Group Name], M.UserId As UserID, M.GroupID As GroupID, N.LoginName as [User Name] 
		from UserGroupPermissionMap M, NCIUsers N, Groups G 
		where M.GroupID= G.GroupID and M.UserID= N.UserId and M.UserID =@ObjectID Order by [User Name]
		
		SELECT GroupID As ID, GroupName As Name FROM  Groups 
		where GroupID not in (select distinct GroupID from UserGroupPermissionMap where userID =@ObjectID) ORDER BY GroupName
	END


	if (@Type= 'PRETTYURL')
	BEGIN
		select currentURL,ProposedURL, UpdateRedirectOrNot, IsPrimary from PrettyURL where prettyurlID=@ObjectID
	END		

	if (@Type= 'PRETTYURLBYID')
	BEGIN
		SELECT PrettyURLID, IsPrimary, CurrentURL, ProposedURL, UpdateDate, UpdateUserID 
		FROM PrettyURL 
		where isroot=1  and  nciviewID= @ObjectID and objectID is null ORDER BY CurrentURL
	END	

			


	if (@Type= 'PRETTYURLALLDIR')
	BEGIN
		SELECT Distinct D.DirectoryName, D.DirectoryID FROM Directories D, SectionDirectoryMap M, NCIView V 
		where D.DirectoryID = M.DirectoryID and M.SectionID= V.NCISectionID and V.NCIViewID =@ObjectID ORDER BY D.DirectoryName
	END

	if (@Type= 'PRETTYURLDIR')
	BEGIN
		select distinct directoryID from PrettyURL where  PrettyURLID=@ObjectID
	END	

	if (@Type= 'PDF')
	BEGIN
		SELECT N.Title, N.ShortTitle, N.Description, V.ObjectID, S.Name 
		FROM NCIView N, ViewObjects V, NCISection S 
		WHERE N.NCISectionID = S.NCISectionID AND N.NCIViewID= V.NCIViewID AND V.TYPE= 'PDF' AND N.NCIViewID =@ObjectID
	END
			
	if (@Type= 'PRODPU') -- check whether nciview has its pretty url overlapping with one in prod
	BEGIN
		
		SELECT CurrentURL, realURL
		FROM  Cancergov..PrettyURL 
		where isroot=1  and  nciviewID !=  @ObjectID and objectID is  null and CurrentURL in (
			
			SELECT ProposedURL
			FROM PrettyURL 
			where isroot=1  and  nciviewID= @ObjectID and objectID is null 
			and ProposedURL is not null
		)
	END		

	if (@Type= 'RIGHTNAV')
	BEGIN
		SELECT NCIViewObjectID, ObjectID, Priority FROM VIEWOBJECTS
		 WHERE NCIViewID =@ObjectID AND (Type like '%list' OR Type like '%doc' OR Type Like '%image') ORDER by Priority 

	END		

	if (@Type= 'SECTION')
	BEGIN	
		SELECT Distinct G.GroupName, G.GroupID 
		FROM Groups G, SectionGroupMap S 
		where S.SectionID = @ObjectID and G.GroupID = S.GroupID 
		order by G.GroupName ASC
	END


	if (@Type= 'SEARCH')
	BEGIN	
		SELECT N.URL from NCIView N, ViewObjects V
		Where N.NCIViewID= V.NCIViewID and V.ObjectID = @ObjectID 
	END

	if (@Type= 'SITE')
	BEGIN	
		SELECT [Name], [Description]
		FROM NCISite 
		where NCISiteID = @ObjectID 
	END

	if (@Type= 'SIMPLENEWSLETTER')
	BEGIN
			select N.NewsletterID, N.SendDate, S.PlainBody, S.HTMLBody, N.IssueType, L.[From], L.ReplyTo
			 from NLIssue N, NLSection S, Viewobjects V, Newsletter L 
			where N.nciviewid=@ObjectID and S.NLSectionID = V.ObjectID and  V.NCIViewID = N.NCIViewID and L.NewsletterID = N.NewsletterID
	END

	if (@Type= 'SYNONYM')
	BEGIN	
		SELECT SynonymID, SynName FROM BestBetSynonyms WHERE CategoryID=@ObjectID and IsNegated=0 ORDER BY SynName
		
		SELECT SynonymID, SynName FROM BestBetSynonyms WHERE CategoryID=@ObjectID  and IsNegated=1 ORDER BY SynName

		select CatName from BestBetCategories WHERE categoryID =@ObjectID			
	END

	if (@Type= 'TASK')
	BEGIN
		Select TaskID, ResponsibleGroupID, Name, Status, Notes, Importance, ObjectID, UpdateDate, UpdateUserID 
		from Task WHERE taskID =@ObjectID
	END

	if (@Type= 'TASKVIEWID')
	BEGIN
		select  a.argumentvalue as NCIViewID
		from taskstepargument a, TaskStep s where 
		s.taskID = @ObjectID
		and s.aprvstoredprocedure ='usp_PushNCIViewToProduction' and a.argumentordinal=1 and forprocedurex =1 
		and a.stepID = s.stepID
	END

	if (@Type= 'TASKSTEP')
	BEGIN
		select StepID, TaskID, ResponsibleGroupID, Name, Description, Status, OrderLevel, AprvStoredProcedure, DisAprvStoredProcedure, OnErrorStoredProcedure, IsAuto, UpdateDate, UpdateUserID
		from TaskStep where StepID =@ObjectID
	END

	if (@Type= 'TASKPP')
	BEGIN
		SELECT 'order' = 1 ,T.StepID, T.Name, 'Description'=Replace(T.Description, '''''',''''), T.Status, G.GroupName, OrderLevel 
		from TaskStep T, Groups G 
		WHERE T.ResponsibleGroupID = G.GroupID and TaskID=@ObjectID  ORDER BY OrderLevel
	END	


	if (@Type= 'TASKDELETEDVIEWID')
	BEGIN
		select ArgumentValue as NCIViewID from taskstepargument where stepid in (select stepID from taskstep 
where taskID= @ObjectID) and ForProcedureX =2 and ArgumentOrdinal = 1
	END	




	if (@Type= 'TEMPLATEPROPERTY')
	BEGIN			
		Select PropertyValue from TemplateProperty where PropertyName=@Title  AND 
		NCITemplateID= (select NCITemplateID from NCIView where NCIViewID=@ObjectID)
	END	

	if (@Type= 'TEMPLATE')
	BEGIN	
		select Name, URL, Description, AddURL, EditURL, ClassName from NCITemplate where NCITemplateID=@ObjectID
		
		select NCITemplateID, PropertyName, PropertyValue, ValueType, 'Update'= UpdateUserID +' ' + Convert(varchar, UpdateDate,101) 
		from TemplateProperty where NCITemplateID=@ObjectID
	END				

	if (@Type= 'TEMPPROPERTY')
	BEGIN		
		select PropertyName, PropertyValue, Comments, Description, IsDefaultValue, ValueType, Editable from TemplateProperty 
		where NCITemplateID=@ObjectID and PropertyName=@Title
	END
		


	if (@Type= 'VIEWPROPERTYFEATURED')
	BEGIN			
		SELECT T.NCITemplateID, T.PropertyName, T.PropertyValue, T.ValueType, T.IsDefaultValue 
		from TemplateProperty T, NCIView N 
		where N.NCIViewID=@ObjectID AND N.NCITemplateID = T.NCITemplateID AND T.PropertyName !='FEATURED'
		 AND T.PropertyName not in (select PropertyName from ViewProperty where NCIViewID=@ObjectID)
	
		SELECT V.ViewPropertyID, V.PropertyName, 'Value'= V.PropertyValue, T.ValueType, T.PropertyValue, T.Editable, 
		'Update'= V.UpdateUserID +' ' + Convert(varchar,V.UpdateDate,101) 
		from NCIView N, ViewProperty V, TemplateProperty T 
		where N.NCITemplateID = T.NCITemplateID AND N.NCIViewID=V.NCIViewID AND T.PropertyName=V.PropertyName
		 AND V.PropertyName !='FEATURED' AND V.NCIViewID=@ObjectID
				
	END	

	if (@Type= 'VIEWVOPROPERTY')
	BEGIN			
		Select PropertyValue from ViewObjectTypeProperty where PropertyName=@Title  AND 
		NCIObjectID= (select N.NCIObjectID from NCIObject N, ViewObjects V where V.Type=N.Name AND V.ObjectID=@ObjectID)
	END	

	if (@Type= 'VIEWPROPERTY')
	BEGIN			
		SELECT T.PropertyName, T.PropertyValue from TemplateProperty T, NCIView N 
		where N.NCIViewID=@ObjectID AND N.NCITemplateID = T.NCITemplateID AND T.PropertyName not in
			 (select PropertyName from ViewProperty where NCIViewID=@ObjectID)
		
		SELECT ViewPropertyID, PropertyName, PropertyValue, 'Update'= UpdateUserID +' ' + Convert(varchar,UpdateDate,101) 
		from ViewProperty where NCIViewID=@ObjectID
			
	END

	if (@Type= 'VIEWPROPERTYTAG')
	BEGIN

		SELECT PropertyValue
		 from  ViewProperty
		where PropertyName='Tag' AND NCIViewID =@ObjectID
	END	


	if (@Type= 'VIEWPROPERTYNOT')
	BEGIN				
		SELECT T.NCITemplateID, T.PropertyName, T.PropertyValue, T.ValueType, T.IsDefaultValue 
		from TemplateProperty T, NCIView N where N.NCIViewID=@ObjectID
		AND N.NCITemplateID = T.NCITemplateID 
		AND T.PropertyName not in (select PropertyName from ViewProperty where NCIViewID=@ObjectID)

		SELECT V.ViewPropertyID, V.PropertyName, 'Value'= V.PropertyValue, T.ValueType, T.PropertyValue, T.Editable,
		 'Update'= V.UpdateUserID +' ' + Convert(varchar,V.UpdateDate,101) 
		from NCIView N, ViewProperty V, TemplateProperty T 
		where N.NCITemplateID = T.NCITemplateID AND N.NCIViewID=V.NCIViewID AND T.PropertyName=V.PropertyName AND V.NCIViewID=@ObjectID
	END	

	if (@Type= 'VIEWOBJECT')
	BEGIN	
		select Name, Description, TableName from NCIObject where NCIObjectID=@ObjectID
				
		select NCIObjectID, PropertyName, PropertyValue, ValueType, 'Update'= UpdateUserID +' ' + Convert(varchar, UpdateDate,101)
		 from ViewObjectTypeProperty where NCIObjectID=@ObjectID
	END

	if (@Type= 'VIRSEARCH')
	BEGIN	
		SELECT N.URL from NCIView N, ViewObjects V
		Where N.NCIViewID= V.NCIViewID and V.ObjectID = @ObjectID 
	END

	if (@Type= 'VOPROPERTYVIEW')
	BEGIN			
		select PropertyName, PropertyValue, Comments, Description, ValueType, Editable, IsDefaultValue 
		from ViewObjectTypeProperty where NCIobjectID=@ObjectID and PropertyName=@Title
	END		

	if (@Type= 'VOPROPERTY')
	BEGIN
		SELECT Distinct T.NCIObjectID, T.PropertyName, T.PropertyValue, T.ValueType, T.IsDefaultValue 
		from ViewObjectTypeProperty T, ViewObjects N, NCIObject O 
		where T.PropertyName !='DigestRelatedListID' and O.NCIObjectID= T.NCIObjectID 
			AND O.Name= N.Type AND N.ObjectID=@ObjectID AND 
			T.PropertyName not in (select P.PropertyName from ViewObjectProperty P, ViewObjects S where S.NCIViewObjectID=P.NCIViewObjectID AND S.ObjectID =@ObjectID)

		SELECT V.NCIViewObjectID, V.PropertyName, 'Value'= V.PropertyValue, T.ValueType, T.PropertyValue, T.Editable, 'Update'= V.UpdateUserID +' ' + Convert(varchar,V.UpdateDate,101)
		 from NCIObject N, ViewObjectProperty V, ViewObjectTypeProperty T, ViewObjects O 
		where N.NCIObjectID = T.NCIObjectID AND  O.Type=N.Name aND T.PropertyName=V.PropertyName AND O.NCIViewObjectID = V.NCIViewObjectID AND O.ObjectID =@ObjectID
	END	

	if (@Type ='VIEWPROEDIT')
	BEGIN
		select PropertyValue from ViewProperty where propertyname=@Title and NCIViewID =@ObjectID
	END			

	if (@Type= 'XMLINCLUDE')
	BEGIN				
		SELECT N.Title, N.ShortTitle, N.Description, V.ObjectID, S.Name 
		FROM NCIView N, ViewObjects V, NCISection S 
		WHERE N.NCISectionID = S.NCISectionID AND N.NCIViewID= V.NCIViewID AND V.TYPE= 'XMLINCLUDE' AND N.NCIViewID =@ObjectID
	END

END


GO
GRANT EXECUTE ON [dbo].[usp_RetrieveVOByObjectID] TO [webadminuser_role]
GO
