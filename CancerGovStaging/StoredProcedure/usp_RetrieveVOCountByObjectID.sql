IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_RetrieveVOCountByObjectID]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_RetrieveVOCountByObjectID]
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

CREATE PROCEDURE dbo.usp_RetrieveVOCountByObjectID
	(
	@ObjectID	uniqueidentifier,
	@Type		varchar(50),
	@Title		varchar(250)
	)
AS
BEGIN
	Declare @Count int

	select @Title =  REPLACE(@Title,'''','''''')


	if (@Type ='BESTBET')-- used in security.cs
	BEGIN
		SELECT count(*) from  BestBetcategories where LISTID=@ObjectID
	END

	if (@Type ='CHECKPARENTLIST') -- used in security.cs
	BEGIN
		SELECT count(*) from LIST WHERE ParentListID is not null AND LISTID=@ObjectID
	END

	if (@Type ='CHECKVO') -- used in security.cs
	BEGIN
		SELECT COUNT(*) FROM VIEWOBJECTS WHERE OBJECTID=@ObjectID
	END

	if (@Type ='CHECKBBSTATUS') -- used in security.cs
	BEGIN
		SELECT COUNT(*) FROM BestBetCategories WHERE Status in ('SUBMIT','DELSUBMIT') AND categoryID =@ObjectID
	END	

	if (@Type ='CHECKLOCK') -- used in security.cs
	BEGIN
		SELECT COUNT(*) FROM NCIView WHERE Status ='LOCKED' AND nciViewID =@ObjectID
	END

	if (@Type ='CHECKSTATUS') -- used in security.cs
	BEGIN
		SELECT COUNT(*) FROM NCIView WHERE Status in ('SUBMIT','DELSUBMIT') AND nciViewID = @ObjectID
	END
	
	if (@Type ='CONTENTHEADER')
	BEGIN
		select count(*) from Header where Type='ContentHeader' and Name =@Title and HeaderID <> @ObjectID
	END		

	if (@Type ='CONTENTDC')
	BEGIN
		Select count(T.Name) from NCIView N, NCITemplate T 
		where N.NCITemplateID = T.NCITemplateID and T.Name ='CONTENT_DC' and N.NCIViewID=@ObjectID
	END
			
	if (@Type= 'DIGEST')
	BEGIN
		select count(*) from  viewobjectproperty vo, list l
		where l.listid=@ObjectID and Convert(varchar(36), l.parentlistid) = vo.propertyvalue 
		and vo.propertyname ='DigestRelatedListID'
	END
	
	if (@Type= 'DIRECTORY')
	BEGIN
		Select count(*) from SectionDirectoryMap M, Directories D 
		where D.DirectoryID=M.DirectoryID and M.SectionID=@ObjectID and D.DirectoryName =@Title
	END
				
	if (@Type ='DOCUMENT')
	BEGIN
		select count(*) from document where documentID=@ObjectID
	END

	if (@Type ='DOCPREVIEW')
	BEGIN
		select count(*) from CancerGovStaging..ViewObjects Where NCIViewID=@ObjectID AND ObjectID not in
		 (Select objectID from CancerGov..ViewObjects Where NCIViewID=@ObjectID)
	END

					
	if (@Type ='DOCWYNTK')
	BEGIN
		select count(*) from NCITemplate where NCITemplateID=@ObjectID  AND Name ='DOC_WYNTK'
	END


	if (@Type ='EXTERNALLINK')
	BEGIN
		select count(*) from NCIView where NCIViewID in (select objectID from viewobjects where NCIViewID =@ObjectID  AND type ='LINK') 
		and url  = @Title and NCITemplateID is null
	END
	
	if (@Type ='FEATUREDPROPERTY')
	BEGIN
		SELECT Count(*) from ViewProperty where PropertyName ='FEATURED' AND NCIViewID=@ObjectID
	END	

	if (@Type ='GETVOPRIORITY')
	BEGIN
		select @Count = count(*) from ViewObjects where NCIViewID=@ObjectID
		If (@Count =0)
		BEGIN
				select 1
		END
		else
		BEGIN
				select max(priority) +1  from Viewobjects where NCIViewID=@ObjectID and Type <>'HEADER'
		END
	END	

	if (@Type ='GETLISTPRIORITY')
	BEGIN
		select @Count = count(V.Type) from list L, ViewObjects V  where L.ListID=V.ObjectID and V.Type ='NLLIST' AND L.listid=@ObjectID
		if (@Count >0)
		BEGIN
			select @Count = count(*) from NLlistitem where listID=@ObjectID
			if (@Count =0)
			BEGIN
				select 1
			END
			Else
			BEGIN
				select max(priority) +1 from NLlistitem where listID=@ObjectID
			END
		END
		else
		BEGIN
			select @Count = count(*) from listitem where listID=@ObjectID
			if (@Count =0)
			BEGIN
				select 1
			END
			Else
			BEGIN
				select max(priority) + 1 from listitem where listID=@ObjectID
			END
		END
	END

	if (@Type ='HEADER')
	BEGIN
		select count(*) from Header where Type='Header' and Name =@Title and HeaderID <> @ObjectID
	END	

	if (@Type ='INFOBOX')
	BEGIN
		select count(*) from NCIObjects where ParentNCIObjectID =@ObjectID
	END

	if (@Type ='INFOBOXLIST')
	BEGIN
		select count(*) from nciObjects N, ViewObjects V where N.ParentNCIObjectID = V.ObjectID and V.Type='INFOBOX' 
		and N.NCIObjectID = @ObjectID
	END


	if (@Type ='INTERNALLINK')
	BEGIN
		select count(*) from NCIView where NCIViewID in (select objectID from viewobjects where NCIViewID =@ObjectID  AND type ='LINK') 
		and url  = @Title and NCITemplateID is not null
	END

	if (@Type ='ISLINK')
	BEGIN
		SELECT  count(*) FROM NCIView where NCITemplateID is null and URL like '%http%' and NCIViewID= @ObjectID
	END		

	if (@Type ='ISPRINTAVAILABLETEMP') 
	BEGIN
		select count(*) from TemplateProperty where propertyname='IsPrintAvailable' and PropertyValue='TRUE' and
		 NCITemplateID=@ObjectID
	END

	if (@Type ='LIST')
	BEGIN
		select count(*) from list where parentlistid=@ObjectID
	END

	if (@Type= 'NEWSLETTERKY')
	BEGIN
		select count(*) from NLKeyword where Keyword =@Title and NewsletterID =@ObjectID
	END		

	if (@Type= 'NEWSLETTERTITLE')
	BEGIN
		select count(*) from Newsletter where Title =@Title and newsletterID !=@ObjectID
	END


	if (@Type= 'NLLIST')
	BEGIN

		select count(V.Type) from list L, ViewObjects V  
		where L.ListID=V.ObjectID and V.Type='NLLIST' 
		AND L.listid=@ObjectID
	END

	if (@Type ='NLISSUE')
	BEGIN
		Select count(*) from NLIssue where NewsletterID =@ObjectID
	END

	if (@Type ='NLISSUEVIEWID')
	BEGIN
		Select count(*) from NLIssue where NciviewID =@ObjectID
	END

	if (@Type ='NLKEYWORD')
	BEGIN
		Select count(*) from NLKeyword where NewsletterID =@ObjectID
	END

	if (@Type= 'PARENTLIST')
	BEGIN
		SELECT count(*) FROM LIST 
		WHERE ParentListID = @ObjectID
		 AND ListName =@Title
	END


	if (@Type ='PRETTYURL')
	BEGIN
		Select count(*) from prettyURL where nciviewid= @ObjectID
	END

	if (@Type ='PRETTYURLEXIST')
	BEGIN
		Select count(*) from prettyURL where prettyurlID = @ObjectID and (proposedURL=@Title or currentURL=@Title)
	END

	if (@Type ='PRETTYURLPRIMARYNOT')
	BEGIN
		select count(*) from prettyurl where nciviewid= (select nciviewid from prettyurl where prettyurlid = @ObjectID)
		 and isroot=1 and prettyurlID != @ObjectID
	END

	if (@Type ='PRETTYURLPRIMARY')
	BEGIN						
		select count(*) from prettyurl where isprimary=1 and prettyurlID =@ObjectID						
	END

	if (@Type ='REDIRECT')
	BEGIN
		SELECT count(*) from NCIView WHERE NCIViewID =@ObjectID and NCITemplateID is not null
	END	

	if (@Type ='TASK')
	BEGIN
		select count(*) from taskstep where AprvStoredProcedure ='usp_deleteNCIView' and taskID =@ObjectID
	END

	if (@Type ='TASKINCOMPLETE')
	BEGIN
		SELECT count(*) from TaskStep WHERE TaskID =@ObjectID AND OrderLevel < @Title  AND Status <> 'Completed'
	END	

	if (@Type ='TEMPPROPERTY')
	BEGIN
		select count(*) from TemplateProperty 
		where PropertyName =@Title and NCITemplateID =@ObjectID
	END	
			
	if (@Type ='TEMPLATE')
	BEGIN
		select count(*) from NCITemplate where Name =@Title  and NCITemplateID <>@ObjectID
	END		

	if (@Type= 'UNSENTTASK')
	BEGIN		
		select count(L.status) from NLIssue L, NCIView N, Task T 
		where T.ObjectID = N.NCIViewID and L.NCIViewID= N.NCIViewID and N.IsOnProduction =0 and L.status ='UNSENT' and L.senddate < getdate() 
		and T.TaskID=@ObjectID
	END

	if (@Type= 'UNSENTNLISSUE')
	BEGIN		
		select count(L.status) from NLIssue L, NCIView N where L.NCIViewID= N.NCIViewID and N.IsOnProduction =0 and L.status ='UNSENT' 
		and L.senddate < getdate() and L.nciviewid=@ObjectID
	END	

	if (@Type ='VIEWOBJECT')
	BEGIN
		select count(*) from NCIObject where Name =@Title and NCIObjectID <>@ObjectID
	END

	if (@Type ='VIEWPROPERTY')
	BEGIN
		Select count(*) from ViewProperty Where NCiviewid=@ObjectID and PropertyName=@Title
	END

	if (@Type= 'VIEWPROPERTYNOTSHOWTAG')
	BEGIN
		SELECT count(*)
		from  nciview v
		WHERE v.NCIViewID =@ObjectID 
			and (v.ncitemplateid in (select ncitemplateid from ncitemplate
					where name in ('Benchmark', 'NEWSLETTER', 'summary', 'AutomaticRSSFeed', 'ManualRSSFeed')) 
		      or ncisectionid = 'F2901263-4A99-44A8-A1DA-92B16E173E86' )
	END	

	if (@Type ='VOPROPERTY')
	BEGIN
		select count(*) from ViewObjectTypeProperty where PropertyName =@Title and NCIobjectID =@ObjectID
	END		

END

GO
GRANT EXECUTE ON [dbo].[usp_RetrieveVOCountByObjectID] TO [webadminuser_role]
GO
