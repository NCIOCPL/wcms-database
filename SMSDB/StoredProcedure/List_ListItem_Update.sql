IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[List_ListItem_Update]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[List_ListItem_Update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
	CREATE  PROCEDURE  dbo.List_ListItem_Update(
		@ListItemInstanceID uniqueidentifier
		, @OverriddenTitle varchar(255)
		, @OverriddenShortTitle varchar(50)
		, @OverriddenDescription varchar(500)
		, @overriddenAnchor varchar(255)
		, @overriddenQueryParams varchar(512)
		, @FileSize varchar(50)
		, @FileIcon varchar(256)
		, @SupplementalText varchar(256)
		, @IsFeatured bit
		, @UpdateUserID varchar(50)
	)
	/**************************************************************************************************
	* Name		: dbo.List_ListItem_Update
	* Purpose	: updates list item
	* Author	: 
	* Date		: 04/27/2006
	* Returns	: 
	* Usage		: dbo.List_ListItem_Update '4FCC53E8-29FC-41A9-AC81-702720B47A19', null, null, null, null, null, 0, 'ramaiahs'
	* Changes	: 09/30/2006 SR: added anchor and quey params
	**************************************************************************************************/
	AS
	BEGIN
		DECLARE @rtnValue int,
				@ListID uniqueidentifier

		SELECT @ListID = ListID
		FROM ListItem
		WHERE ListItemInstanceID = @ListItemInstanceID

	  --Execute
		BEGIN TRY

			Update dbo.ListItem
			Set 
				OverriddenTitle = @OverriddenTitle,
				OverriddenShortTitle = @OverriddenShortTitle,
				OverriddenDescription = @OverriddenDescription,
				OverriddenAnchor = @overriddenAnchor,
				OverriddenQuery = @overriddenQueryParams,
				FileSize = @fileSize,
				FileIcon = @fileIcon,
				SupplementalText = @SupplementalText,
				IsFeatured = @IsFeatured,
				UpdateUserID = @UpdateUserID,
				UpdateDate = getdate()
			Where ListItemInstanceID = @ListItemInstanceID
			
			exec @rtnValue = Core_Object_SetIsDirty
				@ObjectID = @ListID,
				@UpdateUserID= @UpdateUserID

			if (@rtnValue >0)
				return @rtnValue

		END TRY
		BEGIN CATCH 
			--Return Error Number
			RETURN 11101
		END CATCH	  	  	  
	END

GO
GRANT EXECUTE ON [dbo].[List_ListItem_Update] TO [websiteuser_role]
GO
