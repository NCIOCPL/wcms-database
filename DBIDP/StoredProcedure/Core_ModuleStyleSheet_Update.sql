IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_ModuleStyleSheet_Update]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_ModuleStyleSheet_Update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_ModuleStyleSheet_Update
	@StyleSheetID uniqueidentifier
    ,@MainClassName varchar(50)
    ,@CSS varchar(max)
	,@List varchar(max)
    ,@UpdateUserID varchar(50)
AS
BEGIN
	Declare @Delimiter varchar(2)
	select @Delimiter=','

	BEGIN TRY
		if (dbo.Core_Function_ModuleStylesheetExists(@StyleSheetID,@MainClassName ) =1)
			return 10100 -- StylesheetExists

		update dbo.ModuleStyleSheet
		set [MainClassName] = @MainClassName,
			[CSS] = @CSS,
			[UpdateUserID] = @UpdateUserID,
		    [UpdateDate] = getdate()
		where [StyleSheetID] = @StyleSheetID

		if (@List = '')
		BEGIN
			Delete From dbo.GenericModuleStyleSheetMap
			WHERE StyleSheetID= @StyleSheetID 
		END
		ELSE
		BEGIN
			--CategoryMap
			Delete From dbo.GenericModuleStyleSheetMap 
			WHERE StyleSheetID= @StyleSheetID  and GenericModuleID 
				not in (select Item from  dbo.udf_ListToGuid(@List, @Delimiter) )

			Insert into  dbo.GenericModuleStyleSheetMap
			(GenericModuleID , StyleSheetID)
			Select Item, @StyleSheetID
			From  dbo.udf_ListToGuid(@List, @Delimiter)
			Where Item not in 
					(	select GenericModuleID from dbo.GenericModuleStyleSheetMap
						WHERE StyleSheetID= @StyleSheetID )
		END	
	
	END TRY

	BEGIN CATCH
		RETURN 10104 
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_ModuleStyleSheet_Update] TO [websiteuser_role]
GO
