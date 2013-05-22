IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_ExistDigestDocList]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_ExistDigestDocList]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** 	Object:  Stored Procedure dbo.usp_InsertViewObject    
	Purpose: This script can be used for  inserting view objects property value.	Script Date: 8/13/2003 11:43:49 pM ******/

CREATE PROCEDURE dbo.usp_ExistDigestDocList
(
	@ObjectID		UniqueIdentifier
)
AS

	select L.ListID from List L,  ViewObjectProperty V,  ViewObjects VO
	where L.ListID = V.PropertyValue and V.NCIViewObjectID = VO.NCIViewObjectID
	and  VO.ObjectID= @ObjectID and V.PropertyName=  'DigestRelatedListID' order by L.Priority
	IF (@@ERROR <> 0)
	BEGIN
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END
GO
GRANT EXECUTE ON [dbo].[usp_ExistDigestDocList] TO [webadminuser_role]
GO
