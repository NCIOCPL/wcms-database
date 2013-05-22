IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetProtocolsByListOfProtocolIDs]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetProtocolsByListOfProtocolIDs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Object:  Stored Procedure dbo.usp_GetProtocolsByListOfProtocolIDs    Script Date: 8/5/2005 9:28:10 AM ******/

/**********************************************************************************

	Object's name:	usp_GetProtocolsByListOfProtocolIDs
	Object's type:	Stored procedure
	Purpose:	Get protocols by ProtocolID list
	
	Change History:
	?/?/2003 	John Doo	Script Created
	12/4/2003	Alex 		Add Phase in to search Result
	3/16/2004	Alex 		Make first table return HealthProfessionalTitle, PatientTitle columns
	8/19/2004	Lijia Chu	Make to use table variable, not use dynamic sql and temp table. 		
	9/09/2005       min 		Modify about when to rerunsearch

**********************************************************************************/



CREATE PROCEDURE dbo.usp_GetProtocolsByListOfProtocolIDs
	(
	     @ProtocolList varchar(3000),
	     @SectionList varchar(1000), -- For psrv 
	     @DrawStudySites bit, -- For PSRV
	     @Version int,
	     @ProtocolSearchID int, -- For psrv and View clinical from filtered search
		 @SortFilter int  = 4		
	)
AS
BEGIN
	set nocount on 
	----- These are variables ---------
	DECLARE @tmpStrLen int,
		@delimeterPosition smallint,
		@SectionTypeID int,
		@ProtocolID int
				
	--This is temporary protocol cache
	DECLARE  @TempProto TABLE (		
		ResultNumber int identity(1,1),
		ProtocolID int,
		ProtocolTitle varchar(1000), 
		AlternateTitle varchar(1000),
		-- ProtocolTitle varchar(1000),
		TypeOfTrial varchar(255),
		LowAge int,
		HighAge int,
		AgeRange varchar(500),
		SponsorOfTrial varchar(255),
		PrimaryProtocolID varchar(50),
		AlternateProtocolIDs varchar(1000),
		CurrentStatus varchar(50),
		Phase varchar(255),
		DateLastModified datetime,
		DateFirstPublished datetime,
		DocumentTypeID int
	)

	--This is for temporary pci cache info 
	DECLARE @TempProtoContact TABLE (
		ProtocolID int,
		ProtocolContactInfoID int		

	)

	DECLARE	@SectionTypeIDList TABLE (
			SectionTypeID int
			)

	DECLARE	@ProtocolIDList TABLE (
			ProtocolID int
			)

	DEClARE @isIDsearch bit 

	--Rerun search if there is no cache
	IF (@ProtocolSearchID <> 0)
	BEGIN
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

	SET	@ProtocolList = RTRIM(LTRIM(@ProtocolList))
	SET	@tmpStrLen=LEN(@ProtocolList)
	SET	@delimeterPosition = PATINDEX ( '%,%' , @ProtocolList) 
		
	--PRINT 'Entering While Loop'
	WHILE  (@delimeterPosition > 0 )
	BEGIN
		--There is a space
		SET 	@ProtocolID=CONVERT(int,RTRIM(LTRIM(SUBSTRING(@ProtocolList,1,@delimeterPosition-1))))
		IF NOT EXISTS (SELECT 1 FROM @ProtocolIDList WHERE ProtocolID=@ProtocolID)
			INSERT INTO @ProtocolIDList (ProtocolID)  VALUES (@ProtocolID)
			
		SET	@ProtocolList=RTRIM(LTRIM(SUBSTRING(@ProtocolList,@delimeterPosition+1 , @tmpStrLen-@delimeterPosition)))
		SET	@tmpStrLen=LEN(@ProtocolList)
		SET	@delimeterPosition = PATINDEX ( '%,%' , @ProtocolList)
	END
	IF NOT EXISTS (SELECT 1 FROM @ProtocolIDList WHERE ProtocolID=CONVERT(int,@ProtocolList))
		INSERT INTO @ProtocolIDList (ProtocolID)  VALUES (CONVERT(int,@ProtocolList))
	--PRINT 'Exiting While Loop'


		
	--This selects out the items in the cache, and puts them into the temp table so we
	--can get a subset of results.
	INSERT INTO @TempProto (ProtocolID, 
				ProtocolTitle, 
				AlternateTitle, 
				TypeOfTrial,	
				LowAge, 
				HighAge, 
				AgeRange, 
				SponsorOfTrial,	
				PrimaryProtocolID, 
				AlternateProtocolIDs,  
				CurrentStatus, 
				Phase, 
				DateLastModified, 
				DateFirstPublished, 
				DocumentTypeID)
		SELECT	pd.ProtocolID, 
 			(CASE 	WHEN @Version= 2 THEN ISNULL(pd.healthprofessionaltitle,pd.patienttitle) 
				WHEN @version= 1 THEN ISNULL(pd.patienttitle,pd.HealthProfessionalTitle)
			END) AS	ProtocolTitle,
			(CASE 	WHEN @version= 2 AND pd.HealthProfessionalTitle is not null THEN pd.patienttitle
				WHEN @version= 1 AND pd.PatientTitle is not null THEN pd.HealthProfessionalTitle
				ELSE NULL
			END) AS	AlternateTitle,
 			pD.TypeOfTrial,
			pD.LowAge, 
			pD.HighAge, 
			pD.AgeRange, 
			pD.SponsorOfTrial, 
			pD.PrimaryProtocolID, 
			pD.AlternateProtocolIDs,  
			pD.CurrentStatus, 
			pD.Phase,
			pD.DateLastModified,
			nullif(pd.DateFirstPublished,''), 
			case isCTprotocol when 1 then 28 else 5 end as DocumentTypeID
		FROM 	(select distinct protocolid,rank from dbo.ProtocolSearchSysCache AS C WITH (READUNCOMMITTED) where ProtocolSearchID = @ProtocolSearchID)
				a
			inner join dbo.protocoldetail pd on pd.protocolid  = a.protocolid
			INNER JOIN @ProtocolIDList PL
			ON a.ProtocolID=PL.ProtocolID  
		ORDER BY 
			case WHEN @SortFilter=15 THEN rank end desc,
				CASE WHEN @SortFilter=1 AND @Version= 2 THEN ISNULL(pd.healthprofessionaltitle,pd.patienttitle)
			      WHEN @SortFilter=1 AND @Version= 1 THEN ISNULL(pd.patienttitle,pd.HealthProfessionalTitle)
			      WHEN @SortFilter=3 THEN pd.Phase
			      WHEN @SortFilter=5 THEN pd.PrimaryProtocolID
			      WHEN @SortFilter=7 THEN pd.TypeOfTrial
			      WHEN @SortFilter=9 THEN pd.CurrentStatus
			      WHEN @SortFilter=11 THEN pd.AgeRange
			      WHEN @SortFilter=13 THEN pd.SponsorOfTrial
			 END,
			 CASE WHEN @SortFilter=2 AND @Version= 2 THEN ISNULL(pd.healthprofessionaltitle,pd.patienttitle)
			      WHEN @SortFilter=2 AND @Version= 1 THEN ISNULL(pd.patienttitle,pd.HealthProfessionalTitle)
			      WHEN @SortFilter=4 THEN pd.Phase
			      WHEN @SortFilter=6 THEN pd.PrimaryProtocolID
			      WHEN @SortFilter=8 THEN pd.TypeOfTrial
			      WHEN @SortFilter=10 THEN pd.CurrentStatus
			      WHEN @SortFilter=12 THEN pd.AgeRange
			      WHEN @SortFilter=14 THEN pd.SponsorOfTrial
			      WHEN @SortFilter<1 OR @SortFilter>15 THEN pd.Phase
			 END DESC , pd.protocolid 
	 
	
	--RETURN PROTOCOL TABLE
	SELECT * FROM @TempProto	order by resultnumber

	
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


		--PRINT 'Exiting While Loop'

		SELECT	PS.* 
		FROM 	dbo.ProtocolSection PS WITH (READUNCOMMITTED)
		INNER JOIN @TempProto TP
			ON PS.ProtocolID = TP.ProtocolID
		INNER JOIN @SectionTypeIDList SL
			ON PS.SectionTypeID = SL.SectionTypeID
	END		

	--Draw the Study Sites If it was asked
	
	IF @DrawStudySites <> 0
	BEGIN
		IF (@ProtocolSearchID <> 0) 
		BEGIN
			--Now lets get the cached contacts
			INSERT INTO @TempProtoContact (ProtocolID, ProtocolContactInfoID)
			SELECT	distinct PSCC.ProtocolID, 
				PSCC.ProtocolContactInfoID
			FROM	dbo.ProtocolSearchContactCache PSCC
				WITH (READUNCOMMITTED),
				dbo.ProtocolContactInfoHtmlMap PCIHM
				WITH (READUNCOMMITTED),
				@TempProto TP
			WHERE 	PSCC.ProtocolSearchID = @ProtocolSearchID
			AND 	PCIHM.ProtocolContactInfoID = PSCC.ProtocolContactInfoID
			AND 	PSCC.ProtocolID = TP.ProtocolID
			
			--Return Table of Study Sites			
			IF @@ROWCOUNT> 0
			BEGIN
				SELECT	distinct PCIH.ProtocolContactInfoHtmlID, PCIH.ProtocolID, PCIH.City, PCIH.State, PCIH.Country, PCIH.OrganizationName, PCIH.HTML 
				FROM	dbo.ProtocolContactInfoHtml PCIH
					WITH (READUNCOMMITTED),
					dbo.ProtocolContactInfoHtmlMap PCIHM
					WITH (READUNCOMMITTED),
					@TempProtoContact TPC
				WHERE 	TPC.ProtocolContactInfoID = PCIHM.ProtocolContactInfoID
				AND 	PCIH.ProtocolContactInfoHtmlID = PCIHM.ProtocolContactInfoHtmlID
			END
			ELSE 
			BEGIN
				SELECT distinct PCIH.ProtocolContactInfoHtmlID, PCIH.ProtocolID, PCIH.City, PCIH.State, PCIH.Country, PCIH.OrganizationName, PCIH.HTML 
				FROM 	dbo.ProtocolContactInfoHtml PCIH
					WITH (READUNCOMMITTED),
					@TempProto TP
				WHERE 	TP.ProtocolID = PCIH.ProtocolID
			END
		END
		ELSE
		BEGIN
			SELECT 	distinct PCIH.ProtocolContactInfoHtmlID, 
				PCIH.ProtocolID, 
				PCIH.City, 
				PCIH.State, 
				PCIH.Country, 
				PCIH.OrganizationName, 
				PCIH.HTML 
			FROM 	dbo.ProtocolContactInfoHtml PCIH
				WITH (READUNCOMMITTED),
				@TempProto TP
			WHERE 	TP.ProtocolID = PCIH.ProtocolID	
		END
	END
	
	
	

END




GO
GRANT EXECUTE ON [dbo].[usp_GetProtocolsByListOfProtocolIDs] TO [websiteuser_role]
GO
