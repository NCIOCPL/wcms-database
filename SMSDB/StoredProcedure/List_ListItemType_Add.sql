IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[List_ListItemType_Add]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[List_ListItemType_Add]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
	CREATE  PROCEDURE  dbo.List_ListItemType_Add(
		@ListItemTypeID int 
		, @TypeName varchar(50)
		, @CreateUserID varchar(50)	
	)
	/**************************************************************************************************
	* Name		: [dbo.List_ListItemType_Add]
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
			Insert Into dbo.ListItemType(		
			    ListItemtypeID
			   , TypeName
			   , CreateUserID
			   , CreateDate
			   , UpdateUserID
			   , UpdateDate
			)
			Values(
				@ListItemTypeID
				, @TypeName
				, @CreateUserID
				, getdate()
				, @CreateUserID
				, getdate()
			)
		END TRY
		BEGIN CATCH 
			RETURN 11201
		END CATCH	  	  	  
	END

GO
GRANT EXECUTE ON [dbo].[List_ListItemType_Add] TO [websiteuser_role]
GO
