IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_CheckPrimaryPU]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_CheckPrimaryPU]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** 	Object:  Stored Procedure dbo.dbo.usp_InsertUploadFile    
	Purpose: This script can be used for uploading files, including pdf, xml, include and image files. This will be a transactional script, which creates a nciview and a viewobject.
	Script Date: 1/30/2002 11:43:49 pM ******/

CREATE PROCEDURE dbo.usp_CheckPrimaryPU
(
	@NCIViewID       	UniqueIdentifier,
	@PrettyURLID		UniqueIdentifier
)
AS
BEGIN
	
	Declare @Count int,
		@PCount int,
		@result int

	select @Count = count(*) from prettyurl where nciviewid=@NCIViewID 
	 and isroot=1 and prettyurlID !=@PrettyURLID

	select @result =0
		
	if (@Count >0)
	BEGIN
		select @PCount = count(*) from prettyurl where isprimary=1 and prettyurlID =@PrettyURLID
		if (@PCount =1)
		BEGIN
			return 1
		END
		ELSE
		BEGIN
			return 0
		END
	END
	ELSE
	BEGIN
		return 0
	END

END
GO
