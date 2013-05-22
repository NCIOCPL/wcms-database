IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_PrettyUrl_Delete]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_PrettyUrl_Delete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_PrettyUrl_Delete
	@PrettyUrlID uniqueidentifier
	,@UpdateUserID varchar(50)
AS
BEGIN
	Declare @rtnValue int,
		@NodeID uniqueidentifier

	select @NodeID= NodeID from dbo.PrettyUrl
	Where PrettyUrlID = @PrettyUrlID

	BEGIN TRY

		Delete from dbo.PrettyUrl
		  Where PrettyUrlID = @PrettyUrlID
		
--		if (@NodeID  is not null)
--		BEGIN
--
--			exec @rtnValue = dbo.Core_Node_SetStatus @NodeID
--			if (@rtnValue >0)
--				return @rtnValue
--		END

	END TRY

	BEGIN CATCH
		RETURN 10805
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_PrettyUrl_Delete] TO [websiteuser_role]
GO
