IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[vw_CachedProtocolSearch]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[vw_CachedProtocolSearch]
GO



/****** Object:  View dbo.vw_CachedProtocolSearch    Script Date: 7/5/2006 2:15:46 PM ******/

/****** Object:  View dbo.vw_CachedProtocolSearch    Script Date: 7/18/2005 12:15:14 PM ******/


/*	NCI - National Cancer Institute
*	
*	Purpose:	
*
*	Objects Used:
*
*	Change History:
*/

CREATE VIEW dbo.vw_CachedProtocolSearch
AS

select 
	ProtocolSearchID,
	-- SearchDate,  -- we do not need to worry about this records
	ISNULL( convert( varchar(900), CancerType), '') AS 'CancerType',
	ISNULL( convert( varchar(900), CancerTypeStage ), '') AS 'CancerTypeStage',
	ISNULL( TrialType , '') AS 'TrialType',
	ISNULL( TrialStatus , '') AS 'TrialStatus',
	ISNULL( convert( varchar(900), AlternateProtocolID ), '') AS 'AlternateProtocolID',
	ISNULL( ZIP , '') AS 'ZIP',
	ISNULL( ZIPProximity , '') AS 'ZIPProximity',
	ISNULL( City , '') AS 'City',
	ISNULL( State , '') AS 'State',
	ISNULL( Country , '') AS 'Country',
	ISNULL( convert( varchar(900), Institution ), '') AS 'Institution',
	ISNULL( convert( varchar(900), Investigator ), '') AS 'Investigator',
	ISNULL( convert( varchar(900), LeadOrganization ), '') AS 'LeadOrganization',
	ISNULL( convert( varchar(900), VAMilitaryOrganization ), '') AS 'VAMilitaryOrganization',
	ISNULL( IsNIHClinicalCenterTrial , '') AS 'IsNIHClinicalCenterTrial',
	ISNULL( IsNew , '') AS 'IsNew',
	ISNULL( convert( varchar(900), TreatmentType ), '') AS 'TreatmentType' ,
	ISNULL( convert( varchar(900), Drug ), '') AS 'Drug',
	ISNULL( Phase , '') AS 'Phase',
	ISNULL( convert( varchar(900), TrialSponsor) , '') AS 'TrialSponsor',
	ISNULL( AbstractVersion , '') AS 'AbstractVersion',
	ISNULL( convert( varchar(900), ParameterOne ), '') AS 'ParameterOne',
	ISNULL( convert( varchar(900), ParameterTwo ), '') AS 'ParameterTwo',
	ISNULL( convert( varchar(900), ParameterThree ), '') AS 'ParameterThree',
	ISNULL( DrugSearchFormula, '') AS 'DrugSearchFormula' ,
	ISNULL(SpecialCategory, '') AS 'SpecialCategory' 			----Gao 7/18 SC
	-- ISNULL( SearchType, '') AS 'SearchType'
	-- ShowDetailReportMessage, -- we do not need to worry about this records
	-- CanBeDeleted, -- we do not need to worry about this records
	-- IsCachedSearchResultAvailable, -- we do not need to worry about this records
	-- Requested -- we do not need to worry about this records
from 	dbo.ProtocolSearch
with 	( readuncommitted )
where 	IsCachedSearchResultAvailable = 1




GO
