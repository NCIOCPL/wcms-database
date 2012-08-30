IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_Node_Reprioritize]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_Node_Reprioritize]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO



CREATE PROCEDURE dbo.Core_Node_Reprioritize
	@NodeID uniqueidentifier,
	@Priority int,
	@UpdateUserID varchar(50)
AS
BEGIN
	BEGIN TRY
		Update dbo.Node
		Set Priority = @Priority,
			status =1,
			UpdateUserID= @UpdateUserID,
			UpdateDate = getdate()
		Where NodeID = @NodeID


		RETURN 0
	END TRY

	BEGIN CATCH
		Print 	ERROR_MESSAGE()
		RETURN 11108
	END CATCH 
END



GO
GRANT EXECUTE ON [dbo].[Core_Node_Reprioritize] TO [websiteuser_role]
GO
