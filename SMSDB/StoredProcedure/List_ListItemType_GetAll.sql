IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[List_ListItemType_GetAll]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[List_ListItemType_GetAll]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
	CREATE  PROCEDURE  dbo.List_ListItemType_GetAll
	/**************************************************************************************************
	* Name		: [dbo.List_ListItemType_GetAll]
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
			SELECT t.ListItemTypeID, t.TypeName
			FROM dbo.ListItemType t
		END TRY
		BEGIN CATCH 
			RETURN 11204
		END CATCH	  	  	  
	END

GO
GRANT EXECUTE ON [dbo].[List_ListItemType_GetAll] TO [websiteuser_role]
GO
