IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_NodeProperty_Update]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_NodeProperty_Update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_NodeProperty_Update
	@NodePropertyID uniqueidentifier
	,@PropertyValue varchar(8000)
	,@UpdateUserID varchar(50)
AS
BEGIN
	BEGIN TRY

		Update dbo.NodeProperty 
		Set PropertyValue = @PropertyValue
			,UpdateUserID = @UpdateUserID
			,UpdateDate = getdate()
		Where NodePropertyID = @NodePropertyID
		

--		Declare @rtnValue int,
--				@NodeID uniqueidentifier
--
--		select @NodeID = NodeID from dbo.NodeProperty
--		  Where NodePropertyID = @NodePropertyID
--
--		exec @rtnValue = dbo.Core_Node_SetStatus @NodeID
--		if (@rtnValue >0)
--			return @rtnValue

	END TRY

	BEGIN CATCH
		RETURN 10904
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_NodeProperty_Update] TO [websiteuser_role]
GO
