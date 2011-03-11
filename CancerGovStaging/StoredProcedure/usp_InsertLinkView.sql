IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_InsertLinkView]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_InsertLinkView]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** 	Object:  Stored Procedure dbo.usp_InsertLinkView
	Purpose: This script is used for creating a new link view and create a listitem. This will be a transactional script.
	Script Date: 1/30/2002 11:43:49 pM ******/

CREATE PROCEDURE dbo.usp_InsertLinkView
(
	@Title           		VarChar(255),
	@ShortTitle     		VarChar(64),
	@Description    		VarChar(1500),
	@URL			VarChar(1000),
	@NCIViewID 		UniqueIdentifier,
	@IsLinkExternal		Bit,
	@Status		Char(10),
	@UpdateUserID		VarChar(40),
	@GroupID		Int,
	@NCISectionID		UniqueIdentifier,
	@ListID			UniqueIdentifier,
	@PostedDate	 DateTime 
)
AS
BEGIN
	SET NOCOUNT ON;

	Declare @Priority 		int,
		@Count 		int

	
	select @Count = count(V.Type) from list L, ViewObjects V  where L.ListID=V.ObjectID and V.Type ='NLLIST' AND L.listid=@ListID		

	if (@Count =0)
	BEGIN
		if (exists (select * from listitem where listID =@ListID))
		BEGIN
			select @Priority = max(priority) + 1 from listitem where listID =@ListID
		END
		ELSE
		BEGIN
			select @Priority = 1
		END
	END
	ELSE	
	BEGIN
		if (exists (select * from NLlistitem where listID =@ListID))
		BEGIN
			select @Priority = max(priority) + 1 from NLlistitem where listID =@ListID
		END
		ELSE
		BEGIN
			select @Priority = 1
		END
	END


	BEGIN TRAN Tran_InsertLinkView
	/*
	** STEP - A
	** Insert a new row into NCIView table
	** if not return a 70004 error
	*/		

	select @Status = 'PRODUCTION'

	INSERT INTO NCIView 
	(Title,  ShortTitle,  Description,  URL,  NCIViewID, IsLinkExternal, Status, UpdateUserID, GroupID, NCISectionID, ISONPRODUCTION, PostedDate)
	 VALUES 
	(@Title, @ShortTitle, @Description, @URL, @NCIViewID, @IsLinkExternal, @Status, @UpdateUserID, @GroupID, @NCISectionID, 1, @PostedDate)
			
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_InsertLinkView
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 


	INSERT INTO CancerGov..NCIView 
      (Title,  ShortTitle,  Description,  URL,  NCIViewID, IsLinkExternal, Status, UpdateUserID, GroupID, NCISectionID, ISONPRODUCTION, PostedDate)
       VALUES 
      (@Title, @ShortTitle, @Description, @URL, @NCIViewID, @IsLinkExternal, @Status, @UpdateUserID, @GroupID, @NCISectionID, 1, @PostedDate)
                  
      IF (@@ERROR <> 0)
      BEGIN
            ROLLBACK TRAN Tran_InsertLinkView
            RAISERROR ( 70004, 16, 1)
            RETURN 70004
      END




	/*
	** STEP - B
	** Add a list item for the above-created view  -- 2 cases: ListItem or NLListItem
	*/	
	if (@Count =0)
	BEGIN
		INSERT INTO ListItem 
		(ListID, NCIViewID, UpdateUserId, Priority) 
		VALUES 
		(@ListID, @NCIViewID, @UpdateUserID, @Priority)
	
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_InsertLinkView
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END
	END
	ELSE
 	BEGIN
		INSERT INTO NLListItem 
		(ListID, Title, ShortTitle, [Description], NCIViewID, Priority, UpdateDate, UpdateUserID)  
		VALUES 
		(@ListID, @Title, @ShortTitle, @Description, @NCIViewID, @Priority, getdate(),  @UpdateUserID)		
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_InsertLinkView
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END
	END

	COMMIT TRAN  Tran_InsertLinkView
	SET NOCOUNT OFF
	RETURN 0 

END

GO
GRANT EXECUTE ON [dbo].[usp_InsertLinkView] TO [webadminuser_role]
GO
