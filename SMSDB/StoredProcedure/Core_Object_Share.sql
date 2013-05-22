IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_Object_Share]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_Object_Share]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_Object_Share
	@ObjectID uniqueidentifier ,
	@UpdateUserID varchar(50)
AS
BEGIN
	
	BEGIN TRY
		UPDATE Object
		SET IsShared= 1
		WHERE ObjectID = @ObjectID

--		Declare @NodeID 	uniqueidentifier,
--				@rtnValue int
--
--		select 	@NodeID= OwnerID
--		from dbo.Object	
--		Where ObjectID = @ObjectID
--
--		exec @rtnValue = dbo.Core_Node_SetStatus @NodeID, @UpdateUserID
--		if (@rtnValue >0)
--			return @rtnValue
		

		return 0		
	END TRY

	BEGIN CATCH
		Print Error_Message()
		RETURN 11907
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_Object_Share] TO [websiteuser_role]
GO
