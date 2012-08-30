IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_ConfigurableRoles_Add]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_ConfigurableRoles_Add]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE dbo.Core_ConfigurableRoles_Add
    @RoleName       VARCHAR(50),
	@Permission	int,
	@CreateUserID varchar(50)
AS
BEGIN
	
	IF (EXISTS (SELECT 1 FROM   dbo.[Role] WHERE  roleName = @RoleName  ))
		RETURN 60402

	BEGIN TRY	
			INSERT INTO [dbo].[Role]
			(	
				[RoleName], 
				[Permission], 
				[CreateDate],
				[CreateUserID],
				[UpdateDate],
				[UpdateUserID]
			)
			VALUES
			(
				@RoleName,
				@Permission, 
				getdate(),
				@CreateUserID,
				getdate(),
				@CreateUserID
			)	   	
		RETURN 0
	END TRY

	BEGIN CATCH
		RETURN 60420 -- Can't insert Role
	
	END CATCH 
	
END

GO
GRANT EXECUTE ON [dbo].[Core_ConfigurableRoles_Add] TO [websiteuser_role]
GO
