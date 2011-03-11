IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_RetrievePriority]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_RetrievePriority]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



--***********************************************************************
-- Create New Object 
--************************************************************************

/****** Object:  Stored Procedure dbo.usp_RetrieveViewObject
   Owner:Jhe Purpose: For admin side Script Date: 1/15/2002 16:00:49 pm ****/
/*
CREATE PROCEDURE dbo.usp_RetrieveRightNav
AS
BEGIN
	
	*/

CREATE PROCEDURE dbo.usp_RetrievePriority
	(
	@NCIViewID	uniqueidentifier,
	@Type 		varchar(30)
	)
AS
BEGIN

	if(	
		  @NCIViewID IS NULL
	  )	
	BEGIN
		RAISERROR ( 70001, 16, 1)
		RETURN 70001
	END

	if (@Type ='BASICDOCUMENT')
	BEGIN
		SELECT NCIViewObjectID, ObjectID, Priority 
		FROM VIEWOBJECTS 
		WHERE NCIViewID =@NCIViewID 
		AND Type not in ('HEADER', 'HDRLIST' )
		ORDER by Priority 
	END	


	if (@Type ='BENCHMARK')
	BEGIN
		SELECT NCIViewObjectID, ObjectID, Priority 
		FROM VIEWOBJECTS 
		WHERE NCIViewID =@NCIViewID AND Type <>'header' 
		ORDER by Priority 
	END	

	if (@Type ='CONTENTDC')
	BEGIN	
		SELECT NCIViewObjectID, ObjectID, Priority 
		FROM VIEWOBJECTS 
		WHERE NCIViewID =@NCIViewID AND Type <>'header' 
		ORDER by Priority
	END		

	if (@Type ='CONTENTNAV')
	BEGIN	
		SELECT NCIViewObjectID, ObjectID, Priority 
		FROM VIEWOBJECTS 
		WHERE NCIViewID =@NCIViewID AND Type <>'header' 
		ORDER by Priority
	END		
	
	if (@Type ='CONTENTNAV3COL')
	BEGIN	
		SELECT NCIViewObjectID, ObjectID, Priority 
		FROM VIEWOBJECTS 
		WHERE NCIViewID =@NCIViewID AND Type not in ('header', 'LEFTHEADER') and Priority >0 
		ORDER by Priority
	END		

	if (@Type ='CONTENTNAV3COLLEFTHAND')
	BEGIN	
		SELECT NCIViewObjectID, ObjectID, Priority
		FROM VIEWOBJECTS 
		WHERE NCIViewID =@NCIViewID AND Type in  ('DOCUMENT', 'LIST', 'LEFTHEADER') and Priority < 0 
		ORDER by Priority
	END		

	if (@Type ='CONTENTNAV3COLHEADERNAME')
	BEGIN	
		SELECT V.NCIViewObjectID, V.ObjectID, V.Priority +20000 as 'Priority', H.Name, V.Type 
		FROM VIEWOBJECTS V, Header H  
		WHERE V.NCIViewID =@NCIViewID AND V.Type in ('LEFTHEADER', 'DOCUMENT','LIST') and V.Priority <0 and  V.ObjectID =H.headerID
		ORDER by V.Priority
	END	

	if (@Type ='DOCUMENT')
	BEGIN
		SELECT NCIViewObjectID, ObjectID, Priority 
		FROM ViewObjects 
		WHERE Type in ('HDRDOC', 'DOCUMENT') AND NCIViewID=@NCIViewID 
		ORDER by Priority 
	END
	
	if (@Type ='DOCLIST')
	BEGIN
		SELECT NCIViewObjectID, ObjectID, Priority 
		From ViewObjects 
		WHERE TYPE='LIST' AND NCIViewID=@NCIViewID 
		ORDER BY Priority
	END
		
	if (@Type ='HDRLIST')
	BEGIN
		SELECT NCIViewObjectID, ObjectID, Priority 
		From ViewObjects 
		WHERE TYPE='HDRLIST' AND NCIViewID=@NCIViewID 
		ORDER BY Priority
	END

	if (@Type ='INCLUDE')
	BEGIN	
		SELECT NCIViewObjectID, ObjectID, Priority 
		from ViewObjects 
		where Type = 'IMAGE' and NCIViewID =@NCIViewID  
		order by Priority
	END	

	if (@Type ='INFOBOX')
	BEGIN
		SELECT ObjectInstanceID, NCIObjectID, Priority
		FROM NCIObjects
		WHERE ParentNCIObjectID =@NCIViewID AND (ObjectType = 'list' OR ObjectType = 'navdoc' OR ObjectType Like '%image')
		ORDER by Priority 
	END
			
	if (@Type ='LEFTNAV')
	BEGIN
		SELECT NCIViewObjectID, Priority 
		FROM VIEWOBJECTS
		WHERE NCIViewID =@NCIViewID AND (Type = 'list' OR Type = 'navdoc' OR Type Like '%image' or Type Like '%infobox' or Type like '%ncsearch' or Type like '%ftsearch') 
		ORDER by Priority 
	END



	if (@Type ='LISTHOME')
	BEGIN
		SELECT V.NCIViewObjectID, V.ObjectID, V.Priority 
		FROM VIEWOBJECTS V, List L
		WHERE V.NCIViewID =@NCIViewID 
		AND V.Type not in ('HEADER', 'HDRLIST' )
		and V.ObjectID = L.ListID
		ORDER by V.Priority 
	END	

	if (@Type ='NEWSLETTER')
	BEGIN	
		SELECT NCIViewObjectID, ObjectID, Priority 
		FROM ViewObjects 
		WHERE Type in ('NLSECTION', 'NLLIST') AND NCIViewID=@NCIViewID  
		ORDER by Priority
	END

	if (@Type ='RIGHTNAV')
	BEGIN
		SELECT NCIViewObjectID, Priority 
		FROM VIEWOBJECTS
		WHERE NCIViewID =@NCIViewID AND (Type like '%list' OR Type like '%doc' OR Type Like '%image') 
		ORDER by Priority 
	END
		
END


GO
GRANT EXECUTE ON [dbo].[usp_RetrievePriority] TO [webadminuser_role]
GO
