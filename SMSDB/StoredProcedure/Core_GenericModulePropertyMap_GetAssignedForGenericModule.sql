IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_GenericModulePropertyMap_GetAssignedForGenericModule]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_GenericModulePropertyMap_GetAssignedForGenericModule]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].Core_GenericModulePropertyMap_GetAssignedForGenericModule
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
		FROM GenericModulePropertyMap gmptm
		JOIN PropertyTemplate pt
		ON gmptm.PropertyTemplateID = pt.PropertyTemplateID

		return 0
	END TRY

	BEGIN CATCH
		RETURN 17002
	END CATCH 

END



GO
GRANT EXECUTE ON [dbo].[Core_GenericModulePropertyMap_GetAssignedForGenericModule] TO [websiteuser_role]
GO
