IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_GenericModulePropertyMap_GetUnassignedForGenericModule]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_GenericModulePropertyMap_GetUnassignedForGenericModule]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].Core_GenericModulePropertyMap_GetUnassignedForGenericModule
	@GenericModuleID uniqueidentifier
AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		
		SELECT
			pt.PropertyTemplateID,
			pt.PropertyName,
			pt.ValueType,
			pt.DefaultValue
		FROM PropertyTemplate pt
		WHERE PropertyTemplateID not in (
			SELECT PropertyTemplateID 
			FROM GenericModulePropertyMap
			WHERE GenericModuleID = @GenericModuleID
		)
		order by pt.PropertyName

		return 0
	END TRY

	BEGIN CATCH
		RETURN 17002
	END CATCH 

END



GO
GRANT EXECUTE ON [dbo].[Core_GenericModulePropertyMap_GetUnassignedForGenericModule] TO [websiteuser_role]
GO
