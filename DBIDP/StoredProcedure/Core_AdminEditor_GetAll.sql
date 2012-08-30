IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_AdminEditor_GetAll]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_AdminEditor_GetAll]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE  PROCEDURE [dbo].Core_AdminEditor_GetAll
AS
BEGIN
	BEGIN TRY

		SELECT [AdminEditorID]
		  ,[Namespace]
		  ,[AssemblyName]
		  ,[AdminEditorClass]
		FROM [dbo].[AdminEditor]
		order by [Namespace], [AdminEditorClass]
		
	END TRY

	BEGIN CATCH
		RETURN 10202
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_AdminEditor_GetAll] TO [websiteuser_role]
GO
