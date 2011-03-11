IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_GetBatchHistory]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_GetBatchHistory]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
-- =============================================
-- Author:		<Vadim>
-- Create date: <02/28/07>
-- Description:	<Get Batch History Data and Batch Action Data>
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetBatchHistory]
	-- Add the parameters for the stored procedure here
	@BatchID int, 
	@Status_Code int OUTPUT,
	@Status_Text	varchar(255) OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	BEGIN TRY
	SET NOCOUNT ON;
		SELECT pa.Name Action, ba.CompletionDate FROM ProcessAction pa
		inner join BatchAction ba
		ON pa.ProcessActionID = ba.ProcessActionID
		WHERE ba.BatchID = @BatchID	

		SELECT Entry, EntryDateTime, UserName
		FROM BatchHistory
		WHERE BatchID = @BatchID

	END TRY
	BEGIN CATCH
		SET @Status_Code = -1000	-- Very big error
		SET @Status_Text = 'Exception thrown usp_GetRequestBatchHistory in  ' + ERROR_MESSAGE()
		RETURN 100101  --Error code
	END CATCH 

END

GO
GRANT EXECUTE ON [dbo].[usp_GetBatchHistory] TO [gatekeeper_role]
GO
