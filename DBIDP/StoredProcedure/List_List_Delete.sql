IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[List_List_Delete]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[List_List_Delete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
	CREATE  PROCEDURE  dbo.List_List_Delete(
		@ListID uniqueidentifier
		, @UpdateUserID varchar(50)
	)
	/**************************************************************************************************
	* Name		: [dbo.List_List_Delete]
	* Purpose	: [Deletes List for the given List ID]
	* Author	: [SR]
	* Date		: [04/27/2006]
	* Parameters: [ListID]
	* Returns	: [n/a]
	* Usage		: [dbo.List_List_Delete 'D4DE197D-9393-49AD-BADB-97A55ED7DAB9', 'NIH\ramaiahs']
	* Changes	: [n/a]
	**************************************************************************************************/
	AS
	BEGIN
		BEGIN TRY
			Delete dbo.List
			Where ListID = @ListID
			--TODO: check for cascade deletes if required
			--TODO: log in the history table details about who deleted the record.
		END TRY
		BEGIN CATCH 
			RETURN 11202
		END CATCH	  	  	  
	END

GO
GRANT EXECUTE ON [dbo].[List_List_Delete] TO [websiteuser_role]
GO
