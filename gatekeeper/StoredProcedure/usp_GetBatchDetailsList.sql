IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_GetBatchDetailsList]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_GetBatchDetailsList]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[usp_GetBatchDetailsList]
	@Filter int,
	@Status_Code int OUTPUT,
	@Status_Text	varchar(255) OUTPUT
AS
BEGIN
	BEGIN TRY
	set nocount ON

		SET @Status_Code = 0
		SET @Status_Text = 'OK'

		-- Retrieve all.
		IF( @Filter = 0)
		BEGIN
			select p.ProcessQueueId, p.BatchID, BatchName, Status, UserName, EntryDate,
				(select top 1 rd.RequestId from RequestData rd
				inner join BatchRequestData brd on brd.RequestDataId = rd.RequestDataId
				and brd.BatchId = p.BatchId) as RequestId,

				(select count(*) from BatchRequestData brd 
				inner join RequestData rd2 on brd.RequestDataId = rd2.RequestDataId
				and rd2.status = 'Error'
				and brd.BatchId = p.BatchId) as ErrorCount,

				(select count(*) from BatchRequestData brd 
				inner join RequestData rd3 on brd.RequestDataId = rd3.RequestDataId
				and rd3.status = 'Warning'
				and brd.BatchId = p.BatchId) as WarningCount 
			from ProcessQueue p 
			inner join Batch b
			on b.BatchId = p.BatchId
			order by p.ProcessQueueID
		END

		-- Active Only (No Complete with Errors)
		ELSE IF( @Filter = 1)
		BEGIN
			select p.ProcessQueueId, p.BatchID, BatchName, Status, UserName, EntryDate,
				(select top 1 rd.RequestId from RequestData rd
				inner join BatchRequestData brd on brd.RequestDataId = rd.RequestDataId
				and brd.BatchId = p.BatchId) as RequestId,

				(select count(*) from BatchRequestData brd 
				inner join RequestData rd2 on brd.RequestDataId = rd2.RequestDataId
				and rd2.status = 'Error'
				and brd.BatchId = p.BatchId) as ErrorCount,

				(select count(*) from BatchRequestData brd 
				inner join RequestData rd3 on brd.RequestDataId = rd3.RequestDataId
				and rd3.status = 'Warning'
				and brd.BatchId = p.BatchId) as WarningCount 
			from ProcessQueue p 
			inner join Batch b
			on b.BatchId = p.BatchId
			where b.status <> 'CompleteWithErrors'
			order by p.ProcessQueueID

		END

		-- Errors Only (Complete with Errors)
		ELSE IF( @Filter = 2 )
		BEGIN
			select p.ProcessQueueId, p.BatchID, BatchName, Status, UserName, EntryDate,
				(select top 1 rd.RequestId from RequestData rd
				inner join BatchRequestData brd on brd.RequestDataId = rd.RequestDataId
				and brd.BatchId = p.BatchId) as RequestId,

				(select count(*) from BatchRequestData brd 
				inner join RequestData rd2 on brd.RequestDataId = rd2.RequestDataId
				and rd2.status = 'Error'
				and brd.BatchId = p.BatchId) as ErrorCount,

				(select count(*) from BatchRequestData brd 
				inner join RequestData rd3 on brd.RequestDataId = rd3.RequestDataId
				and rd3.status = 'Warning'
				and brd.BatchId = p.BatchId) as WarningCount
			from ProcessQueue p 
			inner join Batch b
			on b.BatchId = p.BatchId
			where b.status = 'CompleteWithErrors'
			order by p.ProcessQueueID
		END
		ELSE
			RAISERROR('usp_GetBatchList: Unknown Filter ID %d', 1, 1, @Filter )

		RETURN 0  --Succesful return 0
	END TRY

	BEGIN CATCH
		SET @Status_Code = -1000	-- Very big error
		SET @Status_Text = 'Exception thrown in usp_GetBatchList ' + ERROR_MESSAGE()
		RETURN 100101  --Error code
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[usp_GetBatchDetailsList] TO [gatekeeper_role]
GO
