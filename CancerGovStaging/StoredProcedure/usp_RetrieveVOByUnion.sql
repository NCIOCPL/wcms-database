IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_RetrieveVOByUnion]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_RetrieveVOByUnion]
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

CREATE PROCEDURE dbo.usp_RetrieveVOByUnion
	(
	@ObjectID	uniqueidentifier,
	@Type		varchar(50)
	)
AS
BEGIN
	
	if (@Type= 'CONTENTDC')
	BEGIN
		SELECT VO.NCIViewObjectID, Vo.ObjectID, VO.Type, VO.Priority, 'Name'=L.ListName FROM VIEWOBJECTS VO, List L WHERE VO.NCIViewID =@ObjecTID AND VO.Type like '%list%' and L.ListID = VO.ObjectID 
		Union 
		SELECT VO.NCIViewObjectID, Vo.ObjectID, VO.Type, VO.Priority, 'Name'=D.ShortTitle FROM VIEWOBJECTS VO, Document D WHERE VO.NCIViewID =@ObjectID AND VO.Type like '%doc%' and D.DocumentID = VO.ObjectID 
		Union 
		SELECT VO.NCIViewObjectID, Vo.ObjectID, VO.Type, VO.Priority, 'Name'=D.ShortTitle FROM VIEWOBJECTS VO, Document D WHERE VO.NCIViewID =@ObjectID AND VO.Type like '%search%' and D.DocumentID = VO.ObjectID 
		Union 
		SELECT VO.NCIViewObjectID, Vo.ObjectID, VO.Type, VO.Priority, 'Name'=VO.Type FROM VIEWOBJECTS VO  WHERE VO.NCIViewID =@ObjectID AND Type  not in ('list', 'document', 'search', 'virsearch') 
		ORDER by VO.Priority 
			
	END

	if (@Type= 'CONTENTNAV')
	BEGIN
		SELECT VO.NCIViewObjectID, Vo.ObjectID, VO.Type, VO.Priority, 'Name'=L.ListName FROM VIEWOBJECTS VO, List L WHERE VO.NCIViewID =@ObjecTID AND VO.Type like '%list%' and L.ListID = VO.ObjectID 
		Union 
		SELECT VO.NCIViewObjectID, Vo.ObjectID, VO.Type, VO.Priority, 'Name'=D.ShortTitle FROM VIEWOBJECTS VO, Document D WHERE VO.NCIViewID =@ObjectID AND VO.Type like '%doc%' and D.DocumentID = VO.ObjectID 
		Union 
		SELECT VO.NCIViewObjectID, Vo.ObjectID, VO.Type, VO.Priority, 'Name'=D.ShortTitle FROM VIEWOBJECTS VO, Document D WHERE VO.NCIViewID =@ObjectID AND VO.Type like '%search%' and D.DocumentID = VO.ObjectID 
		Union 
		SELECT VO.NCIViewObjectID, Vo.ObjectID, VO.Type, VO.Priority, 'Name'=VO.Type FROM VIEWOBJECTS VO  WHERE VO.NCIViewID =@ObjectID AND Type  not in ('list','HDRLIST', 'document', 'search', 'header', 'virsearch') 
		ORDER by VO.Priority 
			
	END


	if (@Type= 'CONTENTNAV3COL')
	BEGIN
		SELECT VO.NCIViewObjectID, Vo.ObjectID, VO.Type, VO.Priority, 'Name'=L.ListName FROM VIEWOBJECTS VO, List L WHERE VO.NCIViewID =@ObjecTID AND VO.Type like '%list%' and L.ListID = VO.ObjectID and VO.Priority > 0
		Union 
		SELECT VO.NCIViewObjectID, Vo.ObjectID, VO.Type, VO.Priority, 'Name'=D.ShortTitle FROM VIEWOBJECTS VO, Document D WHERE VO.NCIViewID =@ObjectID AND VO.Type like '%doc%' and D.DocumentID = VO.ObjectID and VO.Priority > 0
		Union 
		SELECT VO.NCIViewObjectID, Vo.ObjectID, VO.Type, VO.Priority, 'Name'=D.ShortTitle FROM VIEWOBJECTS VO, Document D WHERE VO.NCIViewID =@ObjectID AND VO.Type like '%search%' and D.DocumentID = VO.ObjectID and VO.Priority > 0
		Union 
		SELECT VO.NCIViewObjectID, Vo.ObjectID, VO.Type, VO.Priority, 'Name'=VO.Type FROM VIEWOBJECTS VO  WHERE VO.NCIViewID =@ObjectID AND Type not in ('list', 'document', 'search', 'header', 'leftheader') ORDER by VO.Priority 
			
	END


	if (@Type= 'CONTENTNAV3COLLEFTHAND')
	BEGIN
		SELECT VO.NCIViewObjectID, Vo.ObjectID, VO.Type, VO.Priority +20000 as Priority, 'Name'=L.ListName FROM VIEWOBJECTS VO, List L WHERE VO.NCIViewID =@ObjecTID AND VO.Type = 'list' and L.ListID = VO.ObjectID and VO.Priority < 0
		Union 
		SELECT VO.NCIViewObjectID, Vo.ObjectID, VO.Type, VO.Priority +20000 as Priority, 'Name'=D.ShortTitle FROM VIEWOBJECTS VO, Document D WHERE VO.NCIViewID =@ObjectID AND VO.Type = 'document' and D.DocumentID = VO.ObjectID and VO.Priority < 0
		Union 
		SELECT VO.NCIViewObjectID, Vo.ObjectID, VO.Type, VO.Priority +20000 as Priority, 'Name'=H.Name  FROM VIEWOBJECTS VO, Header H WHERE VO.NCIViewID =@ObjectID AND VO.Type = 'leftheader' and H.HeaderID = VO.ObjectID and VO.Priority < 0		
		
	END

	if (@Type= 'PAGELIST')
	BEGIN
		(SELECT N.NCIViewID, 'Title/URL'= N.Title + '<br>' + N.url + IsNull(NullIf( '?'+IsNull(N.URLArguments,''),'?'),''), 'Short Title'=N.ShortTitle, N.Description, 'Owner Group'=G.GroupName, 'Updated'=Convert(varchar,N.UpdateDate,101) + ' by ' + N.UpdateUserID FROM NCIView N, Groups G, ListItem I, ViewObjects V, List L WHERE N.GroupID=G.GroupID AND 
		 N.NCIViewID= V.NCIViewID and V.ObjectID=L.ParentListID  and L.Listid=I.ListID and I.NCIViewID=@ObjectID) 
		UNION 
		(SELECT N.NCIViewID, 'Title/URL'= N.Title + '<br>' + N.url + IsNull(NullIf( '?'+IsNull(N.URLArguments,''),'?'),''), 'Short Title'=N.ShortTitle, N.Description, 'Owner Group'=G.GroupName, 'Updated'=Convert(varchar,N.UpdateDate,101) + ' by ' + N.UpdateUserID FROM NCIView N, Groups G, ListItem I, ViewObjects V  WHERE N.GroupID=G.GroupID AND 
		N.NCIViewID= V.NCIViewID and V.ObjectID=I.ListID and I.NCIViewID=@ObjectID)

		(SELECT N.NCIViewID, 'Title/URL'= N.Title + '<br>' + N.url + IsNull(NullIf( '?'+IsNull(N.URLArguments,''),'?'),''), 'Short Title'=N.ShortTitle, N.Description, 'Owner Group'=G.GroupName, 'Updated'=Convert(varchar,N.UpdateDate,101) + ' by ' + N.UpdateUserID FROM CancerGov..NCIView N, CancerGov..Groups G, CancerGov..ListItem I, CancerGov..ViewObjects V, CancerGov..List L WHERE N.GroupID=G.GroupID AND 
		 N.NCIViewID= V.NCIViewID and V.ObjectID=L.ParentListID  and L.Listid=I.ListID and I.NCIViewID=@ObjectID) 
		UNION 
		(SELECT N.NCIViewID, 'Title/URL'= N.Title + '<br>' + N.url + IsNull(NullIf( '?'+IsNull(N.URLArguments,''),'?'),''), 'Short Title'=N.ShortTitle, N.Description, 'Owner Group'=G.GroupName, 'Updated'=Convert(varchar,N.UpdateDate,101) + ' by ' + N.UpdateUserID FROM CancerGov..NCIView N, CancerGov..Groups G, CancerGov..ListItem I, CancerGov..ViewObjects V  WHERE N.GroupID=G.GroupID AND 
		N.NCIViewID= V.NCIViewID and V.ObjectID=I.ListID and I.NCIViewID=@ObjectID)

	END

	if (@Type= 'RIGHTNAV')
	BEGIN
		SELECT VO.NCIViewObjectID, Vo.ObjectID, VO.Type, VO.Priority, 'Name'=L.ListName FROM VIEWOBJECTS VO, List L WHERE VO.NCIViewID =@ObjectID AND Type like '%list%' and L.ListID = VO.ObjectID 
		Union 
		SELECT VO.NCIViewObjectID, Vo.ObjectID, VO.Type, VO.Priority, 'Name'=D.ShortTitle FROM VIEWOBJECTS VO, Document D WHERE VO.NCIViewID  =@ObjectID  AND Type like '%doc%' and D.DocumentID = VO.ObjectID 
		Union 
		SELECT VO.NCIViewObjectID, Vo.ObjectID, VO.Type, VO.Priority, 'Name'=I.ImageName FROM VIEWOBJECTS VO, [Image] I WHERE VO.NCIViewID  =@ObjectID  AND Type like '%image%' and I.ImageID = VO.ObjectID ORDER by VO.Priority 
	END

	if (@Type= 'LEFTNAV')
	BEGIN
		SELECT VO.NCIViewObjectID, Vo.ObjectID, VO.Type, VO.Priority, 'Name'=L.ListName FROM VIEWOBJECTS VO, List L WHERE VO.NCIViewID =@ObjectID AND Type ='list' and L.ListID = VO.ObjectID 
		Union 
		SELECT VO.NCIViewObjectID, Vo.ObjectID, VO.Type, VO.Priority, 'Name'='Info Box' FROM VIEWOBJECTS VO WHERE VO.NCIViewID =@ObjectID AND Type = 'infobox'
		Union 
		SELECT VO.NCIViewObjectID, Vo.ObjectID, VO.Type, VO.Priority, 'Name'=D.ShortTitle FROM VIEWOBJECTS VO, Document D WHERE VO.NCIViewID  =@ObjectID  AND Type ='navdoc' and D.DocumentID = VO.ObjectID 
		Union 
		SELECT VO.NCIViewObjectID, Vo.ObjectID, VO.Type, VO.Priority, 'Name'=I.ImageName FROM VIEWOBJECTS VO, [Image] I WHERE VO.NCIViewID  =@ObjectID  AND Type like '%image%' and I.ImageID = VO.ObjectID 
		Union 		
		SELECT VO.NCIViewObjectID, Vo.ObjectID, VO.Type, VO.Priority, 'Name'=VO.Type FROM VIEWOBJECTS VO WHERE VO.NCIViewID =@ObjectID AND Type like '%ftsearch%' 
		Union
		SELECT VO.NCIViewObjectID, Vo.ObjectID, VO.Type, VO.Priority, 'Name'=VO.Type FROM VIEWOBJECTS VO WHERE VO.NCIViewID =@ObjectID AND Type like '%ncsearch%' 
		ORDER by VO.Priority 
	END

	if (@Type= 'INFOBOX')
	BEGIN
		SELECT VO.ObjectInstanceID, Vo.NCIObjectID, VO.ObjectType, VO.Priority, 'Name'=L.ListName FROM NCIOBJECTS VO, List L WHERE VO.ParentNCIObjectID =@ObjectID AND VO.ObjectType ='list' and L.ListID = VO.NCIObjectID 
		Union 
		SELECT VO.ObjectInstanceID, Vo.NCIObjectID, VO.ObjectType, VO.Priority, 'Name'=D.ShortTitle FROM NCIOBJECTS VO, Document D WHERE  VO.ParentNCIObjectID  =@ObjectID  AND VO.ObjectType = 'navdoc' and D.DocumentID = VO.NCIObjectID 
		Union 
		SELECT VO.ObjectInstanceID, Vo.NCIObjectID, VO.ObjectType, VO.Priority, 'Name'=I.ImageName FROM NCIOBJECTS VO, [Image] I WHERE  VO.ParentNCIObjectID  =@ObjectID  AND VO.ObjectType like '%image%' and I.ImageID = VO.NCIObjectID ORDER by VO.Priority 
	END
END

GO
GRANT EXECUTE ON [dbo].[usp_RetrieveVOByUnion] TO [webadminuser_role]
GO
