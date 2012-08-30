IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[List_List_GetAll]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[List_List_GetAll]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
	CREATE  PROCEDURE  dbo.List_List_GetAll
	/**************************************************************************************************
	* Name		: [dbo.List_List_GetAll]
	* Purpose	: [Returns all lists]
	* Author	: [SR]
	* Date		: [04/27/2006]
	* Parameters: [n/a]
	* Returns	: [Lists]
	* Usage		: [dbo.List_List_GetAll]
	* Changes	: []
	**************************************************************************************************/
	AS
	BEGIN
		BEGIN TRY
			Select l.ListID
			--, l.Title
			, l.Description, l.ShowLinkDescriptions, l.ShowShortTitle
			--, l.IsModified
			, l.CreateUserID, l.CreateDate, l.UpdateUserID, l.UpdateDate 
			From  dbo.List l
		END TRY
		BEGIN CATCH 
			RETURN 11204
		END CATCH	  	  	  
	END

GO
GRANT EXECUTE ON [dbo].[List_List_GetAll] TO [websiteuser_role]
GO
