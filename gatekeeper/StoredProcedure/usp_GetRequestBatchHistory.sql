IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_GetRequestBatchHistory]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_GetRequestBatchHistory]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

-- =============================================
-- Author:		Vadim
-- Create date: 03/7/07
-- Description:	Get Batch info for a specific Request ID
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetRequestBatchHistory] 
	@RequestID int, 
	@Status_Code int OUTPUT,
	@Status_Text	varchar(255) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
/* Alternative version
SELECT b.BatchID, b.BatchName, b.Status, b.UserName, b.EntryDate
SELECT *
FROM BatchRequestData brd
INNER JOIN RequestData rd
ON brd.RequestDataID = rd.RequestDataID
INNER JOIN Batch b
ON brd.BatchID = b.BatchID
WHERE rd.RequestID = @RequestID
GROUP BY b.BatchID, b.BatchName, b.Status, b.UserName, b.EntryDate
order by b.BatchID
*/
		SELECT b.BatchID, b.BatchName, b.Status, b.UserName, b.EntryDate
		FROM BatchRequestData brd
		INNER JOIN Batch b
		ON brd.BatchID = b.BatchID
		WHERE brd.RequestID = @RequestID
		GROUP BY b.BatchID, b.BatchName, b.Status, b.UserName, b.EntryDate
		ORDER BY b.BatchID DESC
	END TRY

	BEGIN CATCH
		SET @Status_Code = -1000	-- Very big error
		SET @Status_Text = 'Exception thrown usp_GetRequestBatchHistory in  ' + ERROR_MESSAGE()
		RETURN 100101  --Error code
	END CATCH 
END


GO
GRANT EXECUTE ON [dbo].[usp_GetRequestBatchHistory] TO [gatekeeper_role]
GO
