IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_ModuleStyleSheet_Add]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_ModuleStyleSheet_Add]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_ModuleStyleSheet_Add
    @MainClassName varchar(50)
    ,@CSS varchar(max)
	,@List varchar(max)
    ,@CreateUserID varchar(50)
AS
BEGIN
	Declare @Delimiter varchar(2) ,
			@StyleSheetID uniqueidentifier
	select @Delimiter=','
	select @StyleSheetID = newid()

	BEGIN TRY
		if (dbo.Core_Function_ModuleStylesheetExists(null,@MainClassName ) =1)
			return 10100 -- StylesheetExists

		insert into dbo.ModuleStyleSheet
		(
		   [StyleSheetID]
		  ,[MainClassName]
		  ,[CSS]
		  ,[CreateUserID]
		  ,[CreateDate]
		  ,[UpdateUserID]
		  ,[UpdateDate])
		values
		(
			@StyleSheetID, 
			@MainClassName,
			@CSS,
			@CreateUserID,
			getdate(),
			@CreateUserID,
			getdate()
		)
	
		if (@List <> '')
		BEGIN
			Insert into  dbo.GenericModuleStyleSheetMap
			(GenericModuleID , StyleSheetID)
			Select item, @StyleSheetID
			From  dbo.udf_ListToGuid(@List,@Delimiter)
		END	


	END TRY

	BEGIN CATCH
		RETURN 10103
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_ModuleStyleSheet_Add] TO [websiteuser_role]
GO
