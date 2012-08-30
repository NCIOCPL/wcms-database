IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_NodeProperty_GetAll]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_NodeProperty_GetAll]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_NodeProperty_GetAll
	@NodeID uniqueidentifier
AS
BEGIN
	BEGIN TRY
			

			SELECT [NodePropertyID] as PropertyID
			  ,[NodeID] as ItemID
			  ,M.[PropertyTemplateID]
			  ,M.[PropertyValue]
			  ,M.[CreateUserID]
			  ,M.[CreateDate]
			  ,M.[UpdateUserID]
			  ,M.[UpdateDate]
			  ,P.PropertyName
			  ,P.ValueType
		  FROM [dbo].[NodeProperty] M
			Inner join dbo.PropertyTemplate P
			on M.[PropertyTemplateID] = P.[PropertyTemplateID]
			Where NodeID = @NodeID 
	END TRY

	BEGIN CATCH
		RETURN 10902
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_NodeProperty_GetAll] TO [websiteuser_role]
GO
