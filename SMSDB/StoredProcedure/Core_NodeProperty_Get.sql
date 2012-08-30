IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_NodeProperty_Get]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_NodeProperty_Get]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_NodeProperty_Get
	@NodePropertyID uniqueidentifier
AS
BEGIN
	BEGIN TRY
			SELECT [NodePropertyID] as PropertyID
			  ,[NodeID] as ItemID
			  ,P.[PropertyTemplateID]
			  ,[PropertyValue]
				,T.DefaultValue
				,T.ValueType
				,T.PropertyName
			  ,P.[CreateUserID]
			  ,P.[CreateDate]
			  ,P.[UpdateUserID]
			  ,P.[UpdateDate]
		  FROM [dbo].[NodeProperty] P
		Inner join dbo.PropertyTemplate T
		on T.[PropertyTemplateID] = P.[PropertyTemplateID]
		Where 		NodePropertyID= @NodePropertyID
		

	END TRY

	BEGIN CATCH
		RETURN 10901
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_NodeProperty_Get] TO [websiteuser_role]
GO
