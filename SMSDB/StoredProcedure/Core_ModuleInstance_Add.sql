IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_ModuleInstance_Add]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_ModuleInstance_Add]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_ModuleInstance_Add
	@ZoneInstanceID uniqueidentifier
	,@ModuleID uniqueidentifier
	,@ObjectID uniqueidentifier = null -- for shared objects
	,@IsShared bit
	,@UpdateUserID varchar(50)
	,@ModuleInstanceID uniqueidentifier output
AS
BEGIN
	Declare @rtnValue int
		,@OwnerID uniqueidentifier
		,@ObjectTypeID int
		,@IsVirtual bit
		,@Priority int

	BEGIN TRY
		SELECT @ModuleInstanceID = NewID()
		SELECT @Priority = dbo.Core_Function_ModuleInstanceGetPriority(@ZoneInstanceID)
		SELECT @OwnerID =NodeID from  dbo.ZoneInstance where ZoneInstanceID = @ZoneInstanceID

		SELECT @ObjectTypeID =G.category ,@IsVirtual = G.IsVirtual
		from  dbo.GenericModule G
		inner join  dbo.Module M
		on G.GenericModuleID = M.GenericModuleID
		where M.ModuleID = @ModuleID

		print str(@ObjectTypeID)

		if (@ObjectID is null) -- non-search-back-shared objects, need to create it first
		BEGIN
			exec @rtnValue = Core_Object_Add
				@objectTypeID = @ObjectTypeID
				,@OwnerID = @OwnerID
				,@IsShared = @IsShared
				,@IsVirtual = @IsVirtual
				,@UpdateUserID= @UpdateUserID
				,@ObjectID = @ObjectID output

			print str(@rtnValue)

			if (@rtnValue >0)
				return @rtnValue
		END		

		INSERT INTO [dbo].[ModuleInstance]
           ([ModuleInstanceID]
           ,[ZoneInstanceID]
           ,[ModuleID]
           ,[Priority]
           ,[CreateUserID]
           ,[CreateDate]
           ,[UpdateUserID]
           ,[UpdateDate]
           ,[ObjectID])
		 VALUES
			(@ModuleInstanceID, @ZoneInstanceID, @ModuleID, @Priority,
			@UpdateUserID, getdate(),@UpdateUserID,getdate(),@ObjectID )

		exec @rtnValue = dbo.Core_Node_SetStatus @OwnerID, @UpdateUserID
		if @rtnValue >0
			return @rtnValue

		return 0

	END TRY

	BEGIN CATCH
		Print Error_Message()
		RETURN 11803
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_ModuleInstance_Add] TO [websiteuser_role]
GO
