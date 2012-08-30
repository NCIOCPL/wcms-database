IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Flash_FlashObject_Delete]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Flash_FlashObject_Delete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

	CREATE  PROCEDURE  [dbo].[Flash_FlashObject_Delete](
		@flashObjectID uniqueidentifier
		
	)
	/**************************************************************************************************
	* Name		: [Flash_FlashObject_Delete']
	* Purpose	: [Deletes it for the given flash object ID]
	* Author	: [sandra]
	* Date		: [11/07/2006]
	* Parameters: [ListID]
	* Returns	: [n/a]
	* Usage		: [dbo.Flash_FlashObject_Delete' 'D4DE197D-9393-49AD-BADB-97A55ED7DAB9', 'NIH\shij']
	* Changes	: [n/a]
	**************************************************************************************************/
	AS
	BEGIN
		BEGIN TRY
			Delete dbo.Flash
			Where FlashObjectID = @flashObjectID 
			Delete dbo.FlashObjectParams
			Where FlashObjectID= @flashobjectID
		END TRY
		BEGIN CATCH 
			RETURN 11202
		END CATCH	  	  	  
	END

GO
GRANT EXECUTE ON [dbo].[Flash_FlashObject_Delete] TO [websiteuser_role]
GO
