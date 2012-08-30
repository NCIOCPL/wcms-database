IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_ModuleInstanceProperty_AddByName]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_ModuleInstanceProperty_AddByName]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_ModuleInstanceProperty_AddByName
	@ModuleInstanceID uniqueidentifier
	,@PropertyName varchar(50)
	,@PropertyValue varchar(8000)
	,@UpdateUserID varchar(50)
AS
BEGIN
	Declare @rtnValue int
		,@NodeID uniqueidentifier

		SELECT @NodeID= Z.NodeID
		From [dbo].[ModuleInstance] M
		inner join dbo.ZoneInstance Z
		on Z.ZoneInstanceID = M.ZoneInstanceID
		Where	M.ModuleInstanceID=@ModuleInstanceID

	BEGIN TRY

		DECLARE @PropertyTemplateID uniqueidentifier

		SELECT @PropertyTemplateID = PropertyTemplateID
		FROM PropertyTemplate
		WHERE PropertyName = @PropertyName

		IF @PropertyTemplateID is null
			return 11002

		if (exists (select 1 from dbo.ModuleInstanceProperty where ModuleInstanceID=@ModuleInstanceID and [PropertyTemplateID]= @PropertyTemplateID ))
			return 11000

		INSERT INTO dbo.ModuleInstanceProperty
           (InstancePropertyID
			,ModuleInstanceID
           ,[PropertyTemplateID]
           ,[PropertyValue]
           ,[CreateUserID]
           ,[CreateDate]
           ,[UpdateUserID]
           ,[UpdateDate])
     VALUES
		(newid(), @ModuleInstanceID, @PropertyTemplateID, @PropertyValue, @UpdateUserID, getdate(), @UpdateUserID, getdate())
		
	exec @rtnValue = dbo.Core_Node_SetStatus @NodeID, @UpdateUserID	
		if @rtnValue >0
			return @rtnValue

		return 0
	END TRY

	BEGIN CATCH
		RETURN 11003
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_ModuleInstanceProperty_AddByName] TO [websiteuser_role]
GO
