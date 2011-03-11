IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_GetRequestDataHistory]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_GetRequestDataHistory]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
-- =============================================
-- Author:		Vadim
-- Create date: 02/05/07
-- Description:	Get Haistory Data using Request Id
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetRequestDataHistory]
	@RequestDataID	int,
	@EntryType varchar(50) = NULL,
	@DebugType varchar(50) = NULL,
	@Status_Code int OUTPUT,
	@Status_Text	varchar(255) OUTPUT
AS
BEGIN
	BEGIN TRY
	SET NOCOUNT ON;
	SET @Status_Code = 0
	SET @Status_Text = 'OK'

	IF(@EntryType is NULL AND @DebugType is NULL)
	BEGIN
		SELECT d.RequestID, d.CDRID, EntryDateTime, Entry, b.BatchID, b.BatchName, EntryType
		FROM RequestDataHistory h
		INNER JOIN RequestData d
		ON d.RequestDataID = h.RequestDataID
		INNER JOIN Batch b
		ON b.BatchID = h.BatchID
		WHERE h.RequestDataID = @RequestDataID AND EntryType <> 'Debug'
		ORDER BY h.RequestDataHistoryID DESC
	END
	ELSE
		IF(@EntryType is NULL)
	BEGIN
		SELECT d.RequestID, d.CDRID, EntryDateTime, Entry, b.BatchID, b.BatchName, EntryType
		FROM RequestDataHistory h
		INNER JOIN RequestData d
		ON d.RequestDataID = h.RequestDataID
		INNER JOIN Batch b
		ON b.BatchID = h.BatchID
		WHERE h.RequestDataID = @RequestDataID
		ORDER BY h.RequestDataHistoryID DESC
	END
	ELSE
	BEGIN
		SELECT d.RequestID, d.CDRID, EntryDateTime, Entry, b.BatchID, b.BatchName, EntryType
		FROM RequestDataHistory h
		INNER JOIN RequestData d
		ON d.RequestDataID = h.RequestDataID
		INNER JOIN Batch b
		ON b.BatchID = h.BatchID
		WHERE h.RequestDataID = @RequestDataID and EntryType IN (ISNULL(@EntryType, ''), ISNULL(@DebugType, ''))
		ORDER BY h.RequestDataHistoryID DESC
	END
	END TRY

	BEGIN CATCH
		SET @Status_Code = -1000	-- Very big error
		SET @Status_Text = 'Exception thrown in usp_GetRequestDataHistory ' + ERROR_MESSAGE()
		RETURN 100101  --Error code
	END CATCH 

END


GO
GRANT EXECUTE ON [dbo].[usp_GetRequestDataHistory] TO [gatekeeper_role]
GO
