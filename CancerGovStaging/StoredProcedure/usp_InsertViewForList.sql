IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_InsertViewForList]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_InsertViewForList]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** 	Object:  Stored Procedure dbo.usp_InsertBViewForList    not finished yet
	Purpose: This script is used for create a ncivew for list, list_cols and menu_multi, a list and a viewobject.This will be a transactional script, which creates a nciview and a viewobject.
	Script Date: 1/30/2002 11:43:49 pM ******/

CREATE PROCEDURE dbo.usp_InsertViewForList
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

	
	BEGIN TRAN Tran_InsertViewForList
	/*
	** STEP - A
	** Insert a new row into NCIView table
	** if not return a 70004 error
	*/		

	INSERT INTO NCIView 
	(Title,  ShortTitle,  [Description],  URL, URLArguments,   NCIViewID,  IsLinkExternal,  Status,  NCITemplateID, UpdateUSerID, GroupID, NCISectionID)
 	VALUES 
	(@Title, @ShortTitle, @Description, @URL, 'viewid=' + Convert(VarChar(50), @NCIViewID), @NCIViewID, 0, 'Edit', @NCITemplateID,  @UpdateUSerID, @GroupID, @NCISectionID)			
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_InsertViewForList
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	/*
	** STEP -  B
	** Insert a new row into List table
	** if not return a 70004 error
	*/	
	INSERT INTO List 
	(ListID, ListName, ListDesc, UpdateUserID) 
	VALUES 
	(@ListID, @Title, @Description, @UpdateUserID)
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_InsertViewForList
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	/*
	** STEP -  C
	** Insert a new row into ViewObjects table
	** if not return a 70004 error
	*/	
	INSERT INTO ViewObjects 
	(NCIViewID, ObjectID, Type, Priority, UpdateUserID) 
	 VALUES 
	(@NCIViewID, @ListID, 'List', 1, @UpdateUserID)		
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_InsertViewForList
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	COMMIT TRAN  Tran_InsertViewForList
	SET NOCOUNT OFF
	RETURN 0 

END

GO
GRANT EXECUTE ON [dbo].[usp_InsertViewForList] TO [webadminuser_role]
GO
