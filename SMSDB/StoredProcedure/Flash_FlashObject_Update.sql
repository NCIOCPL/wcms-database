IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Flash_FlashObject_Update]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Flash_FlashObject_Update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
	CREATE  PROCEDURE  [dbo].[Flash_FlashObject_Update](
		@flashObjectID uniqueidentifier
		, @srcUrl varchar(255) 
		, @height varchar(50)
		, @width varchar(50)
		, @alternateHtml varchar(500)
		, @requiredVersion varchar(50)
		, @backgroundColor varchar(50)
		, @flashVars varchar(4096)
		, @paramFlashVars varchar(4096)
		, @optionalParams varchar(4096)
		, @updateUserID varchar(50)
		, @title varchar(50)
	)
	/**************************************************************************************************
	* Name		: [dbo.Flash_FlashObject_Update]
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
			Update 	dbo.Flash
			Set 
				  Title=@title				
				, SrcUrl  = @srcUrl 
				, Height = @height
				, AlternateHtml = @alternateHtml
				, Width=@width
				, RequiredVersion=@requiredVersion
				, BackgroundColor= @backgroundColor
				, UpdateDate = getdate()
				, UpdateUserID = @updateUserID
			WHERE 	FlashObjectID = @flashObjectID

			declare @FlashObjectParamID uniqueidentifier
			-- Update FlashObjectParams
			--- For optionalParams (Type 1)	
			Delete from FlashObjectParams
			where FlashObjectID=@flashObjectID
		
			set @FlashObjectParamID=NEWID()
			INSERT INTO dbo.FlashObjectParams(	
				FlashObjectID
				, FlashObjectParamID			
				, ParamName
				, ParamValue
				, ParamTypeID)     		
			Select @flashObjectID,@FlashObjectParamID,ParamName,ParamValue,1 from dbo.udf_FlashToParamRange (@optionalParams, ',', '|' )

			-- Update FlashObjectParams
			--- For flashVars (Type 2)
			set @FlashObjectParamID=NEWID()
			INSERT INTO dbo.FlashObjectParams(	
				FlashObjectID
				, FlashObjectParamID			
				, ParamName
				, ParamValue
				, ParamTypeID)     		
			Select @flashObjectID,@FlashObjectParamID,ParamName,ParamValue,2 from dbo.udf_FlashToParamRange (@flashVars, ',', '|' )

			-- Update FlashObjectParams
			--- For paramFlashVars (Type 3)
			set @FlashObjectParamID=NEWID()
			INSERT INTO dbo.FlashObjectParams(	
				FlashObjectID
				, FlashObjectParamID			
				, ParamName
				, ParamValue
				, ParamTypeID)     		
			Select @flashObjectID,@FlashObjectParamID,ParamName,ParamValue,3 from dbo.udf_FlashToParamRange (@paramFlashVars, ',', '|' )

		
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
GRANT EXECUTE ON [dbo].[Flash_FlashObject_Update] TO [websiteuser_role]
GO
