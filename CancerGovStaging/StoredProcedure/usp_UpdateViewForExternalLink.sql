IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_UpdateViewForExternalLink]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_UpdateViewForExternalLink]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/**********************************************************************************

	Object's name:	usp_UpdateViewForExternalLink
	Object's type:	store proc
	Purpose:	update NCIView
	Author:		1/15/2002	Jhe	For admin side Script
			10/25/2004	Lijia	Remove OLDURL,HTMLAddendum and add ReviewedDate, ChangeComments
			2/04/2005	Lijia	For SCR1039
**********************************************************************************/
					
CREATE PROCEDURE dbo.usp_UpdateViewForExternalLink
(
	@NCIViewID		UniqueIdentifier,
	@Title 			VarChar(255),											
	@ShortTitle      		VarChar(64),
	@Description     		VarChar(2500),
	@ExpirationDate 	DateTime,
	@ReleaseDate		DateTime,
	@MetaTitle		VarChar(255),
	@MetaDescription 	VarChar(255),
	@MetaKeyword		VarChar(255),
	@SpiderDepth		int,
	@IsLinkExternal		bit,
	@UpdateUserID	   	VarChar(40),
	@PostedDate      	DateTime,
	@DisplayDateMode	VarChar(10),
	@URL			varchar(1000),
	@Type			varchar(40),
	@ReviewedDate		DateTime=NULL,
	@ChangeComments		Varchar(2000)=NULL
								
)
AS
	SET NOCOUNT OFF;

	if (@Type ='ADMIN')
	BEGIN
	UPDATE NCIView 
	set 	Title =@Title, 
		ShortTitle =@ShortTitle, 
		[Description] = @Description,   
		URL=@URL,  
		ExpirationDate =@ExpirationDate, 
		ReleaseDate= @ReleaseDate, 
		MetaTitle=@MetaTitle, 
		MetaDescription=@MetaDescription, 
		MetaKeyword=dbo.udf_TrimSpaceForMetaKeyword(@MetaKeyword), 
		SpiderDepth=@SpiderDepth, 
		IsLinkExternal=@IsLinkExternal, 
		UpdateUserID=@UpdateUserID, 
		PostedDate= @PostedDate, 
		DisplayDateMode =@DisplayDateMode,
		ReviewedDate=ISNULL(@ReviewedDate, getdate()),
		ChangeComments=@ChangeComments,
		updatedate=Getdate(),
		Status ='EDIT'
	where NCIViewID 	= @NCIViewID
 	END
	ELSE
	BEGIN
		UPDATE NCIView 
		set Title =@Title, 
		ShortTitle =@ShortTitle, 
		[Description] = @Description,  
		URL=@URL, 
		ExpirationDate =@ExpirationDate, 
		ReleaseDate= @ReleaseDate, 
		MetaTitle=@MetaTitle, 
		MetaDescription=@MetaDescription, 
		MetaKeyword=dbo.udf_TrimSpaceForMetaKeyword(@MetaKeyword),  
		IsLinkExternal=@IsLinkExternal, 
		UpdateUserID=@UpdateUserID, 
		PostedDate= @PostedDate, 
		DisplayDateMode =@DisplayDateMode, 
		ReviewedDate=ISNULL(@ReviewedDate, getdate()),
		ChangeComments=@ChangeComments,
		updatedate=Getdate(),
		Status ='EDIT' 
	where NCIViewID 	= @NCIViewID		
	END


	SET NOCOUNT OFF;



GO
GRANT EXECUTE ON [dbo].[usp_UpdateViewForExternalLink] TO [webadminuser_role]
GO
