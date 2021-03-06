USE [CancerGovStaging]
GO
/****** Object:  StoredProcedure [dbo].[usp_InsertViewForRSS]    Script Date: 08/06/2009 11:03:10 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** 	Object:  Stored Procedure dbo.[usp_InsertViewForRSS]    not finished yet
	Purpose: This script is used for create a ncivew for list, list_cols and menu_multi, a list and a viewobject.This will be a transactional script, which creates a nciview and a viewobject.
	Script Date: 1/30/2002 11:43:49 pM ******/

Create PROCEDURE [dbo].[usp_InsertViewForRSS]
(
	@Title              		VarChar(255),
	@ShortTitle      		VarChar(64),
	@Description    		VarChar(1500),
	@NCIViewID       	UniqueIdentifier,
	@NCITemplateID	UniqueIdentifier,
	@UpdateUserID		VarChar(40),
	@Section		VarChar(40),
	@GroupID		int
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE 	@NCISectionID 	uniqueidentifier,
		   	@ListID		uniqueidentifier,
			@SectionURL	varchar(50),
			@TemplateURL	varchar(50),
			@URL              	VarChar(1000 )

	select @ListID= newid()

	select @NCISectionID= NCISectionID, @SectionURL=URL from NCISection WHERE Name =  @Section  --get section url for view url

	select @TemplateURL = URL  FROM NCITemplate WHERE NCITemplateID = @NCITemplateID   -- get ncitemplateid for view url

	select @URL=  '/templates/' + @TemplateURL 



	INSERT INTO NCIView 
	(Title,  ShortTitle,  [Description],  URL, URLArguments,   NCIViewID,  IsLinkExternal,  Status,  NCITemplateID, UpdateUSerID, GroupID, NCISectionID)
 	VALUES 
	(@Title, @ShortTitle, @Description, @URL, 'viewid=' + Convert(VarChar(50), @NCIViewID), @NCIViewID, 0, 'Edit', @NCITemplateID,  @UpdateUSerID, @GroupID, @NCISectionID)			
	IF (@@ERROR <> 0)
	BEGIN
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 
	SET NOCOUNT OFF
	RETURN 0 

END

GO


GRANT EXECUTE ON [dbo].usp_InsertViewForRSS TO webadminuser_role

GO
