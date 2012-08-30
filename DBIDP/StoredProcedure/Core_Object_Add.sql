IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_Object_Add]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_Object_Add]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_Object_Add
	@objectTypeID int 
	,@OwnerID uniqueidentifier
	,@IsShared bit = 0
	,@IsVirtual bit = 0
	,@Title varchar(255) = '' --this should get fixed
	,@UpdateUserID varchar(50)
	,@ObjectID uniqueidentifier output
AS
BEGIN
	BEGIN TRY

	Select @ObjectID= newid()

	INSERT INTO [dbo].[Object]
           ([ObjectID]
           ,[objectTypeID]
           ,[OwnerID]
           ,[IsShared]
			,IsVirtual
			,Title )
     VALUES
	(	@ObjectID,
		@objectTypeID,
		@OwnerID,
		@IsShared,
		@IsVirtual,
		@Title
	)
		
	END TRY

	BEGIN CATCH
		Print Error_Message()
		RETURN 11903
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_Object_Add] TO [websiteuser_role]
GO
