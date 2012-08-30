IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_VideoPrettyURL_GetPrimary]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_VideoPrettyURL_GetPrimary]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_VideoPrettyURL_GetPrimary
	@VideoID uniqueidentifier
AS
BEGIN
	BEGIN TRY
		
	SELECT VideoID,
		   VideoPrettyURLID,
		   PrettyURL,
		   RealURL,
		   IsPrimary,
		   CreateDate,
		   CreateUserID,
		   UpdateDate,	
		   UpdateUserID
				FROM dbo.VideoPrettyURL		
				WHERE VideoID = @VideoID and IsPrimary = 1

	END TRY

	BEGIN CATCH
		RETURN 10802
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_VideoPrettyURL_GetPrimary] TO [websiteuser_role]
GO
