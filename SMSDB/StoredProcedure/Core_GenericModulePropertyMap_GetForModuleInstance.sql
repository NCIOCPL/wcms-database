IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_GenericModulePropertyMap_GetForModuleInstance]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_GenericModulePropertyMap_GetForModuleInstance]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].Core_GenericModulePropertyMap_GetForModuleInstance
	@ModuleInstanceID uniqueidentifier
AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		DECLARE @GenericModuleID uniqueidentifier

		SELECT @GenericModuleID = m.GenericModuleID
		FROM ModuleInstance mi
		JOIN Module m
		ON mi.ModuleID = m.ModuleID
		WHERE ModuleInstanceID = @ModuleInstanceID

		SELECT
			pt.PropertyTemplateID,
			pt.PropertyName,
			pt.ValueType,
			pt.DefaultValue,
			pt.CreateUserID,
			pt.CreateDate,
			pt.UpdateUserID,
			pt.UpdateDate
		  FROM GenericModulePropertyMap gmptm
		  JOIN PropertyTemplate pt
		  ON gmptm.PropertyTemplateID = pt.PropertyTemplateID
		  AND gmptm.PropertyTemplateID Not in 
			(	SELECT [PropertyTemplateID]
				  FROM dbo.ModuleInstanceProperty 
				Where 	ModuleInstanceID = @ModuleInstanceID)
          WHERE gmptm.GenericModuleID = @GenericModuleID
		  order by [PropertyName]
		
		return 0
	END TRY

	BEGIN CATCH
		RETURN 17002
	END CATCH 

END



GO
GRANT EXECUTE ON [dbo].[Core_GenericModulePropertyMap_GetForModuleInstance] TO [websiteuser_role]
GO
