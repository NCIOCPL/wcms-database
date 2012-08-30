IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[List_ListItem_Add]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[List_ListItem_Add]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
	CREATE  PROCEDURE  dbo.List_ListItem_Add(
		@ListId uniqueidentifier
		, @ListItemID uniqueidentifier
		, @ListItemTypeID int
		, @IsFeatured bit
		, @CreateUserID varchar(50)
		, @ListItemInstanceID uniqueidentifier OUTPUT
		
	)
	/**************************************************************************************************
	* Name		: [dbo.List_ListItem_Add]
	* Purpose	: [Creates a new list item]
	* Author	: [SR]
	* Date		: [04/27/2006]
	* Parameters: []
	* Returns	: []
	* Usage		: [dbo.List_ListItem_Add '563A612D-BF11-4EF4-9ED8-76F0A8FDBC4B', null, 2, 0, 0, '', '', '', '', '', '', 0, 1, 'ramaiahs']
	* Changes	: []
	**************************************************************************************************/
	AS
	BEGIN
	  --Declaration
		Declare @Priority int,
				@rtnValue int
		
	  --Initialization
		Set @ListItemInstanceID = NewId()

		--get the priority 
		if (exists (select * from dbo.ListItem where ListID = @ListID))
		BEGIN
			select @Priority= max(priority) + 1 from dbo.ListItem where ListID = @ListID
		END
		ELSE
		BEGIN
			select @Priority = 1
		END


		--Set @OwnerID = ''
	  --Execute
		BEGIN TRY
			Insert Into dbo.ListItem(
				ListItemInstanceID
				, ListID
				, ListItemID
				, ListItemTypeID
				, IsFeatured
				, Priority
				, CreateUserID
				, CreateDate
				, UpdateUserID
				, UpdateDate
			)
			Values(
				@ListItemInstanceID
				, @ListID
				, @ListItemID
				, @ListItemTypeID
				, @IsFeatured
				, @Priority
				, @CreateUserID
				, getdate()
				, @CreateUserID
				, getdate()
			)

			--Set the object as dirty			
			exec @rtnValue = Core_Object_SetIsDirty
				@ObjectID = @ListID,
				@UpdateUserID = @CreateUserID

			if (@rtnValue >0)
				return @rtnValue

			RETURN 0
		END TRY
		BEGIN CATCH 
			--Return Error Number
			RETURN 11101
		END CATCH	  	  	  
	END

GO
GRANT EXECUTE ON [dbo].[List_ListItem_Add] TO [websiteuser_role]
GO
