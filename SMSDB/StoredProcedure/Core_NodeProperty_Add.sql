IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_NodeProperty_Add]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_NodeProperty_Add]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_NodeProperty_Add
	@NodeID uniqueidentifier
	,@PropertyTemplateID uniqueidentifier
	,@PropertyValue varchar(8000)
	,@UpdateUserID varchar(50)
AS
BEGIN

	BEGIN TRY

		if (exists (select 1 from [dbo].[NodeProperty] where [NodeID]=@NodeID and [PropertyTemplateID]= @PropertyTemplateID ))
			return 10900

		INSERT INTO [dbo].[NodeProperty]
           ([NodePropertyID]
           ,[NodeID]
           ,[PropertyTemplateID]
           ,[PropertyValue]
           ,[CreateUserID]
           ,[CreateDate]
           ,[UpdateUserID]
           ,[UpdateDate])
     VALUES
		(newid(), @NodeID, @PropertyTemplateID, @PropertyValue, @UpdateUserID, getdate(), @UpdateUserID, getdate())
		

--	Declare @rtnValue int
--
--		exec @rtnValue = dbo.Core_Node_SetStatus @NodeID
--		if (@rtnValue >0)
--			return @rtnValue


	END TRY

	BEGIN CATCH
		RETURN 10903
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_NodeProperty_Add] TO [websiteuser_role]
GO
