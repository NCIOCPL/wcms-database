IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_CheckPrimaryRootPU]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_CheckPrimaryRootPU]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** 	Object:  Stored Procedure dbo.dbo.usp_InsertUploadFile    
	Purpose: This script can be used for uploading files, including pdf, xml, include and image files. This will be a transactional script, which creates a nciview and a viewobject.
	Script Date: 1/30/2002 11:43:49 pM ******/

CREATE PROCEDURE dbo.usp_CheckPrimaryRootPU
(
		@PrettyURLID		UniqueIdentifier,
		@NCIViewID       	UniqueIdentifier
)
AS
BEGIN
	


	select  count(*) from prettyurl where nciviewid=@NCIViewID and isprimary=1	
	 and isroot=1 and prettyurlID !=@PrettyURLID


END
GO
GRANT EXECUTE ON [dbo].[usp_CheckPrimaryRootPU] TO [webadminuser_role]
GO
