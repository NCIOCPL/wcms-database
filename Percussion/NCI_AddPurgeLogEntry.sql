IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[NCI_AddPurgeLogEntry]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[NCI_AddPurgeLogEntry]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].NCI_AddPurgeLogEntry
	@PurgedContentID	int,		-- Percussion ID of the content item being purged.
	@itemTitle			nchar(255),	-- sys_title of the content item being purged.
	@purgeBy			varchar(50),-- Userid performing the purge
	@workflowState		varchar(50)	-- Workflow state at time of purge.
AS
BEGIN
--	BEGIN TRY
	set nocount ON

		insert into nci_purgelog(contentid,
					purgeDate,
					itemTitle,
					purgeBy,
					workflowState)
		values( @PurgedContentID,
				getdate(),
				@itemTitle,
				@purgeBy,
				@workflowState)

		RETURN 0  --Succesful return 0
--	END TRY

--	BEGIN CATCH
--	END CATCH 
END


GO
GRANT EXECUTE ON [dbo].[NCI_AddPurgeLogEntry] TO [PercussionUser]
GO
