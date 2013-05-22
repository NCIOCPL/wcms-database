IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[List_ListItemType_Get]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[List_ListItemType_Get]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
	CREATE  PROCEDURE  dbo.List_ListItemType_Get(@ListItemTypeID int)
	
	/**************************************************************************************************
	* Name		: [dbo.List_ListItemType_Get]
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
			SELECT t.ListItemTypeID, t.TypeName, t.IconPath
			FROM dbo.ListItemType t
			Where t.ListItemTypeID = @ListItemTypeID
		END TRY
		BEGIN CATCH 
			RETURN 11203
		END CATCH	  	  	  
	END

GO
GRANT EXECUTE ON [dbo].[List_ListItemType_Get] TO [websiteuser_role]
GO
