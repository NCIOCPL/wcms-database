IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetProtocolByProtocolIDAndOrgID]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetProtocolByProtocolIDAndOrgID]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





/**********************************************************************************

	Object's name:	usp_GetProtocolByProtocolIDAndOrgID
	Object's type:	Stored procedure
	Purpose:	Get protocols by ProtocolID and OrgID
	Author:		8/19/2004	Lijia Chu
	Change History: 		
				9/27/2004 Bryan Pizzillo  -- Added section fetching and some study site logic

**********************************************************************************/

CREATE PROCEDURE dbo.usp_GetProtocolByProtocolIDAndOrgID
	(
	     @ProtocolID int,
	     @OrgID	int,
	     @SectionList varchar(1000), 
	     @Version 	int
	)
AS
BEGIN

	DECLARE @tmpStrLen int,
		@delimeterPosition smallint,
		@SectionTypeID int,
		@TmpOrgID int
		
	DECLARE	@SectionTypeIDList TABLE (
			SectionTypeID int
			)

	
	SELECT 	P.ProtocolID, 
		(CASE 	WHEN @Version= 2 THEN ISNULL(P.healthprofessionaltitle,P.patienttitle) 
			WHEN @version= 1 THEN ISNULL(P.patienttitle,P.HealthProfessionalTitle)
		END) AS	ProtocolTitle,
		(CASE 	WHEN @version= 2 AND P.HealthProfessionalTitle is not null THEN ISNULL(P.patienttitle,'')
			WHEN @version= 1 AND P.PatientTitle is not null THEN ISNULL(P.HealthProfessionalTitle,'')
			ELSE ''
		END) AS AlternateTitle, 
		P.TypeOfTrial,
		P.LowAge, 
		P.HighAge, 
		P.AgeRange, 
		P.SponsorOfTrial, 
		P.PrimaryProtocolID, 
		P.AlternateProtocolIDs,  
		P.CurrentStatus, 
		P.Phase, 
		p.DateLastModified, 
		p.DateFirstPublished, 
		case isCTprotocol when 1 then 28 else 5 end as documentTypeid
 	FROM 	Protocoldetail P WITH (READUNCOMMITTED)
 	WHERE P.ProtocolID = @ProtocolID

	-- Get Sections
		--RETURN SECTIONS if select is not empty
	SET	@SectionList = RTRIM(LTRIM(@SectionList))
	IF (@SectionList <> '') -- Always create string 
	BEGIN
		/******************************************************************
	  		Section selection here.  This is probably an out of date enumeration
				                                        
	 		PatientAbstract = 1,
			Objectives = 2,
			EntryCriteria = 3,
			ProjectedAccrual = 4,
			Outline = 5,
			PublishedResults = 6,
			Terms = 7,
			HPDisclaimer = 8,
			LeadOrgs = 9,
			PDisclaimer = 10
		********************************************************************/
		SET	@tmpStrLen=LEN(@SectionList)
		SET	@delimeterPosition = PATINDEX ( '%,%' , @SectionList) 
		
		--PRINT 'Entering While Loop'
		WHILE  (@delimeterPosition > 0 )
		BEGIN
			--There is a space
			SET 	@SectionTypeID=CONVERT(int,RTRIM(LTRIM(SUBSTRING(@SectionList,1,@delimeterPosition-1))))
			IF NOT EXISTS (SELECT 1 FROM @SectionTypeIDList WHERE SectionTypeID=@SectionTypeID)
				INSERT INTO @SectionTypeIDList (SectionTypeID)  VALUES (@SectionTypeID)
			
			SET	@SectionList=RTRIM(LTRIM(SUBSTRING(@SectionList,@delimeterPosition+1 , @tmpStrLen-@delimeterPosition)))
			SET	@tmpStrLen=LEN(@SectionList)
			SET	@delimeterPosition = PATINDEX ( '%,%' , @SectionList)
		END
		IF NOT EXISTS (SELECT 1 FROM @SectionTypeIDList WHERE SectionTypeID=CONVERT(int,@SectionList))
			INSERT INTO @SectionTypeIDList (SectionTypeID)  VALUES (CONVERT(int,@SectionList))
		--PRINT 'Exiting While Loop''

		SELECT	PS.* 
		FROM 	ProtocolSection PS WITH (READUNCOMMITTED)
		INNER JOIN @SectionTypeIDList SL
			ON PS.SectionTypeID = SL.SectionTypeID
		WHERE	PS.ProtocolID=@ProtocolID	
	END		


	--Draw the Study Sites 
	--So really, we need to return all if no study sites appear
	
	set @TmpOrgID = (
		Select top 1 OrganizationID 
		from vwprotocolInvestigator
		where OrganizationID = @OrgID
		AND ProtocolID = @ProtocolID
	)
	
	if (@TmpOrgID is not null)
	BEGIN
		SELECT  distinct PCIH.ProtocolContactInfoHtmlID, 
				PCIH.ProtocolID, 
				PCIH.City, 
				PCIH.State, 
				PCIH.Country, 
				PCIH.OrganizationName, 
				PCIH.HTML  
		FROM	ProtocolContactInfoHtml pcih WITH (READUNCOMMITTED)
		JOIN	ProtocolContactinfoHtmlMap pcihm WITH (READUNCOMMITTED)
  		ON 	pcihm.ProtocolContactinfoHtmlID = pcih.ProtocolContactinfoHtmlID
		JOIN	vwProtocolInvestigator  pci WITH (READUNCOMMITTED)
  		ON 	pci.protocolcontactinfoid = pcihm.protocolcontactinfoid	
		WHERE	pci.ProtocolID = @ProtocolID
		AND	pci.OrganizationID=@OrgID
    END
    ELSE
    BEGIN
		SELECT	distinct PCIH.ProtocolContactInfoHtmlID, PCIH.ProtocolID, PCIH.City, PCIH.State, PCIH.Country, PCIH.OrganizationName, PCIH.HTML 
			FROM	ProtocolContactInfoHtml PCIH
				WITH (READUNCOMMITTED)
			WHERE 	PCIH.ProtocolID = @ProtocolID
	END

END


GO
GRANT EXECUTE ON [dbo].[usp_GetProtocolByProtocolIDAndOrgID] TO [websiteuser_role]
GO
