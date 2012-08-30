IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_VideoPrettyURL_Get]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_VideoPrettyURL_Get]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_VideoPrettyURL_Get
	@VideoPrettyURLID uniqueidentifier
AS
BEGIN
	BEGIN TRY

		SELECT VideoID
			  ,VideoPrettyURLID			  
			  ,PrettyURL
			  ,RealURL
			  ,IsPrimary
			  ,CreateUserID
			  ,CreateDate
			  ,UpdateUserID
			  ,UpdateDate
		  FROM dbo.VideoPrettyURL		  
		  Where VideoPrettyURLID = @VideoPrettyURLID
		
	END TRY

	BEGIN CATCH
		RETURN 10801
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_VideoPrettyURL_Get] TO [websiteuser_role]
GO
