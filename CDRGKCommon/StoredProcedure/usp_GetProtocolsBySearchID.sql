IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetProtocolsBySearchID]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetProtocolsBySearchID]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Object:  Stored Procedure dbo.usp_GetProtocolsBySearchID    Script Date: 8/5/2005 9:26:29 AM ******/

/**********************************************************************************

	Object's name:	usp_GetProtocolsBySearchID
	Object's type:	Stored procedure
	Purpose:	Get protocols by SearchID
	
	Change History:
	??/??/2003 	Bryan Pizzillo 	Script Created
	7/16/2003 	Alex Pidlisnyy	Add new parameters, review function, add DBO user
	12/4/2003	Alex 		Add Phase in to search Result
	3/16/2004	Alex 		Make first table return HealthProfessionalTitle, PatientTitle columns
	8/19/2004	Lijia Chu	Make to use table variable, not use dynamic sql and temp table. 		
	9/16/2005	Min 		Change for reRunsearch 

**********************************************************************************/


CREATE PROCEDURE dbo.usp_GetProtocolsBySearchID
	(
       	 @ProtocolSearchID int,
	     @SortFilter int,   
	     @Page int,
	     @ResultsPerPage int, 
	     @SectionList varchar(1000),  
	     @DrawStudySites bit,
	     @Version int,
   	     @TotalResults int = NULL OUTPUT
	)
AS
BEGIN
	set nocount on
	----- These are variables ---------
	DECLARE	@ResultsLowerBound int,
		@ResultsHigherBound int,
		@tmpStrLen int,
		@delimeterPosition smallint,
		@SectionTypeID int
	--This is temporary protocol cache
	DECLARE @TempProto TABLE (		
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
	DECLARE	@TempProtoContact TABLE  (
			ProtocolID int,
			ProtocolContactInfoID int		
			)			 
	DECLARE	@SectionTypeIDList TABLE (
			SectionTypeID int
			)

	DEClARE @isIDsearch bit 


	--Rerun search if there is no cache

		if exists (select * FROM dbo.ProtocolSearch WITH (READUNCOMMITTED) 
			WHERE ProtocolSearchID=@ProtocolSearchID
			  AND IsCachedSearchResultAvailable=0 )
			BEGIN
				EXEC dbo.usp_ReRunSearchID @ProtocolSearchID = @ProtocolSearchID
			END
	
	
		if @ResultsPerPage =25 and @page= 1
		begin
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
				SELECT 	top 25 pd.ProtocolID, 
				(CASE WHEN @Version= 2 THEN ISNULL(pd.healthprofessionaltitle,pd.patienttitle) 
				     WHEN @version= 1 THEN ISNULL(pd.patienttitle,pd.HealthProfessionalTitle)
				END) AS	ProtocolTitle,
				(CASE WHEN @version= 2 AND pd.HealthProfessionalTitle is not null THEN pd.patienttitle
				     WHEN @version= 1 AND pd.PatientTitle is not null THEN pd.HealthProfessionalTitle
				     ELSE NULL
				END) AS	AlternateTitle,
				pd.TypeOfTrial, 
				pd.LowAge, 
				pd.HighAge, 
				pd.AgeRange, 
				pd.SponsorOfTrial, 
				pd.PrimaryProtocolID, 
				pd.AlternateProtocolIDs, 
				pd.CurrentStatus, 
				pd.Phase, 
				pd.DateLastModified,
				nullif(pd.DateFirstPublished,''),
				case pd.isCTprotocol when 1 then 28 else 5 end as DocumentTYpeID
								
		FROM	(select distinct protocolid,rank from dbo.ProtocolSearchSysCache AS C WITH (READUNCOMMITTED) where ProtocolSearchID = @ProtocolSearchID)
				a
			inner join dbo.protocoldetail pd on pd.protocolid  = a.protocolid
		
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
			 END DESC, pd.protocolid
			 
	
			select	@TotalResults = count( distinct protocolid) from dbo.protocolsearchsyscache where protocolsearchid = @protocolsearchid
			goto FinalResult
		end			 









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
		SELECT  pd.ProtocolID, 
				(CASE WHEN @Version= 2 THEN ISNULL(pd.healthprofessionaltitle,pd.patienttitle) 
				     WHEN @version= 1 THEN ISNULL(pd.patienttitle,pd.HealthProfessionalTitle)
				END) AS	ProtocolTitle,
				(CASE WHEN @version= 2 AND pd.HealthProfessionalTitle is not null THEN pd.patienttitle
				     WHEN @version= 1 AND pd.PatientTitle is not null THEN pd.HealthProfessionalTitle
				     ELSE NULL
				END) AS	AlternateTitle,
				pd.TypeOfTrial, 
				pd.LowAge, 
				pd.HighAge, 
				pd.AgeRange, 
				pd.SponsorOfTrial, 
				pd.PrimaryProtocolID, 
				pd.AlternateProtocolIDs, 
				pd.CurrentStatus, 
				pd.Phase, 
				pd.DateLastModified,
				nullif(pd.DateFirstPublished,''),
				case pd.isCTprotocol when 1 then 28 else 5 end as DocumentTYpeID
				--dbo.udf_GetDocProperty( D.DocumentID, ''DateFirstPublished'') AS DateFirstPublished '
				--	DateFirstPublished = 
				--		case
				--			when D.[XML] like '%DateFirstPublished%' Then dbo.udf_GetDocProperty( D.DocumentID, 'DateFirstPublished')
				--			else NULL
				--		END
						
		FROM	(select distinct protocolid,rank from dbo.ProtocolSearchSysCache AS C WITH (READUNCOMMITTED) where ProtocolSearchID = @ProtocolSearchID)
				a
			inner join dbo.protocoldetail pd on pd.protocolid  = a.protocolid
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
			 
	
			select	@TotalResults = count( distinct protocolid) from dbo.protocolsearchsyscache where protocolsearchid = @protocolsearchid


	--Set up the number of results to fetch
	SET	@ResultsLowerBound = @ResultsPerPage * (@Page - 1)
	SET	@ResultsHigherBound = @ResultsLowerBound + @ResultsPerPage
		
	--Check to make sure they are not asking for a page that does not exist
	IF (@ResultsLowerBound >= @TotalResults)
	BEGIN
		--We need to make something up
		--Find the last page
		DECLARE @LastPage int
		
		IF ((@TotalResults % @ResultsPerPage) <> 0)
			Set @LastPage = (@TotalResults / @ResultsPerPage) + 1
		ELSE
			set @LastPage = @TotalResults / @ResultsPerPage
		
	
		SET	@ResultsLowerBound = @ResultsPerPage * (@LastPage - 1)
		SET	@ResultsHigherBound = @ResultsLowerBound + @ResultsPerPage
	END

	--print 'Lower Bound : ' + convert(varchar(20),@ResultsLowerBound)
	--print 'Higher Bound : ' + convert(varchar(20),@ResultsHigherBound)

	--print 'Total Results : ' + convert(varchar(20),@TotalResults)
	
	--Narrow Results
	--So remove all Items that are not on the page
	DELETE FROM @TempProto
	where ResultNumber <= @ResultsLowerBound
	OR ResultNumber > @ResultsHigherBound

FinalResult:
	--RETURN TRUNCATED PROTOCOL TABLE
	SELECT * FROM @TempProto
	ORDER BY ResultNumber


	--RETURN SECTIONS if select is not empty
	SET	@SectionList = RTRIM(LTRIM(@SectionList))
	IF (@SectionList <> '')
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
	IF (@DrawStudySites <> 0)
	BEGIN
	
		--Now lets get the cached contacts
		INSERT INTO @TempProtoContact (ProtocolID, ProtocolContactInfoID)
		SELECT	distinct PSCC.ProtocolID, PSCC.ProtocolContactInfoID
		FROM	dbo.ProtocolSearchContactCache PSCC WITH (READUNCOMMITTED)
		INNER JOIN ProtocolContactInfoHtmlMap PCIHM WITH (READUNCOMMITTED)
			ON PCIHM.ProtocolContactInfoID = PSCC.ProtocolContactInfoID
		INNER JOIN @TempProto TP
			ON PSCC.ProtocolID = TP.ProtocolID
		WHERE PSCC.ProtocolSearchID = @ProtocolSearchID
	 	
		--Hrmm... Lets remove the ProtocolContacts who are not contained in blobs	

		--Return Table of Study Sites			
		IF (@@ROWCOUNT> 0) 
		BEGIN
	
			if not exists
			(select * from
			(select protocolcontactinfoid 
				from dbo.ProtocolSearchContactCache 
				where ProtocolSearchID = @protocolsearchid) 
			 PSCC   inner join dbo.protocoltrialsite pt on pt.protocolcontactinfoid = PSCC.protocolcontactinfoID
			)
				BEGIN
							SELECT	distinct PCIH.ProtocolContactInfoHtmlID, PCIH.ProtocolID, PCIH.City, PCIH.State, PCIH.Country, PCIH.OrganizationName, PCIH.HTML 
							FROM	dbo.ProtocolContactInfoHtml PCIH WITH (READUNCOMMITTED)
							INNER JOIN ProtocolContactInfoHtmlMap PCIHM WITH (READUNCOMMITTED)
								ON PCIH.ProtocolContactInfoHtmlID = PCIHM.ProtocolContactInfoHtmlID
							INNER JOIN @TempProtoContact TPC
								ON TPC.ProtocolContactInfoID = PCIHM.ProtocolContactInfoID
							union all

							SELECT	distinct PCIH.ProtocolContactInfoHtmlID, PCIH.ProtocolID, PCIH.City, PCIH.State, PCIH.Country, PCIH.OrganizationName, PCIH.HTML 
							FROM	@tempproto tp inner join protocoltrialsite pts on tp.protocolid = pts.protocolid
									inner join dbo.ProtocolContactInfoHtmlMAP PCIHM WITH (READUNCOMMITTED)
									on pcihm.protocolcontactinfoid = pts.protocolcontactinfoid
									inner join dbo.ProtocolContactInfoHtml PCIH WITH (READUNCOMMITTED)
									on pcihm.protocolcontactinfohtmlID = pcih.protocolcontactinfohtmlID 
									
					
				END
				ELSE
					BEGIN
		
							SELECT	distinct PCIH.ProtocolContactInfoHtmlID, PCIH.ProtocolID, PCIH.City, PCIH.State, PCIH.Country, PCIH.OrganizationName, PCIH.HTML 
							FROM	dbo.ProtocolContactInfoHtml PCIH WITH (READUNCOMMITTED)
							INNER JOIN ProtocolContactInfoHtmlMap PCIHM WITH (READUNCOMMITTED)
								ON PCIH.ProtocolContactInfoHtmlID = PCIHM.ProtocolContactInfoHtmlID
							INNER JOIN @TempProtoContact TPC
								ON TPC.ProtocolContactInfoID = PCIHM.ProtocolContactInfoID
					END




		END
		ELSE 
		BEGIN
			SELECT	distinct PCIH.ProtocolContactInfoHtmlID, PCIH.ProtocolID, PCIH.City, PCIH.State, PCIH.Country, PCIH.OrganizationName, PCIH.HTML 
			FROM	dbo.ProtocolContactInfoHtml PCIH WITH (READUNCOMMITTED)
			INNER JOIN @TempProto TP
				ON TP.ProtocolID = PCIH.ProtocolID
		END

	END


END
GO
GRANT EXECUTE ON [dbo].[usp_GetProtocolsBySearchID] TO [websiteuser_role]
GO
