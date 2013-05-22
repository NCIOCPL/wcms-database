IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetProtocolSearchParamsID]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetProtocolSearchParamsID]
GO

/****** Object:   dbo.usp_GetProtocolSearchParamsID    Script Date: 9/6/2005 3:20:00 PM ******/
/*	NCI - National Cancer Institute
*	
*	File Name:	
*	usp_GetProtocolSearchParamsID.sql
*
*	Objects Used:
*
*	9/9/2005 	Min 	Get search parameters using ID
*
*	Change History:
*	9/9/2005 			Script Created
*	12/29/2008			Return keyword text.
*	01/02/2009			Return trial type as text instead of integers to be consistent with save.
*	To Do:
*
*/

CREATE procedure dbo.usp_GetProtocolSearchParamsID
(
	@ProtocolSearchID	int
)  
AS
BEGIN 

set nocount on

declare  @dn varchar(8000), 
 @in varchar(8000), 
 @hn varchar(8000),
 @ln varchar(8000)


	if exists (select * from dbo.ProtocolSearch NOLOCK 		
		WHERE ProtocolSearchID = @ProtocolSearchID and idstring is not null )
	
	begin			
			select @dn =  preferredname  from
					dbo.terminology NOLOCK where termid = 
				(select drugid from dbo.protocolsearch NOLOCK WHERE 
				ProtocolSearchID = @protocolsearchid and drugid is not null and drug is null)
			
	
			
			select  @in = 
				(select top 1 personGivenname + ' ' + PersonSurName from
						dbo.vwProtocolInvestigator  NOLOCK where personid = 
				(select investigatorid from dbo.protocolsearch NOLOCK WHERE 
				ProtocolSearchID = @protocolsearchid and investigatorid is not null and investigator is null)
				)

			
			select @hn =
				(select top 1 name from
					dbo.organizationname NOLOCK where organizationid = 
					(select  institutionid from dbo.protocolsearch NOLOCK WHERE 
					ProtocolSearchID = @protocolsearchid and institutionid is not null and institution is null
						and type='OfficialName')
					)

			
			select @ln=
				(select top 1 name from
					dbo.organizationname where organizationid = 
					(select leadOrganizationid from dbo.protocolsearch WHERE 
						ProtocolSearchID = @protocolsearchid and leadorganizationid is not null and leadorganization is null
						and type='OfficialName'
						)
						)			

	

			SELECT	TOP 1
			ProtocolSearchID,
			CancerType,
			CancerTypeStage,
			trialType,
			ISNULL(NULLIF(LTRIM(RTRIM(TrialStatus)), ''), 'Y') AS TrialStatus,
			AlternateProtocolID,
			ZIP,
			ZIPProximity,
			City,
			State,
			Country,
			case when Institution is null then @hn else institution end as institution,
			case when Investigator is null then @in else investigator end as investigator,
			case when LeadOrganization is null then @ln else leadorganization end as leadorganization,
			IsNIHClinicalCenterTrial,
			IsNew,
			TreatmentType,
			case when Drug is null then @dn else drug end  as drug,
			phase,
			TrialSponsor,
			specialCategory,
			AbstractVersion,
			ParameterOne AS SearchType,
			ParameterTwo AS ParameterDisplayHTML,
			ParameterThree AS CancerTypeName,
			ShowDetailReportMessage,
			DrugSearchFormula,
			dbo.udf_GetStateFullName( State ) AS StateFullName 	,
			drugid,
			--diagnosisid,
			institutionid,
			investigatorid,
			leadOrganizationid,
			keyword,
			treatmentTypeName
		FROM 
			dbo.ProtocolSearch  p  WITH (NOLOCK)
		WHERE 
			ProtocolSearchID = @ProtocolSearchID 

end
else

		SELECT	TOP 1
			ProtocolSearchID,
			CancerType,
			CancerTypeStage,
			trialType,
			ISNULL(NULLIF(LTRIM(RTRIM(TrialStatus)), ''), 'Y') AS TrialStatus,
			AlternateProtocolID,
			ZIP,
			ZIPProximity,
			City,
			State,
			Country,
			Institution,
			Investigator,
			LeadOrganization,
			IsNIHClinicalCenterTrial,
			IsNew,
			TreatmentType,
			Drug,
			Phase,
			TrialSponsor,
			specialCategory,
			AbstractVersion,
			ParameterOne AS SearchType,
			ParameterTwo AS ParameterDisplayHTML,
			ParameterThree AS CancerTypeName,
			ShowDetailReportMessage,
			DrugSearchFormula,
			dbo.udf_GetStateFullName( State ) AS StateFullName ,	-- Bryan requested to add this column at the end of the recordset
			-- @tmpStr AS StateFullName 	-- Bryan requested to add this column at the end of the recordset
			drugid,
			institutionid,
			investigatorid,
			leadOrganizationid,
			keyword,
			treatmentTypeName
		FROM 
			dbo.ProtocolSearch   WITH (NOLOCK)
			
		WHERE 
			ProtocolSearchID = @ProtocolSearchID
	

END

GO
GRANT EXECUTE ON [dbo].[usp_GetProtocolSearchParamsID] TO [websiteuser_role]
GO
