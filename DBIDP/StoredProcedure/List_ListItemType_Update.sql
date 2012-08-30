IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[List_ListItemType_Update]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[List_ListItemType_Update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
	CREATE  PROCEDURE  dbo.List_ListItemType_Update(
		@ListItemTypeID int 
		, @TypeName varchar(50)
		, @UpdateUserID varchar(50)	
	)
	/**************************************************************************************************
	* Name		: [dbo.List_ListItemType_Update]
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
			Update dbo.ListItemType
			Set TypeName = @TypeName
			   , UpdateUserID = @UpdateUserID
			   , UpdateDate = getdate()
			Where ListItemtypeID = @ListItemTypeID
		END TRY
		BEGIN CATCH 
			RETURN 11205
		END CATCH	  	  	  
	END

GO
GRANT EXECUTE ON [dbo].[List_ListItemType_Update] TO [websiteuser_role]
GO
