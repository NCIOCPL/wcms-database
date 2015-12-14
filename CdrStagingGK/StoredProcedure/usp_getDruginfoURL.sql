if object_id('usp_getDruginfoURL') is not null
	drop procedure dbo.usp_getDruginfoURL
GO
create procedure dbo.usp_getDruginfoURL (@termID int)
AS
BEGIN
set nocount on
select PrettyURL
from dbo.DrugInfoSummary
where TerminologyLink = @TermID
END
GO
GRANT execute on dbo.usp_getDrugInfoURL to gatekeeperuser

