IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_GenericModulePropertyMap_Update]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_GenericModulePropertyMap_Update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].Core_GenericModulePropertyMap_Update
	@GenericModuleID uniqueidentifier,
	@List varchar(1000),
	@Delimiter varchar(2) =',',
	@UpdateUserID varchar(50)
AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
	
		if (@List = '')
		BEGIN
			Delete From dbo.GenericModulePropertyMap
			WHERE GenericModuleID= @GenericModuleID 
		END
		ELSE
		BEGIN
			--CategoryMap
			Delete From dbo.GenericModulePropertyMap 
			WHERE GenericModuleID= @GenericModuleID and 
				PropertyTemplateID not in (select Item from  dbo.udf_ListToGuid(@List, @Delimiter) )

			Insert into  dbo.GenericModulePropertyMap
			(GenericModuleID , PropertyTemplateID)
			Select @GenericModuleID, Item
			From  dbo.udf_ListToGuid(@List, @Delimiter)
			Where Item not in 
					(	select PropertyTemplateID from dbo.GenericModulePropertyMap
						WHERE GenericModuleID= @GenericModuleID )			
		END	

		return 0
	END TRY

	BEGIN CATCH
		RETURN 17004
	END CATCH 

END



GO
GRANT EXECUTE ON [dbo].[Core_GenericModulePropertyMap_Update] TO [websiteuser_role]
GO
