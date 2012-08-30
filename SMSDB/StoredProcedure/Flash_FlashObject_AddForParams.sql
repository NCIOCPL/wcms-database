IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Flash_FlashObject_AddForParams]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Flash_FlashObject_AddForParams]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



	Create  PROCEDURE  [dbo].[Flash_FlashObject_AddForParams](
		@flashObjectID uniqueidentifier
		,@ParamTypeID int
		, @flashVars varchar(4096)		
		, @createUserID varchar(50)
	)
	/**************************************************************************************************
	* Name		: [dbo.Flash_FlashObject_AddForParams]
	* Purpose	: [creates a new flash object]
	* Author	: [SR]
	* Date		: [11/08/2006]
	* Parameters: [srcUrl, height,width, alternateHtml, requiredVersion, backgroundColor,flashObjectID]
	* Returns	: [FlashObjectID]
	* Usage		: [Declare @flashObjectID uniqueidentifier Exec dbo.Flash_FlashObject_Add ]
	* Changes	: []
	**************************************************************************************************/
	AS
	BEGIN
		--Declaration
			Declare @rtnValue int
 
	  --Initialization			

	  --Execute					
		BEGIN TRY
			
	

			declare @FlashObjectParamID uniqueidentifier
			--- Insert into FlashObjectParams for Params 		
			set @FlashObjectParamID=NEWID()
			INSERT INTO dbo.FlashObjectParams(	
				FlashObjectID
				, FlashObjectParamID			
				, ParamName
				, ParamValue
				, ParamTypeID)     		
			Select @flashObjectID,@FlashObjectParamID,ParamName,ParamValue,@ParamTypeID  from dbo.udf_FlashToParamRange (@flashVars, ',', '|' )

			--Set the object as dirty			
			exec @rtnValue = Core_Object_SetIsDirty
				@ObjectID = @flashObjectID,
					@UpdateUserID = @createUserID

			if (@rtnValue >0)
				return @rtnValue

		END TRY
		BEGIN CATCH 
			RETURN 11201
		END CATCH	  	  	  
	END


GO
GRANT EXECUTE ON [dbo].[Flash_FlashObject_AddForParams] TO [websiteuser_role]
GO
