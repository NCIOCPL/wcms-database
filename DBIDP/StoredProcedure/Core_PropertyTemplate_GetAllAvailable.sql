IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_PropertyTemplate_GetAllAvailable]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_PropertyTemplate_GetAllAvailable]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_PropertyTemplate_GetAllAvailable
	@ObjectID uniqueidentifier,
	@Type int
AS
BEGIN
	BEGIN TRY
		if (@Type=1)
		BEGIN
			SELECT [PropertyTemplateID]
			  ,[PropertyName]
			  ,[ValueType]
			  ,[DefaultValue]
			  ,[CreateUserID]
			  ,[CreateDate]
			  ,[UpdateUserID]
			  ,[UpdateDate]
		  FROM [dbo].[PropertyTemplate] Where [PropertyTemplateID] Not in 
			(	SELECT [PropertyTemplateID]
				  FROM [dbo].[NodeProperty] 
				Where 		NodeID= @ObjectID)
			order by [PropertyName]
		END
		if (@Type=2)
		BEGIN
			SELECT [PropertyTemplateID]
			  ,[PropertyName]
			  ,[ValueType]
			  ,[DefaultValue]
			  ,[CreateUserID]
			  ,[CreateDate]
			  ,[UpdateUserID]
			  ,[UpdateDate]
		  FROM [dbo].[PropertyTemplate] Where [PropertyTemplateID] Not in 
			(	SELECT [PropertyTemplateID]
				  FROM dbo.ModuleInstanceProperty 
				Where 	ModuleInstanceID = @ObjectID)
			order by [PropertyName]
		END

	END TRY

	BEGIN CATCH
		RETURN 10901
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_PropertyTemplate_GetAllAvailable] TO [websiteuser_role]
GO
