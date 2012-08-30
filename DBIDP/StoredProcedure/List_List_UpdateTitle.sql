IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[List_List_UpdateTitle]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[List_List_UpdateTitle]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE  PROCEDURE  [dbo].[List_List_UpdateTitle](
	@ListID uniqueidentifier
	, @Title varchar(255)
	, @Description varchar(1500)
	, @UpdateUserID varchar(50)
)
/**************************************************************************************************
* Name		: [dbo.List_List_UpdateTitle]
* Purpose	: [update list title]
* Author	: [QZ]
* Date		: [05/11/2006]
* Parameters: [ListID, Title, CreateUserID, ReturnValue]
* Returns	: [ReturnValue]
* Usage		: [Exec dbo.List_List_UpdateTitle 'FC53DB4B-E10F-4433-8162-2B02FBAB5412', 'MyList', 'zhengqi']
* Changes	: []
**************************************************************************************************/
AS
BEGIN
	--Declaration
	DECLARE @rtnValue int

	--Initialization			
	--Execute					
	BEGIN TRY

		--Yea, wow, this should be in the object table.
		--Oh well.
		UPDATE List
			SET 
				Description = @Description,
				UpdateUserID = @UpdateUserID,
				UpdateDate = getdate()
		WHERE ListID = @ListID

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

		return 0
	END TRY
	BEGIN CATCH 
		RETURN 11201
	END CATCH	  	  	  
END

GO
GRANT EXECUTE ON [dbo].[List_List_UpdateTitle] TO [websiteuser_role]
GO
