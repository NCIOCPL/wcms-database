
/****** Object:  User Defined Function dbo.udf_GetProtocolSponsors    Script Date: 7/5/2006 4:21:13 PM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[udf_GetProtocolSponsors]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[udf_GetProtocolSponsors]
GO


/****** Object:  User Defined Function dbo.udf_GetProtocolSponsors    Script Date: 11/26/2002 12:36:32 PM ******/
/*	NCI - National Cancer Institute
*	
*	Purpose:	
*
*	Objects Used:
*
*	Change History:
*/

CREATE FUNCTION [dbo].[udf_GetProtocolSponsors] 
	( 
	@ProtocolID int
	)  
RETURNS varchar(8000) 
AS  
BEGIN  
	-- SELECT distinct SponsorName FROM 	ProtocolSponsors
	-- SELECT * FROM 	ProtocolAlternateID where IDType is null
	-- select dbo.udf_GetProtocolSponsors (63303)

	DECLARE @SponsorList varchar(8000),
		@tmpStr varchar(1000)

	DECLARE  CursorProtocolSponsor CURSOR
	FOR 	SELECT 	distinct 
			LTRIM(RTRIM( SponsorName ))
		FROM 	dbo.ProtocolSponsors ps inner join dbo.sponsor s on ps.sponsorid  = s.sponsorid
		WHERE 	ProtocolID = @ProtocolID

	OPEN CursorProtocolSponsor
	FETCH NEXT FROM CursorProtocolSponsor 	INTO @tmpStr 

	SELECT @SponsorList = NULL --LTRIM(RTRIM(@tmpStr))
	
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SELECT @SponsorList = ISNULL( @SponsorList + ',  ',  '') + LTRIM(RTRIM(@tmpStr))
		FETCH NEXT FROM CursorProtocolSponsor 	INTO @tmpStr 
	END

	CLOSE CursorProtocolSponsor
	DEALLOCATE CursorProtocolSponsor

	RETURN @SponsorList 
END








GO


