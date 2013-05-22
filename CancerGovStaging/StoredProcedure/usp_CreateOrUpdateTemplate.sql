IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_CreateOrUpdateTemplate]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_CreateOrUpdateTemplate]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--***********************************************************************
-- Create New Object 
--************************************************************************

/****** 	Object:  Stored Procedure dbo.usp_InsertNewsletter
	Owner:	Jay He
	Script Date: 3/19/2003 14:43:49 pM 
******/

CREATE PROCEDURE dbo.usp_CreateOrUpdateTemplate
(
	@NCITemplateID	UniqueIdentifier,
	@Name			VarChar(50),
	@URL			VarChar(2000),
	@Description		VarChar(255),
	@AddURL		VarChar(100),
	@EditURL		VarChar(100),
	@ClassName 		VarChar(50),
	@UpdateUserID		varchar(50)						
)
AS
BEGIN						

	if (not exists (select NCITemplateID from NCITemplate where NCITemplateID=@NCITemplateID))
	BEGIN
		Insert into NCITemplate 
		(NCITemplateID, [Name], URL, [Description], AddURL, EditURL, ClassName, UpdateUserID) 
		values 
		(@NCITemplateID, @Name,  @URL, @Description, @AddURL,  @EditURL,  @ClassName, @UpdateUserID)
		IF (@@ERROR <> 0)
		BEGIN
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 
	END
	ELSE
	BEGIN
		update NCITemplate 
		set 	[Name]	=@Name, 
			URL	= @URL, 
			[Description]	=	@Description, 
			AddURL	=	@AddURL, 
			EditURL 	=	@EditURL,	
			ClassName	= 	@ClassName,			
			UpdateDate	= 	getdate(),  
			UpdateUserID  	=	@UpdateUserID  
		 where NCITemplateID=@NCITemplateID
		IF (@@ERROR <> 0)
		BEGIN
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 
	END

	RETURN 0 

END

GO
GRANT EXECUTE ON [dbo].[usp_CreateOrUpdateTemplate] TO [webadminuser_role]
GO
