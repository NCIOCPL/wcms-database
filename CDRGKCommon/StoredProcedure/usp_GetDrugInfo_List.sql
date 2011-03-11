
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'usp_GetDrugInfo_List' AND type = 'P') 
   DROP PROCEDURE usp_GetDrugInfo_List
GO

CREATE PROCEDURE [dbo].usp_GetDrugInfo_List
AS
BEGIN
	BEGIN TRY
	set nocount ON

		select DrugInfoSummaryID, Title, PrettyURL, UpdateDate
		from dbo.DrugInfoSummary
		order by title

		RETURN 0  --Succesful return 0
	END TRY

	BEGIN CATCH
		RETURN 100101  --Error code
	END CATCH 
END

GO

GRANT EXECUTE on usp_GetDrugInfo_List TO webSiteUser_role
GO
