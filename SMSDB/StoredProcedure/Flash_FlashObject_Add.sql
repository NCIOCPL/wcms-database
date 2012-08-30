IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Flash_FlashObject_Add]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Flash_FlashObject_Add]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

	CREATE  PROCEDURE  [dbo].[Flash_FlashObject_Add](
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
		, @createUserID varchar(50)
		, @title varchar(50)
	)
	/**************************************************************************************************
	* Name		: [dbo.Flash_FlashObject_Add]
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
			
			INSERT INTO dbo.Flash(
				FlashObjectID
				, SrcUrl
				, Height
				, Width
				, AlternateHtml
				, RequiredVersion
				, BackgroundColor
				, CreateDate
           		, CreateUserID
           		, UpdateDate
           		, UpdateUserID
				, Title)
     		VALUES(
     			@flashObjectID
           		, @srcUrl
           		, @height
			, @width 
			, @alternateHtml 
			, @requiredVersion 
			, @backgroundColor 
				, getdate() 
				, @createUserID
				, getdate()
				, @createUserID
				, @title
			)
			
			print @flashVars
			print @optionalParams
			print @paramFlashVars

			declare @FlashObjectParamID uniqueidentifier
			--- Insert into FlashObjectParams for optionalParams (Type 1)		
			set @FlashObjectParamID=NEWID()
			INSERT INTO dbo.FlashObjectParams(	
				FlashObjectID
				, FlashObjectParamID			
				, ParamName
				, ParamValue
				, ParamTypeID)     		
			Select @flashObjectID,@FlashObjectParamID,ParamName,ParamValue,1 from dbo.udf_FlashToParamRange (@optionalParams, ',', '|' )
			
			--- Insert into FlashObjectParams for flashVars (Type 2)		
			set @FlashObjectParamID=NEWID()
			INSERT INTO dbo.FlashObjectParams(				
				 FlashObjectID
				, FlashObjectParamID			
				, ParamName
				, ParamValue
				, ParamTypeID)      		
			Select @flashObjectID,@FlashObjectParamID,ParamName,ParamValue,2 from dbo.udf_FlashToParamRange (@flashVars , ',', '|' )

			--- Insert into FlashObjectParams for paramFlashVars (Type 3)		
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
					@UpdateUserID = @createUserID

			if (@rtnValue >0)
				return @rtnValue

		END TRY
		BEGIN CATCH 
			RETURN 11201
		END CATCH	  	  	  
	END

GO
GRANT EXECUTE ON [dbo].[Flash_FlashObject_Add] TO [websiteuser_role]
GO
