IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_UpdateViewSimple]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_UpdateViewSimple]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.usp_UpdateViewForUploadFile   Owner:Jhe Purpose: For admin side Script Date: 1/30/2002 16:00:49 pm ******/		
					
					
CREATE PROCEDURE dbo.usp_UpdateViewSimple
(
	@NCIViewID		UniqueIdentifier,
	@PostedDate		DateTime ,
	@DisplayDateMode	varchar(10),
	@UpdateUserID	   	VarChar(40)
)
AS
	SET NOCOUNT OFF;

	UPDATE NCIView 
	set 	PostedDate 	= @PostedDate	,
		DisplayDateMode	= @DisplayDateMode,
		Status		='EDIT',
		UpdateUserID	=@UpdateUserID 
	where NCIViewID 	= @NCIViewID
 	
	SET NOCOUNT OFF;
GO
GRANT EXECUTE ON [dbo].[usp_UpdateViewSimple] TO [webadminuser_role]
GO
