IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[List_List_Update]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[List_List_Update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
	CREATE  PROCEDURE  dbo.List_List_Update(
		@ListID uniqueidentifier
		, @Title varchar(255)
		, @Description varchar(1500)
		, @ShowLinkDescriptions bit
		, @ShowShortTitle bit
		, @UpdateUserID varchar(50)
	)
	/**************************************************************************************************
	* Name		: [dbo.List_List_Update]
	* Purpose	: [creates a new list]
	* Author	: [SR]
	* Date		: [04/27/2006]
	* Parameters: [Title, Desc,ShowLinkDesc, ShowShortTitle, CreateUserID, ReturnListId]
	* Returns	: [ListId]
	* Usage		: [Exec dbo.List_List_Update 'FC53DB4B-E10F-4433-8162-2B02FBAB5412', 'MyList', 'MyList', 0, 1, 'ramaiahs']
	* Changes	: []
	**************************************************************************************************/
	AS
	BEGIN
		--Declaration
		DECLARE @rtnValue int

		--Initialization			
		--Execute					
		BEGIN TRY
			Update 	dbo.Lists
			Set 				
				Description = @Description
				, ShowLinkDescriptions = @ShowLinkDescriptions
				, ShowShortTitle = @ShowShortTitle
				, UpdateDate = getdate()
				, UpdateUserID = @UpdateUserID
			WHERE 	ListID = @ListID

			--Update the list title			
			exec @rtnValue = Core_Object_SetTitle
				@ObjectID = @ListID,
				@Title = @Title

			if (@rtnValue >0)
				return @rtnValue

			--Set the object as dirty			
			exec @rtnValue = Core_Object_SetIsDirty
				@ObjectID = @ListID,
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
GRANT EXECUTE ON [dbo].[List_List_Update] TO [websiteuser_role]
GO
