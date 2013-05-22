IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[List_List_Add]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[List_List_Add]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
	CREATE  PROCEDURE  dbo.List_List_Add(
		@ListID uniqueidentifier
		, @Title varchar(255) = null
		, @Description varchar(1500) = null
		, @ShowLinkDescriptions bit=0
		, @ShowShortTitle bit = 0
		, @CreateUserID varchar(50)
	)
	/**************************************************************************************************
	* Name		: [dbo.List_List_Add]
	* Purpose	: [creates a new list]
	* Author	: [SR]
	* Date		: [04/27/2006]
	* Parameters: [Title, Desc,ShowLinkDesc, ShowShortTitle, CreateUserID, ReturnListId]
	* Returns	: [ListId]
	* Usage		: [Declare @ListID uniqueidentifier Exec dbo.List_List_Add '', 'MyList', 'MyList', 0, 1, 'ramaiahs', @ListID output Select @ListID]
	* Changes	: []
	**************************************************************************************************/
	AS
	BEGIN
		--Declaration
			Declare @rtnValue int
 
	  --Initialization			

	  --Execute					
		BEGIN TRY
			
			INSERT INTO dbo.List(
				ListID
				, Description
				, ShowLinkDescriptions
				, ShowShortTitle
				, CreateDate
           		, CreateUserID
           		, UpdateDate
           		, UpdateUserID)
     		VALUES(
     			@ListID
           		, ISNULL(@Description, '')
           		, @ShowLinkDescriptions
				, @ShowShortTitle
				, getdate() 
				, @CreateUserID
				, getdate()
				, @CreateUserID
			)
			
			--Set the list title			
			exec @rtnValue = Core_Object_SetTitle
				@ObjectID = @ListID,
				@Title = @Title				

			if (@rtnValue >0)
				return @rtnValue

			--Set the object as dirty			
			exec @rtnValue = Core_Object_SetIsDirty
				@ObjectID = @ListID,
					@UpdateUserID = @CreateUserID

			if (@rtnValue >0)
				return @rtnValue

		END TRY
		BEGIN CATCH 
			RETURN 11201
		END CATCH	  	  	  
	END

GO
GRANT EXECUTE ON [dbo].[List_List_Add] TO [websiteuser_role]
GO
