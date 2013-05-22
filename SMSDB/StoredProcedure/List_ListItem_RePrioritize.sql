IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[List_ListItem_RePrioritize]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[List_ListItem_RePrioritize]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
	CREATE  PROCEDURE  dbo.List_ListItem_RePrioritize(
		@ListItemInstanceID uniqueidentifier
		, @Priority int
		, @UpdateUserID varchar(50)
	)
	/**************************************************************************************************
	* Name		: [dbo.List_ListItem_RePrioritize]
	* Purpose	: [updates Priority]
	* Author	: [SR]
	* Date		: [04/27/2006]
	* Parameters: [ListID, ListItemId, Priority, UpdateUserID]
	* Returns	: [0 or errocode]
	* Usage		: [dbo.List_ListItem_RePrioritize '563A612D-BF11-4EF4-9ED8-76F0A8FDBC4B', '61358D2C-10C6-4665-9D62-46EFD9D35C5B', 1, 'ramaiahs']
	* Changes	: []
	**************************************************************************************************/
	AS
	BEGIN
	  --Declaration
		Declare @rtnValue int,
				@ListID uniqueidentifier

	  --Initialization
		SELECT @ListID = ListID 
		FROM dbo.ListItem 
		WHERE ListItemInstanceID = @ListItemInstanceID

	  --Execute
		BEGIN TRY
			Update dbo.ListItem
			Set Priority = @Priority
				, UpdateUserID = @UpdateUserID
				, UpdateDate = getdate()
			Where ListItemInstanceID = @ListItemInstanceID

			--Set the object as dirty			
			exec @rtnValue = Core_Object_SetIsDirty
				@ObjectID = @ListID,
				@UpdateUserID= @UpdateUserID

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
GRANT EXECUTE ON [dbo].[List_ListItem_RePrioritize] TO [websiteuser_role]
GO
