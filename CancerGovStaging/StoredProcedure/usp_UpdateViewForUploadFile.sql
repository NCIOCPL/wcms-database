IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_UpdateViewForUploadFile]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_UpdateViewForUploadFile]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.usp_UpdateViewForUploadFile   Owner:Jhe Purpose: For admin side Script Date: 1/30/2002 16:00:49 pm ******/		
					
					
CREATE PROCEDURE dbo.usp_UpdateViewForUploadFile
(
	@NCIViewID		UniqueIdentifier,
	@Title 			VarChar(255),											
	@ShortTitle      		VarChar(50),
	@Description     		VarChar(2500),
	@Status		VarChar(10),
	@UpdateUserID	   	VarChar(40)
)
AS
	SET NOCOUNT OFF;

	UPDATE NCIView 
	set 	Title 		=@Title, 
		ShortTitle	=@ShortTitle, 
		[Description] 	=@Description,  
		Status		=@Status,
		UpdateUserID	=@UpdateUserID 
	where NCIViewID 	= @NCIViewID
 	
	SET NOCOUNT OFF;
GO
