IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_PrettyURL_Update]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_PrettyURL_Update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_PrettyURL_Update
	@PrettyURLID uniqueidentifier
	,@PrettyURL varchar(512)
	,@IsPrimary bit
	,@UpdateUserID varchar(50)
AS
BEGIN
	BEGIN TRY
		if (dbo.Core_Function_PrettyURLExists(@PrettyURLID, @PrettyURL) =1)
			return 10800

		Declare @NodeID  uniqueidentifier

		Select @NodeID = NodeID  From dbo.PrettyUrl where PrettyUrlID= @PrettyUrlID

		if (@IsPrimary=1)
		BEGIN
			Update dbo.PrettyURL
			Set IsPrimary = 0 
			WHere NodeID  =@NodeID 
		END

		Update dbo.PrettyUrl
		Set PrettyURL = @PrettyURL
			,IsPrimary = @IsPrimary
			,UpdateUserID = @UpdateUserID
			,UpdateDate = getdate()
		Where PrettyURLID = @PrettyURLID
		
--		Declare @rtnValue int
--
--		exec @rtnValue = dbo.Core_Node_SetStatus @NodeID
--		if (@rtnValue >0)
--			return @rtnValue

	END TRY

	BEGIN CATCH
		RETURN 10304
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_PrettyURL_Update] TO [websiteuser_role]
GO
