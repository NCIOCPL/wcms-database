IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_RetrieveDigestDocListNCIView]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_RetrieveDigestDocListNCIView]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** 	Object:  Stored Procedure dbo.usp_InsertViewObject    
	Purpose: This script can be used for  inserting view objects property value.	Script Date: 8/13/2003 11:43:49 pM ******/

CREATE PROCEDURE dbo.usp_RetrieveDigestDocListNCIView
(
	@ListID		UniqueIdentifier
)
AS

	select N.NCIViewID, N.GroupID, N.NCISectionID from NCIView N,   ViewObjects VO, ViewObjectProperty V,  List L
	Where Convert(varchar(36), L.parentListID) = V.PropertyValue and V.NCIViewObjectID = VO.NCIViewObjectID and VO.NCIViewID = N.NCIViewID
	and V.PropertyName=  'DigestRelatedListID' and L.ListID =@ListID
	IF (@@ERROR <> 0)
	BEGIN
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END
GO
GRANT EXECUTE ON [dbo].[usp_RetrieveDigestDocListNCIView] TO [webadminuser_role]
GO
