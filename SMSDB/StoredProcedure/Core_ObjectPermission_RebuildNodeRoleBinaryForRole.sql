IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_ObjectPermission_RebuildNodeRoleBinaryForRole]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_ObjectPermission_RebuildNodeRoleBinaryForRole]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO




Create  PROCEDURE [dbo].Core_ObjectPermission_RebuildNodeRoleBinaryForRole
	@RoleID	bigint
AS
BEGIN
	BEGIN TRY

		DECLARE	@CTE TABLE (
			RowNumber int identity,
			ID uniqueIdentifier
		);

		--Immediate Children. only first level.
		INSERT INTO @CTE
			(
				ID
			)
		SELECT	distinct nodeID
		FROM dbo.MemberNodeRoleMap
		Where RoleID = @RoleID 

		/*
		Instead of cursor, in future we might do a update
		*/

		-- loop through child to update each one child's binary
		DECLARE @LoopNodeID uniqueIdentifier,
			@LoopCounter int,
			@rtnVal int

		set @LoopCounter = 1

		Select 	@LoopNodeID = ID
		From @CTE --FROM dbo.Core_Function_GetChildNodes(@NodeID)
		WHERE RowNumber = @LoopCounter

		--Copy the data over
		While @@rowcount <> 0
		BEGIN
			EXEC @rtnVal = Core_ObjectPermission_RebuildNodeRoleBinaryForNode @LoopNodeID

			IF @rtnVal <> 0
					RETURN @rtnVal
			
			SET @LoopCounter = @LoopCounter + 1

			Select 	@LoopNodeID = ID
			FROM @CTE
			WHERE RowNumber = @LoopCounter
		END
		-- End Loop
		
		return 0 
		
	END TRY

	BEGIN CATCH
		Print Error_Message()
		RETURN 80011
	END CATCH 
END



GO
GRANT EXECUTE ON [dbo].[Core_ObjectPermission_RebuildNodeRoleBinaryForRole] TO [websiteuser_role]
GO
