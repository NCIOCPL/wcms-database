IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_ProtocolSearchRefineCache]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_ProtocolSearchRefineCache]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- exec dbo.usp_ProtocolSearchRefineCache

/*	NCI - National Cancer Institute
*	
*	Purpose:	
*
*	Objects Used:
*
*	Change History:
*	1/15/2004 	Alex Pidlisnyy	Script Created
*	4/2/2004 	Alex Pidlisnyy	Change to use ProtocolSearchSysCache
*	10/27/2004      Lijia Chu	use delete instead of TRUNCATE.
*/


CREATE PROCEDURE dbo.usp_ProtocolSearchRefineCache
	(	
	@protocolSearchID int = NULL  	-- @protocolSearchID for which cache need to ne cleared
					-- if it is NULL than the whole cache will be cleared.
	)
with execute as owner
AS
BEGIN
	SET XACT_ABORT ON

	IF @protocolSearchID IS NULL
	BEGIN
		BEGIN TRAN
		UPDATE	protocolSearch WITH (ROWLOCK)
		SET	IsCachedSearchResultAvailable = 0,
			IsCachedContactsAvailable = 0
		FROM 	protocolSearch 
		WHERE 	IsCachedSearchResultAvailable = 1
		
		truncate table ProtocolSearchSysCache
		Truncate table  ProtocolSearchContactCache
		-- TRUNCATE TABLE dbo.ProtocolSearchResultViewCache

		COMMIT TRAN
	END
	ELSE 	
	BEGIN
		BEGIN TRAN
		UPDATE	ProtocolSearch WITH (ROWLOCK)
		SET	IsCachedSearchResultAvailable = 0,
			IsCachedContactsAvailable = 0
		FROM 	ProtocolSearch 
		WHERE 	ProtocolSearchID = @ProtocolSearchID
		
		DELETE FROM ProtocolSearchSysCache WITH (ROWLOCK)
		WHERE 	ProtocolSearchID = @ProtocolSearchID
		
		DELETE FROM dbo.ProtocolSearchContactCache WITH (ROWLOCK)
		WHERE 	ProtocolSearchID = @ProtocolSearchID
		
		-- DELETE FROM dbo.ProtocolSearchResultViewCache WITH (ROWLOCK)
		-- WHERE 	ProtocolSearchID = @ProtocolSearchID
		COMMIT TRAN
	END
END



GO
GRANT EXECUTE ON [dbo].[usp_ProtocolSearchRefineCache] TO [gatekeeper_role]
GO
