IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_Video_Get]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_Video_Get]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_Video_Get
	@VideoID uniqueidentifier
AS
BEGIN
	BEGIN TRY

			SELECT vi.VideoID
			  ,vi.Title
			  ,vi.ShortTitle
			  ,vi.Description
			  ,vp.PrettyURL			
			  ,vp.IsPrimary
			  ,vi.CreateUserID
			  ,vi.CreateDate
			  ,vi.UpdateUserID
			  ,vi.UpdateDate
		  FROM dbo.Video vi
		  JOIN dbo.VideoPrettyURL vp on vi.VideoID = vp.VideoID
		  Where vi.VideoID = @VideoID
		
	END TRY

	BEGIN CATCH
		RETURN 10801
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_Video_Get] TO [websiteuser_role]
GO
