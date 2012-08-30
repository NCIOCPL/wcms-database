IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[List_List_GetTitleDescription]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[List_List_GetTitleDescription]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

	Create  PROCEDURE  [dbo].[List_List_GetTitleDescription](
		@ListID uniqueidentifier
	)
	/**************************************************************************************************
	* Name		: [dbo.List_List_GetTitleDescription]
	* Purpose	: [creates a new list]
	* Author	: [SR]
	* Date		: [04/27/2006]
	* Parameters: [ListID]
	* Returns	: DataTable
	* Usage		: [Exec dbo.List_List_GetTitleDescription 'FC53DB4B-E10F-4433-8162-2B02FBAB5412']
	* Changes	: []
	**************************************************************************************************/
	AS
	BEGIN
		
		--Execute					
		BEGIN TRY
			Select Description 
			From List
			WHERE 	ListID = @ListID
			RETURN 0
		END TRY
		BEGIN CATCH 
			RETURN 11201
		END CATCH	  	  	  
	END


GO
GRANT EXECUTE ON [dbo].[List_List_GetTitleDescription] TO [websiteuser_role]
GO
