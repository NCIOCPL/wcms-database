IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[List_ListItemType_Delete]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[List_ListItemType_Delete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
	CREATE  PROCEDURE  dbo.List_ListItemType_Delete(
		@ListItemTypeID int
	)
	/**************************************************************************************************
	* Name		: [dbo.List_ListItemType_Delete]
	* Purpose	: []
	* Author	: []
	* Date		: [04/27/2006]
	* Parameters: []		
	* Returns	: []
	* Usage		: []
	* Changes	: []
	**************************************************************************************************/
	AS
	BEGIN
		BEGIN TRY
			Delete dbo.ListItemType
			Where ListItemTypeID = @ListItemTypeID
		END TRY
		BEGIN CATCH 
			RETURN 11202
		END CATCH	  	  	  
	END

GO
GRANT EXECUTE ON [dbo].[List_ListItemType_Delete] TO [websiteuser_role]
GO
