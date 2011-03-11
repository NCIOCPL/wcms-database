IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetProtocolsByTCResultsList]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetProtocolsByTCResultsList]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/**********************************************************************************

	Object's name:	usp_GetProtocolsByTCResultsList
	Object's type:	Stored procedure
	Purpose:	Get protocols by trial check search results
	Author:		9/08/2004	Lijia Chu	
	Change History:

**********************************************************************************/



CREATE PROCEDURE dbo.usp_GetProtocolsByTCResultsList
	(
	     @ProtocolIdList varchar(8000),
	     @Version int
	)
AS
BEGIN
	----- These are variables ---------
	DECLARE @tmpStrLen int,
		@delimeterPosition int,
		@ProtocolID	int
				

	DECLARE	@ProtocolList TABLE (
			ProtocolID	int
			)

	
	--PRINT 'Exiting While Loop'



	SET	@ProtocolIdList = RTRIM(LTRIM(@ProtocolIdList))
	SET	@tmpStrLen=LEN(@ProtocolIdList)
	SET	@delimeterPosition = PATINDEX ( '%,%' , @ProtocolIdList) 
		
	--PRINT 'Entering While Loop'
	WHILE  (@delimeterPosition > 0 )
	BEGIN
		--There is a space
		SET 	@ProtocolID=CONVERT(int,RTRIM(LTRIM(SUBSTRING(@ProtocolIdList,1,@delimeterPosition-1))))
		IF NOT EXISTS (SELECT 1 FROM @ProtocolList WHERE ProtocolID=@ProtocolID)
			INSERT INTO @ProtocolList (ProtocolID)  VALUES (@ProtocolID)
			
		SET	@ProtocolIdList=RTRIM(LTRIM(SUBSTRING(@ProtocolIdList,@delimeterPosition+1 , @tmpStrLen-@delimeterPosition)))
		SET	@tmpStrLen=LEN(@ProtocolIdList)
		SET	@delimeterPosition = PATINDEX ( '%,%' , @ProtocolIdList)
	END
	IF NOT EXISTS (SELECT 1 FROM @ProtocolList WHERE ProtocolID=CONVERT(int,@ProtocolIdList))
		INSERT INTO @ProtocolList (ProtocolID)  VALUES (CONVERT(int,@ProtocolIdList))
	--PRINT 'Exiting While Loop'



		
	--This selects out the items in the cache, and puts them into the temp table so we
	--can get a subset of results.
	
	SELECT	P.ProtocolID, 
 		(CASE 	WHEN @Version= 2 THEN ISNULL(P.healthprofessionaltitle,P.patienttitle) 
			WHEN @version= 1 THEN ISNULL(P.patienttitle,P.HealthProfessionalTitle)
		END) AS	ProtocolTitle,
		(CASE 	WHEN @version= 2 AND P.HealthProfessionalTitle is not null THEN P.patienttitle
			WHEN @version= 1 AND P.PatientTitle is not null THEN P.HealthProfessionalTitle
			ELSE NULL
		END) AS	AlternateTitle,
 		p.TypeOfTrial,
		p.LowAge, 
		p.HighAge, 
		p.AgeRange, 
		p.SponsorOfTrial, 
		p.PrimaryProtocolID, 
		p.AlternateProtocolIDs,  
		p.CurrentStatus, 
		p.Phase,
		p.DateLastModified,
		p.DateFirstPublished, 
		case  p.isCTprotocol when 1 then 28 else 5 end as DocumentTypeid

	FROM 	dbo.ProtocolDetail AS P WITH (READUNCOMMITTED) 
	INNER JOIN @ProtocolList PL
		ON P.ProtocolID=PL.ProtocolID 

	
	
	

	
	

END


GO
