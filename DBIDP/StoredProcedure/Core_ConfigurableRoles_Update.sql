IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_ConfigurableRoles_Update]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_ConfigurableRoles_Update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE dbo.Core_ConfigurableRoles_Update
	@RoleID		bigint,
    @RoleName       VARCHAR(50),
	@Permission	int,
	@UpdateUserID varchar(50)
AS
BEGIN
	IF (NOT EXISTS (SELECT 1 FROM   dbo.[Role] WHERE  RoleID = @RoleID ))
		RETURN 60421
	
	IF (EXISTS (SELECT 1 FROM   dbo.[Role] WHERE  roleName = @RoleName and RoleID <>@RoleID ))
		RETURN 60422
		
	Declare @OldPermission	int

	Select @OldPermission = [Permission] from  [dbo].[Role] Where RoleID= @RoleID

	BEGIN TRY	
			Update [dbo].[Role]
			set 	
				[RoleName]		=@RoleName, 
				[Permission]	=@Permission, 
				[UpdateDate]	=getdate(),
				[UpdateUserID]	=@UpdateUserID
			WHERE RoleID = @RoleID

			if (@Permission <> @OldPermission)
			BEGIN
				Print 'PErmission changed. Rebuild tree'

				Declare @rtnValue int 
		
				exec @rtnValue= dbo.Core_ObjectPermission_RebuildNodeRoleBinaryForRole
					@RoleID= @RoleID

				if @rtnValue >0
					return @rtnValue
			END

		RETURN 0
	END TRY

	BEGIN CATCH
		RETURN 60420 -- Can't insert Role
	
	END CATCH 
	
END

GO
GRANT EXECUTE ON [dbo].[Core_ConfigurableRoles_Update] TO [websiteuser_role]
GO
