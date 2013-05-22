/****** Object:  User Defined Function dbo.udf_GetProtocolAlternateIDs    Script Date: 7/5/2006 4:21:13 PM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[udf_GetProtocolAlternateIDs]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[udf_GetProtocolAlternateIDs]
GO
/****** Object:  User Defined Function dbo.udf_GetProtocolAlternateIDs    Script Date: 11/26/2002 12:36:32 PM ******/
/*	NCI - National Cancer Institute
*	
*	Purpose:	
*
*	Objects Used:
*
*	Change History:
*	
*/

CREATE FUNCTION [dbo].[udf_GetProtocolAlternateIDs] 
	( 
	@ProtocolID int
	)  
RETURNS varchar(500) 
AS  
BEGIN 
	
	DECLARE @AlternateID varchar(1000),
		@tmpStr varchar(1000)

	DECLARE  cursorProtocolAlternateID CURSOR
	FOR 	SELECT 	LTRIM(RTRIM( IDString ))	
		FROM 	dbo.ProtocolAlternateID
		WHERE 	ProtocolID = @ProtocolID
				and IDTypeID <> 1
			--AND IDType NOT IN ('GUID', 'CDRKey', 'PDQKey', 'Primary')

	OPEN CursorProtocolAlternateID
	FETCH NEXT FROM CursorProtocolAlternateID 	INTO @tmpStr 

	SELECT @AlternateID = NULL --LTRIM(RTRIM(@tmpStr))
	
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SELECT @AlternateID = ISNULL(@AlternateID + ',  ',  '') + LTRIM(RTRIM(@tmpStr))
		FETCH NEXT FROM CursorProtocolAlternateID 	INTO @tmpStr 
	END

	CLOSE CursorProtocolAlternateID
	DEALLOCATE CursorProtocolAlternateID

	RETURN @AlternateID

END

GO


