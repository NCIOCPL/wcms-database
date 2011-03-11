SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].usp_GetProtocolOldAndAlternateIDs') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].usp_GetProtocolOldAndAlternateIDs
GO

CREATE  PROCEDURE [dbo].usp_GetProtocolOldAndAlternateIDs
AS
BEGIN
	BEGIN TRY

		-- As a "Nice to have", it would be good to modify these queries
		-- to return PrettyUrlID instead of OldID.  This requires a
		-- matching change in CDRPrettyUrlProvider.GetSubPagesInfosFromList()
		-- in the section currently marked as being related to the 
		-- "old primary protocolID and Add alternate protocolID".
		SELECT ProtocolID, PrimaryPrettyUrlID as OldID
			FROM protocolDetail
			where PrimaryPrettyUrlID is not null
		union all
		SELECT ProtocolID, IDString as OldID
			FROM ProtocolSecondaryUrl

	END TRY

	BEGIN CATCH
		RETURN 10803
	END CATCH 
END
GO

GRANT EXECUTE ON [dbo].usp_GetProtocolOldAndAlternateIDs TO websiteuser_role

GO

