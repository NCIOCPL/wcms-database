IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Flash_FlashObject_Get]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Flash_FlashObject_Get]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

	Create  PROCEDURE  [dbo].[Flash_FlashObject_Get](@flashObjectID UniqueIdentifier)
	/**************************************************************************************************
	* Name		: [dbo.Flash_FlashObject_Get]
	* Purpose	: [get flash object details]
	* Author	: [Sandra]
	* Date		: [11/07/2006]
	* Returns	: [n/a]
	* Usage		: [dbo.Flash_FlashObject_Get '563A612D-BF11-4EF4-9ED8-76F0A8FDBC4B']
	* Changes	: []
	**************************************************************************************************/
	AS
	BEGIN
	  --Declaration
	  --Initialization
	  --Execute	  
		BEGIN TRY
			--Return Flash object Details for the given the FlashObjectID 
				Select FlashObjectID , Title,SrcUrl, Height, Width, AlternateHtml, RequiredVersion,BackgroundColor, CreateUserID, CreateDate, UpdateUserID, UpdateDate 
				From Flash 
				Where FlashObjectID = @flashObjectID

			--Return Paramters' Details for the given the FlashObjectID 
				SELECT flashObjectID 
				, FlashObjectParamID
				, ParamName
				, ParamValue
				, ParamTypeID
				FROM dbo.FlashObjectParams 
				WHERE FlashObjectID = @flashObjectID 								
		END TRY
		BEGIN CATCH 
			--Return Error Number
			RETURN 11102
		END CATCH	  	  	  
	END

GO
GRANT EXECUTE ON [dbo].[Flash_FlashObject_Get] TO [websiteuser_role]
GO
