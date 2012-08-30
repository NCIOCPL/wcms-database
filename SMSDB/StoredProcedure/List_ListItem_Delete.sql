IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[List_ListItem_Delete]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[List_ListItem_Delete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
	CREATE  PROCEDURE  dbo.List_ListItem_Delete(
		@ListItemInstanceID uniqueidentifier
		, @UpdateUserID varchar(50)
	)
	/**************************************************************************************************
	* Name		: [dbo.List_ListItem_Delete]
	* Purpose	: [deletes a listitem]
	* Author	: [SR]
	* Date		: [04/27/2006]
	* Parameters: [ListItemInstanceID, UpdateUserId]
	* Returns	: [n/a]
	* Usage		: [dbo.List_ListItem_Delete '496F2B93-3115-40EC-ADFF-9491E88F82B3', 'ramaiahs']
	* Changes	: []
	**************************************************************************************************/
	AS
	BEGIN
		BEGIN TRY
			
			DECLARE @rtnValue int,
					@ListID uniqueidentifier

			SELECT @ListID = ListID
			FROM ListItem
			WHERE ListItemInstanceID = @ListItemInstanceID

			--Delete the list item
			DELETE ListItem
			WHERE ListItemInstanceID = @ListItemInstanceID

			exec @rtnValue = Core_Object_SetIsDirty
				@ObjectID = @ListID,
				@UpdateUserID= @UpdateUserID

			if (@rtnValue >0)
				return @rtnValue
			
			RETURN 0
		END TRY
		BEGIN CATCH 
			--Return Error Number
			RETURN 11102
		END CATCH	  	  	  
	END

GO
GRANT EXECUTE ON [dbo].[List_ListItem_Delete] TO [websiteuser_role]
GO
