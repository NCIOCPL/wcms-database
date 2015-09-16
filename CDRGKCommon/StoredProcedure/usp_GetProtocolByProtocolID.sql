IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetProtocolByProtocolID]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetProtocolByProtocolID]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Object:  Stored Procedure dbo.usp_GetProtocolByProtocolID    Script Date: 9/22/2005 12:08:45 PM ******/




/**********************************************************************************

	Object's name:	usp_GetProtocolByProtocolID
	Object's type:	Stored procedure
	Purpose:	Get protocols by ProtocolID

	Calling code:
	09/15/2015 CDE_ROOT\CDESites\CancerGov\CDR.DataManager\Protocol.cs
	
	Change History:
	?/?/2003 	John Doo		Script Created
	12/4/2003	Alex 			Add Phase in to search Result
	3/16/2004	Alex 			Make first table return pd.healthprofessionaltitle, pd.patienttitle columns
	8/19/2004	Lijia Chu		Make to use table variable, not use dynamic sql and temp table.
	10/18/2004	Lijia Chu		SectionList to 1000 		
	09/15/2015  Bryan Pizzillo	Include NCTID in return columns


**********************************************************************************/

CREATE PROCEDURE dbo.usp_GetProtocolByProtocolID
	(
	     @ProtocolID int,
	     @SectionList varchar(1000), 
	     @Version int,
	     @ProtocolSearchID int -- For psrv and View clinical from filtered search
	)
AS
BEGIN
	set nocount on 
	----- These are variables ---------
	DECLARE @tmpStrLen int,
		@delimeterPosition smallint,
		@SectionTypeID int
				
	--This is for temporary pci cache info 
	DECLARE @TempProtoContact TABLE (
		ProtocolID int,
		ProtocolContactInfoID int		

	)

	DECLARE	@SectionTypeIDList TABLE (
			SectionTypeID int
			)

	DEClARE @isIDsearch bit 

	--Rerun search if there is no cache
	IF (@ProtocolSearchID <> 0)
	BEGIN
		
		/*IF EXISTS (SELECT 1 FROM ProtocolSearch with (READUNCOMMITTED) 
				WHERE ProtocolSearchID=@ProtocolSearchID
				  AND (IsCachedSearchResultAvailable=0 OR IsCachedContactsAvailable=0))
	
			EXEC usp_ReRunSearch @ProtocolSearchID = @ProtocolSearchID
		*/




	--Rerun search if there is no cache

	SELECT @isIDsearch = case when idstring is null then 0 else 1 end  FROM dbo.ProtocolSearch WITH (READUNCOMMITTED) 
			WHERE ProtocolSearchID=@ProtocolSearchID
			  AND (IsCachedSearchResultAvailable=0 
				----Gao 7/21/05 if no location or any other contact search is done, no need to reRun Search because of IsCachedSearchResultAvailable=0
					OR
					( idstring is not null and IsCachedContactsAvailable=0 
						and COALESCE(datalength(ZIP),	datalength(ZIPProximity),	datalength(City),	datalength(State	),datalength(Country),datalength(InstitutionID),datalength(InvestigatorID),datalength(LeadOrganizationID)) is not null 
					)  
					OR 
					(idstring is null and (IsCachedContactsAvailable=0 
						and COALESCE(datalength(ZIP),	datalength(ZIPProximity),	datalength(City),	datalength(State	),datalength(Country),datalength(Institution	),datalength(Investigator	),datalength(LeadOrganization)) is not null) 
					)  
				)


		if @isIDsearch = 1 
			EXEC dbo.usp_ReRunSearchID @ProtocolSearchID = @ProtocolSearchID

		if @isIDsearch = 0 
			EXEC dbo.usp_ReRunSearch @ProtocolSearchID = @ProtocolSearchID

	END
	
	--This selects out the items in the cache, and puts them into the temp table so we
	--can get a subset of results.
	
	SELECT 	ProtocolID, 
		(CASE 	WHEN @Version= 2 THEN ISNULL(healthprofessionaltitle,patienttitle) 
			WHEN @version= 1 THEN ISNULL(patienttitle,healthprofessionaltitle)
		END) AS	ProtocolTitle,
		(CASE 	WHEN @version= 2 AND healthprofessionaltitle is not null THEN ISNULL(patienttitle,'')
			WHEN @version= 1 AND patienttitle is not null THEN ISNULL(healthprofessionaltitle,'')
			ELSE ''
		END) AS AlternateTitle, 
		TypeOfTrial,
		LowAge, 
		HighAge, 
		AgeRange, 
		SponsorOfTrial, 
		PrimaryProtocolID, 
		AlternateProtocolIDs,  
		( SELECT TOP 1 IDstring FROM protocolAlternateID WHERE idtypeid = 4) as NCTID,
		CurrentStatus, 
		Phase, 
		DateLastModified, 
		DateFirstPublished, 
		case isCTprotocol when 1 then 28 else 5 end as DocumentTypeID
 	FROM 	Protocoldetail WITH (READUNCOMMITTED) 
 	WHERE ProtocolID = @ProtocolID

	
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

	--Draw the Study Sites If it was asked

	--Now lets get the cached contacts
	IF (@ProtocolSearchID <> 0)
	BEGIN
		INSERT INTO @TempProtoContact (ProtocolID, ProtocolContactInfoID)
		SELECT	distinct PSCC.ProtocolID, PSCC.ProtocolContactInfoID
		FROM 	ProtocolSearchContactCache PSCC WITH (READUNCOMMITTED),
			ProtocolContactInfoHtmlMap PCIHM WITH (READUNCOMMITTED)
		WHERE 	PSCC.ProtocolSearchID = @ProtocolSearchID
		  AND 	PCIHM.ProtocolContactInfoID = PSCC.ProtocolContactInfoID
		  AND PSCC.ProtocolID = @ProtocolID
		
		--Return Table of Study Sites			
		IF @@rowcount> 0
		BEGIN
			SELECT	distinct PCIH.ProtocolContactInfoHtmlID, PCIH.ProtocolID, PCIH.City, PCIH.State, PCIH.Country, PCIH.OrganizationName, PCIH.HTML 
			FROM	ProtocolContactInfoHtml PCIH WITH (READUNCOMMITTED),
				ProtocolContactInfoHtmlMap PCIHM WITH (READUNCOMMITTED),
				@TempProtoContact TPC
			WHERE 	TPC.ProtocolContactInfoID = PCIHM.ProtocolContactInfoID
			AND 	PCIH.ProtocolContactInfoHtmlID = PCIHM.ProtocolContactInfoHtmlID
		END
		ELSE 
		BEGIN
			SELECT 	distinct PCIH.ProtocolContactInfoHtmlID, PCIH.ProtocolID, PCIH.City, PCIH.State, PCIH.Country, PCIH.OrganizationName, PCIH.HTML 
			FROM 	ProtocolContactInfoHtml PCIH WITH (READUNCOMMITTED)
			WHERE 	PCIH.ProtocolID = @ProtocolID
		END
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
GRANT EXECUTE ON [dbo].[usp_GetProtocolByProtocolID] TO [websiteuser_role]
GO
