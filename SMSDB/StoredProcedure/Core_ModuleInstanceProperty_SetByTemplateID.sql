IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_ModuleInstanceProperty_SetByTemplateID]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_ModuleInstanceProperty_SetByTemplateID]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_ModuleInstanceProperty_SetByTemplateID
		@ModuleInstanceID uniqueidentifier,
		@PropertyTemplateID uniqueidentifier,
		@PropertyValue varchar(1000),
		@UpdateUserID varchar(50)
AS
BEGIN

	DECLARE @InstancePropertyID uniqueIdentifier,
			@NodeID uniqueIdentifier,
			@rtnValue int

	BEGIN TRY
		IF EXISTS(select PropertyTemplateID from propertyTemplate where PropertyTemplateID = @PropertyTemplateID)
		BEGIN
			SELECT @InstancePropertyID = InstancePropertyID
			FROM ModuleInstanceProperty
			WHERE PropertyTemplateID = @PropertyTemplateID
			AND ModuleInstanceID = @ModuleInstanceID

			IF @InstancePropertyID is not null
				UPDATE ModuleInstanceProperty
				SET PropertyValue = @PropertyValue
				WHERE InstancePropertyID = @InstancePropertyID
			ELSE
				INSERT INTO ModuleInstanceProperty
				(InstancePropertyID, ModuleInstanceID, PropertyTemplateID, CreateUserID, UpdateUserID, PropertyValue)
				VALUES
				(newid(), @ModuleInstanceID, @PropertyTemplateID, @UpdateUserID, @UpdateUserID, @PropertyValue)
		END
		ELSE
		BEGIN
			--Return error because the property template does not exist.
			PRINT 'Property Does Not Exist'
			RETURN 11095
		END

		SELECT @NodeID= Z.NodeID
		From [dbo].[ModuleInstance] M
		inner join dbo.ZoneInstance Z
		on Z.ZoneInstanceID = M.ZoneInstanceID
		Where	M.ModuleInstanceID=@ModuleInstanceID

		exec @rtnValue = dbo.Core_Node_SetStatus @NodeID, @UpdateUserID	
		if @rtnValue >0
			return @rtnValue


		return 0
	END TRY

	BEGIN CATCH
		RETURN 11004
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_ModuleInstanceProperty_SetByTemplateID] TO [websiteuser_role]
GO
