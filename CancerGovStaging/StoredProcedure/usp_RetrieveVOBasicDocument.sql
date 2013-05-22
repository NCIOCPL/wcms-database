IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_RetrieveVOBasicDocument]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_RetrieveVOBasicDocument]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO




--***********************************************************************
-- Create New Object 
--************************************************************************

/****** Object:  Stored Procedure dbo.usp_RetrieveViewObject
   Owner:Jhe Purpose: For admin side Script Date: 1/15/2002 16:00:49 pm ******/

CREATE PROCEDURE dbo.usp_RetrieveVOBasicDocument
	(
	@ObjectID	uniqueidentifier
	)
AS
BEGIN
	
	SELECT VO.NCIViewObjectID, Vo.ObjectID, VO.Type, VO.Priority, 'Name'=L.ListName FROM VIEWOBJECTS VO, List L WHERE VO.NCIViewID =@ObjecTID AND VO.Type ='LIST' and L.ListID = VO.ObjectID 
	Union 
	SELECT VO.NCIViewObjectID, Vo.ObjectID, VO.Type, VO.Priority, 'Name'=D.ShortTitle FROM VIEWOBJECTS VO, Document D WHERE VO.NCIViewID =@ObjectID AND VO.Type in ( 'DOCUMENT', 'INCLUDE', 'TXTINCLUDE', 'HDRDOC' ,'SEARCH', 'VIRSEARCH' ) and D.DocumentID = VO.ObjectID 
	Union 
	SELECT VO.NCIViewObjectID, Vo.ObjectID, VO.Type, VO.Priority, 'Name'=H.Name FROM VIEWOBJECTS VO, HEADER H WHERE VO.NCIViewID =@ObjecTID AND VO.Type ='BODYHEADER' and H.HEADERID = VO.ObjectID 
	Union 
	SELECT VO.NCIViewObjectID, Vo.ObjectID, VO.Type, VO.Priority, 'Name'=VO.Type FROM VIEWOBJECTS VO WHERE VO.NCIViewID =@ObjectID AND VO.Type in ( 'TITLEBLOCK', 'SCTSEARCH',  'GRAYBAR', 'DATESEARCH', 'CBSEARCH')
	ORDER by VO.Priority 			
END

GO
GRANT EXECUTE ON [dbo].[usp_RetrieveVOBasicDocument] TO [webadminuser_role]
GO
