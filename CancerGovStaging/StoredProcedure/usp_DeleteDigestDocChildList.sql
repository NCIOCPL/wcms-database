IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_DeleteDigestDocChildList]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_DeleteDigestDocChildList]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** 	Object:  Stored Procedure dbo.usp_InsertViewObject    
	Purpose: This script can be used for  inserting view objects property value.	Script Date: 8/13/2003 11:43:49 pM ******/

CREATE PROCEDURE dbo.usp_DeleteDigestDocChildList
(
	@ListID			UniqueIdentifier
)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN  TRAN   Tran_CreateOrUpdatePrettyURL

	Delete from CancerGovStaging..Listitem where listid = @ListID
	IF (@@ERROR <> 0)
	BEGIN
		Rollback tran Tran_CreateOrUpdatePrettyURL
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	Delete from CancerGovStaging..List where listid = @ListID
	IF (@@ERROR <> 0)
	BEGIN
		Rollback tran Tran_CreateOrUpdatePrettyURL
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	COMMIT tran  Tran_CreateOrUpdatePrettyURL

	SET NOCOUNT OFF
	RETURN 0 

END
GO
GRANT EXECUTE ON [dbo].[usp_DeleteDigestDocChildList] TO [webadminuser_role]
GO
