IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_GetRequestCounts]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_GetRequestCounts]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
-- =============================================
-- Author:		Vadim
-- Create date: 04/13/2007, Friday
-- Description:	Counts different document types
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetRequestCounts] 
	@RequestID	int,
	@Status_Code int OUTPUT,
	@Status_Text	varchar(255) OUTPUT
AS
BEGIN
	BEGIN TRY
	set nocount ON

		SET @Status_Code = 0
		SET @Status_Text = 'OK'

		SELECT DataSetId, count(*) AS 'Counts'
		FROM requestdata
		WHERE RequestId = @RequestID
		GROUP BY DataSetId
		ORDER BY DataSetId

		RETURN 0  --Succesful return 0
	END TRY

	BEGIN CATCH
		SET @Status_Code = -1000	-- Very big error
		SET @Status_Text = 'Exception thrown in usp_GetRequestDataIDList ' + ERROR_MESSAGE()
		RETURN 100101  --Error code
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[usp_GetRequestCounts] TO [gatekeeper_role]
GO
