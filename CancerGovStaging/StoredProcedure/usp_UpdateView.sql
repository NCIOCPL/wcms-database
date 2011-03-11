IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_UpdateView]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_UpdateView]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/**********************************************************************************

	Object's name:	usp_UpdateView
	Object's type:	store proc
	Purpose:	Update NCIView
	Author:		1/15/2002	Jhe	For admin side Script
			10/25/2004	Lijia	Remove OLDURL,HTMLAddendum and add ReviewedDate, ChangeComments
			2/04/2005	Lijia	For SCR1039
**********************************************************************************/					
					
CREATE PROCEDURE dbo.usp_UpdateView
(
	@NCIViewID		UniqueIdentifier,
	@Title 			VarChar(255),											
	@ShortTitle      	VarChar(64),
	@Description     	VarChar(2500),	
	@ExpirationDate 	DateTime,
	@ReleaseDate		DateTime,
	@MetaTitle		VarChar(255),
	@MetaDescription 	VarChar(255),
	@MetaKeyword		VarChar(255),
	@UpdateUserID	   	VarChar(40),
	@PostedDate      	DateTime,
	@DisplayDateMode	VarChar(10),
	@ReviewedDate		DateTime=NULL,
	@ChangeComments		Varchar(2000)=NULL											

	
)
AS
	SET NOCOUNT OFF;

	UPDATE NCIView 
	set 	Title 		=@Title, 
		ShortTitle	=@ShortTitle, 
		[Description] 	=@Description,  
		ExpirationDate 	=@ExpirationDate, 
		ReleaseDate	=@ReleaseDate, 
		MetaTitle	=@MetaTitle, 
		MetaDescription	=@MetaDescription, 
		MetaKeyword	=dbo.udf_TrimSpaceForMetaKeyword(@MetaKeyword), 
		UpdateUserID	=@UpdateUserID, 
		PostedDate	=@PostedDate, 
		DisplayDateMode =@DisplayDateMode ,
		ReviewedDate	=ISNULL(@ReviewedDate, getdate()),
		ChangeComments	=@ChangeComments,
		updatedate	=Getdate()
	where NCIViewID 	= @NCIViewID
 	
	SET NOCOUNT OFF;



GO
GRANT EXECUTE ON [dbo].[usp_UpdateView] TO [webadminuser_role]
GO
