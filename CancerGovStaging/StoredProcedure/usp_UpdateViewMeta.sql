IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_UpdateViewMeta]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_UpdateViewMeta]
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
			2/04/2005	Lijia	For SCR1039

**********************************************************************************/					
					
CREATE PROCEDURE dbo.usp_UpdateViewMeta
(																					
	@MetaTitle		VarChar(255),
	@MetaDescription 	VarChar(255),
	@MetaKeyword		VarChar(255),
	@UpdateUserID	   	VarChar(40),
	@PostedDate      	DateTime,
	@DisplayDateMode	VarChar(10),
	@NCIViewID		UniqueIdentifier			
)
AS
	SET NOCOUNT OFF;

	UPDATE NCIView 
	set 	MetaTitle=@MetaTitle, 
		MetaDescription=@MetaDescription, 
		MetaKeyword=dbo.udf_TrimSpaceForMetaKeyword(@MetaKeyword), 
		UpdateUserID=@UpdateUserID, 
		PostedDate= @PostedDate, 
		DisplayDateMode =@DisplayDateMode,
		updatedate=Getdate(),
		Status ='EDIT' 
	where NCIViewID 	= @NCIViewID
 
	SET NOCOUNT OFF;

GO
GRANT EXECUTE ON [dbo].[usp_UpdateViewMeta] TO [webadminuser_role]
GO
