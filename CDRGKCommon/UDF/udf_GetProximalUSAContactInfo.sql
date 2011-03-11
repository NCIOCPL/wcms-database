IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[udf_GetProximalUSAContactInfo]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[udf_GetProximalUSAContactInfo]
GO

/****** Object: User Defined Function dbo.udf_GetProximalZipCodes Script Date: 1/29/2003 2:01:50 PM ******/
/*************************************************************************************************************
* NCI - National Cancer Institute
* 
* Purpose: 
*
* Objects Used:
*
* Change History:
* 6/1/2003 	Alex Pidlisnyy 	Script Created
* 7/14/2003 	Alex Pidlisnyy 	Fix bug. Error for @ZIPProximity = 0
*
*************************************************************************************************************/

CREATE FUNCTION dbo.udf_GetProximalUSAContactInfo
(
	@ZIP varchar(10),
	@ZIPProximity int = 0,
	@IsActiveProtocol varchar(1) = 'Y'

)
RETURNS @ResultTable TABLE
(
	ProtocolContactInfoID int,
	ProtocolID int
)
AS

BEGIN

	IF NULLIF(@ZIPProximity, 0) > 0
	BEGIN
		-- proximity zips
		declare @RadiusConstant float,
			@ZIPLat float,
			@ZIPLong float,
			@minlong float,
			@maxlong float,
			@minlat float,
			@maxlat float,
			@zipcode char(5)
		
		--.00025277 is how many radians (lines of latitude/longitude) that
		--are in 1 statue mile. 1/60 of an arc degree is in a nauticle mile.
		--1 nm == 1.1508 statue miles.
		--degrees are: degrees * pi/180.
		--Soo.. 1nm= (1/60) * (pi/180)
		-- 1.1508= (1/60) * (pi/180)
		-- 1.1508/1.1508 = ((1/60) * (pi/180))/1.1508
		-- 1 = ((1/60) * (pi/180))/1.1508
		-- 1mi = .00025277 radians
		--(Just in case anyone wanted to know the math behind that)
		
		SET @RadiusConstant = @ZIPProximity * .00025277
		
		-- GET Information about provided ZIP Code
		SELECT 	TOP 1
			@ZIPLat = latitude, 
			@ZIPLong = longitude 
		FROM 	ZIPCodes WITH (READUNCOMMITTED)	
		WHERE 	ZIPCode = @ZIP

		IF 	(
			@ZIPLat IS NOT NULL
			AND 
			@ZIPLong IS NOT NULL
			)
		BEGIN
			select @minlong = @ziplong - @radiusconstant
			select @maxlong = @ziplong + @radiusconstant
			select @minlat = @ziplat - @radiusconstant
			select @maxlat = @ziplat + @radiusconstant
			
			-- Find out all existing ZIPs in proximity
			INSERT INTO @ResultTable (
				ProtocolContactInfoID,
				ProtocolID 
				)
			SELECT 	ProtocolContactInfoID,
				ProtocolID 
			FROM 	vwUSAProtocolTrialSite AS ZC WITH (READUNCOMMITTED)
				
			WHERE 	ZC.longitude > @minlong
				AND ZC.longitude < @maxlong
				AND ZC.latitude > @minlat
				AND ZC.latitude < @maxlat
			
		END
		-- ELSE we do not have any mutches 
	END
	ELSE BEGIN
		-- just ZIP 
		INSERT INTO @ResultTable (
			ProtocolContactInfoID,
			ProtocolID 
			)
		SELECT 	ProtocolContactInfoID,
			ProtocolID 
		FROM protocoltrialsite	 AS ZC WITH (READUNCOMMITTED)
		WHERE 	ZIP = @ZIP
			
	END 
RETURN 
END


GO
