IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Flash_FlashObject_UpdateForParams]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Flash_FlashObject_UpdateForParams]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
	CREATE  PROCEDURE  [dbo].[Flash_FlashObject_UpdateForParams](
		@flashObjectID uniqueidentifier
		,@paramName varchar(50)
		, @paramTypeID int
		, @flashVars varchar(4096)
		, @updateUserID varchar(50)
	)
	/**************************************************************************************************
	* Name		: [dbo.Flash_FlashObject_UpdateForParams]
	* Purpose	: [Update a flash object]
	* Author	: [Sandra]
	* Date		: [11/07/2006]
	* Parameters: [srcUrl, height,width, alternateHtml, requiredVersion, backgroundColor,flashObjectID,updateUserID]
	* Returns	: [ListId]
	* Usage		: [Exec dbo.Flash_FlashObject_Update 'FC53DB4B-E10F-4433-8162-2B02FBAB5412', ]
	* Changes	: []
	**************************************************************************************************/
	AS
	BEGIN
		--Declaration
		DECLARE @rtnValue int

		--Initialization			
		--Execute					
		BEGIN TRY
			
			declare @FlashObjectParamID uniqueidentifier
			-- Update FlashObjectParams
			Delete from FlashObjectParams
			where FlashObjectID=@flashObjectID and ParamName=@paramName
		
			set @FlashObjectParamID=NEWID()
			INSERT INTO dbo.FlashObjectParams(	
				FlashObjectID
				, FlashObjectParamID			
				, ParamName
				, ParamValue
				, ParamTypeID)     		
			Select @flashObjectID,@FlashObjectParamID,ParamName,ParamValue, @paramTypeID
from dbo.udf_FlashToParamRange (@flashVars, ',', '|' )

		--Set the object as dirty			
			exec @rtnValue = Core_Object_SetIsDirty
				@ObjectID = @flashObjectID,
				@UpdateUserID = @UpdateUserID

			if (@rtnValue >0)
				return @rtnValue

			RETURN 0
		END TRY
		BEGIN CATCH 
			RETURN 11201
		END CATCH	  	  	  
	END


GO
GRANT EXECUTE ON [dbo].[Flash_FlashObject_UpdateForParams] TO [websiteuser_role]
GO
