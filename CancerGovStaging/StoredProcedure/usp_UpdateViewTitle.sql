IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_UpdateViewTitle]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_UpdateViewTitle]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/****** Object:  Stored Procedure dbo.usp_UpdateNCIView   Owner:Jhe Purpose: For admin side Script Date: 1/15/2002 16:00:49 pm ******/		
					
					
CREATE PROCEDURE dbo.usp_UpdateViewTitle
(										
	@Title 			VarChar(255),											
	@ShortTitle      		VarChar(64),
	@Description     		VarChar(2500),
	@ExpirationDate 	DateTime,
	@ReleaseDate		DateTime,
	@UpdateUserID	   	VarChar(40),
	@PostedDate      	DateTime,
	@ReviewedDate      	DateTime,
	@DisplayDateMode	VarChar(10),
	@NCIViewID		UniqueIdentifier
)
AS
	SET NOCOUNT OFF;

	UPDATE NCIView 
	set	 Title =@Title, 
		ShortTitle =@ShortTitle, 
		[Description] = @Description,  
		ExpirationDate =@ExpirationDate, 
		ReleaseDate= @ReleaseDate, 
		UpdateUserID=@UpdateUserID, 
		PostedDate= @PostedDate, 
		ReviewedDate = @ReviewedDate,
		DisplayDateMode =@DisplayDateMode, 
		Status ='EDIT' 
	where NCIViewID 	= @NCIViewID		


	SET NOCOUNT OFF;


GO
GRANT EXECUTE ON [dbo].[usp_UpdateViewTitle] TO [webadminuser_role]
GO
