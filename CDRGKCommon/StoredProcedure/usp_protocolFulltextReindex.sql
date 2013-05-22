IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_protocolFullTextReindex]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_protocolFullTextReindex]
GO

CREATE PROCEDURE dbo.usp_protocolFullTextReindex with execute as owner
AS
BEGIN
BEGIN TRY
			alter fulltext index on dbo.protocoldetail start full population

			exec dbo.termdrugreload

			drop table dbo.InterventionName

			create table dbo.InterventionName (Interventionid int, InterventionName nvarchar(2200))
			insert into dbo.InterventionName
			select distinct t.termid, t.preferredname from terminology t inner join termsemantictype s on t.termid = s.termid
			where semantictypename = 'Intervention or procedure'
			union 
			select distinct t.termid, ton.othername from terminology t inner join termsemantictype s on t.termid = s.termid
			inner join termothername ton on ton.termid = t.termid
			where semantictypename = 'Intervention or procedure'

			create clustered index CI_InterventionName on dbo.interventionName (InterventionID)

			---------

			drop table dbo.DiagnosisName

			create table dbo.DiagnosisName (Diagnosisid int, diagnosisName nvarchar(2200))
			insert into dbo.DiagnosisName
			select distinct t.termid, t.preferredname from terminology t inner join termsemantictype s on t.termid = s.termid
			where semantictypename in ('Cancer diagnosis', 'Cancer stage', 'Secondary related condition')
			union 
			select distinct t.termid, ton.othername from terminology t inner join termsemantictype s on t.termid = s.termid
			inner join termothername ton on ton.termid = t.termid
			where semantictypename in ('Cancer diagnosis', 'Cancer stage', 'Secondary related condition')

			create clustered index CI_diagnosisName on dbo.diagnosisName (diagnosisID)

			-----------------------------


			-------------
			--active

			truncate table dbo.ActiveProtocolKeyword
			insert into dbo.ActiveProtocolKeyword
			(protocolid, 
			trialsite,
			leadorg,
			investigator,
			specialcategory,
			drug,
			intervention,
			typeofCancer)
			select 
			protocolid,
			case isactiveprotocol when 1 then dbo.udf_getTrialSiteForprotocol(protocolid) else NULL end,  
			dbo.udf_getLeadOrgForprotocol(protocolid),  
			dbo.udf_getInvestigatorForProtocol(protocolid),
			dbo.udf_getSpecialCategoryForprotocol(protocolid),
			dbo.udf_getDrugForprotocol(protocolid),
			dbo.udf_getInterventionForprotocol(protocolid) ,
			dbo.udf_getTypeofCancerForprotocol(protocolid)
			from dbo.protocol 
			where isactiveprotocol =1

			alter fulltext index on dbo.ActiveProtocolkeyword start full population


			----------------------------
			--SectionHTML 
			truncate table dbo.activeProtocolsectionKeyword
			insert into dbo.activeProtocolsectionKeyword
			select protocolid , dbo.udf_getSectionForprotocol(protocolid)
			from dbo.protocol
			where isactiveprotocol =1


			alter fulltext index on dbo.activeprotocolsectionkeyword start full population

			------------------
			------------------
			--closed
			truncate table dbo.closedProtocolKeyword
			insert into dbo.closedprotocolKeyword
			(protocolid, 
			trialsite,
			leadorg,
			investigator,
			specialcategory,
			drug,
			intervention,
			typeofCancer)
			select 
			protocolid,
			case isactiveprotocol when 1 then dbo.udf_getTrialSiteForprotocol(protocolid) else NULL end,  
			dbo.udf_getLeadOrgForprotocol(protocolid),  
			dbo.udf_getInvestigatorForProtocol(protocolid),
			dbo.udf_getSpecialCategoryForprotocol(protocolid),
			dbo.udf_getDrugForprotocol(protocolid),
			dbo.udf_getInterventionForprotocol(protocolid) ,
			dbo.udf_getTypeofCancerForprotocol(protocolid)
			from dbo.protocol
			where isactiveprotocol = 0

			alter fulltext index on dbo.closedprotocolkeyword start full population


			----------------------------
			--SectionHTML 
			truncate table dbo.closedprotocolsectionKeyword
			insert into dbo.closedprotocolsectionKeyword
			select protocolid , dbo.udf_getSectionForprotocol(protocolid)
			from dbo.protocol
			where isactiveprotocol = 0


			alter fulltext index on dbo.closedprotocolsectionkeyword start full population




			

END TRY
BEGIN CATCH
	SELECT 
        ERROR_NUMBER() as ErrorNumber,
        ERROR_MESSAGE() as ErrorMessage;
	return 1
END CATCH



END
GO
Grant execute on dbo.usp_protocolFullTextReindex  to gatekeeperuser
