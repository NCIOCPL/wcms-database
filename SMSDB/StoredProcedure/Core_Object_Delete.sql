IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_Object_Delete]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_Object_Delete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_Object_Delete
	@ObjectID uniqueidentifier 
	,@UpdateUserID varchar(50)
AS
BEGIN
	DEclare @objectTypeID int 
	,@OwnerID uniqueidentifier
	,@IsShared bit 
	,@IsVirtual bit 
	
	Select @objectTypeID = objectTypeID,
			@OwnerID = OwnerID,
			@IsShared = IsShared,
			@IsVirtual = IsVirtual
	From  [dbo].[Object]
	Where ObjectID = @ObjectID

	BEGIN TRY

	--ToDo:
	--if it is virtual, do nothing
	--if is not virtual
		--if is shared, do nothing. 
		--if is not shared, delete the object according to the Type
			--List, Delete listitem, list
			--Document, deelte document


	Delete From [dbo].[Object]
	Where ObjectID = @ObjectID

	return 0
		
	END TRY

	BEGIN CATCH
		Print Error_Message()
		RETURN 11905
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_Object_Delete] TO [websiteuser_role]
GO
