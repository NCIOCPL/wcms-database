IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[udf_GetProtocolAlternateIDs]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[udf_GetProtocolAlternateIDs]
GO
/******************************************
Function return Alternate protocol IDs for given ProtocolID
******************************************/
CREATE FUNCTION [dbo].[udf_GetProtocolAlternateIDs] 
	( 
	@ProtocolID uniqueidentifier
	)  
RETURNS varchar(256) 
AS  

BEGIN 

	DECLARE @AlternateID varchar(256),
		@tmpStr varchar(256)

	DECLARE  cursorProtocolAlternateID CURSOR
	FOR 	SELECT 	AlternateID		--PDQ field ID
		FROM 		ProtocolAlternateID
		WHERE 	ProtocolID = @ProtocolID

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
