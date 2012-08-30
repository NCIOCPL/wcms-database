IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_ModuleInstanceProperty_Get]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_ModuleInstanceProperty_Get]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_ModuleInstanceProperty_Get
	@InstancePropertyID uniqueidentifier
AS
BEGIN
	BEGIN TRY

			SELECT InstancePropertyID as PropertyID
				,ModuleInstanceID as ItemID
			  ,M.[PropertyTemplateID]
			  ,M.[PropertyValue]
			  ,M.[CreateUserID]
			  ,M.[CreateDate]
			  ,M.[UpdateUserID]
			  ,M.[UpdateDate]
			  ,P.PropertyName
			  ,P.ValueType
		  FROM dbo.ModuleInstanceProperty M
			Inner join dbo.PropertyTemplate P
			on M.[PropertyTemplateID] = P.[PropertyTemplateID]
		Where 	InstancePropertyID = @InstancePropertyID

	END TRY

	BEGIN CATCH
		RETURN 11001
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_ModuleInstanceProperty_Get] TO [websiteuser_role]
GO
