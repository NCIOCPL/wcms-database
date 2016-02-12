IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[TermDrugReload]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[TermDrugReload]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure dbo.TermDrugReload
with execute as owner
as
BEGIN
set nocount on
declare @d table (termid int, drugname nvarchar(1100), displayName nvarchar(1100))

if exists (select * from sys.indexes where name = 'CI_termdrug')
	drop index termdrug.CI_termdrug
begin tran
insert into @d (termid, drugname, displayname)
-- Drugs
select 	distinct T.TermID,
	T.PreferredName AS DrugName,
	T.PreferredName AS DisplayName	  
from 	dbo.Terminology AS T
	inner join dbo.TermSemanticType AS TST
		ON T.TermID = TST.TermID 
		AND TST.SemanticTypeName = 'Drug/agent'
	INNER JOIN dbo.ProtocolDrug AS PD
		ON T.TermID = PD.DrugID
UNION ALL
-- OtherNames 
select 	Distinct T.TermID,
	TON.OtherName AS DrugName,
	LTRIM(RTRIM( TON.OtherName )) + ' (Other Name for: ' + LTRIM(RTRIM( T.PreferredName )) + ')' AS 'DisplayName'	  
from 	dbo.Terminology AS T
	inner join dbo.TermOtherName AS TON
		ON TON.TermID = T.TermID 
	inner join dbo.TermSemanticType AS TST1
		ON TON.TermID = TST1.TermID 
		AND TST1.SemanticTypeName = 'Drug/agent'
	INNER JOIN dbo.ProtocolDrug AS PD
		ON T.TermID = PD.DrugID
truncate table dbo.TermDrug 
if @@error <> 0 
	begin
	rollback tran
	RAISERROR(N'termDrugReload error failed to truncate', 16, 1) with log;
	return -1001
	end
INSERT INTO dbo.TermDrug select * from @d ORDER By DrugName
if @@error <> 0 
	begin
	rollback tran
	RAISERROR(N'termDrugReload error failed to insert', 16, 1) with log;
	return -1000
	end
commit tran
create clustered index CI_termdrug on termdrug(termid)
END


GO
