IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_Video_GetAll]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_Video_GetAll]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_Video_GetAll
@TotalResults int output
AS
BEGIN
	BEGIN TRY
		
		SELECT vi.VideoID as VideoID
			  ,vi.Title as Title
			  ,vi.ShortTitle as ShortTitle
			  ,vi.Description as Description
			  ,vp.PrettyURL as PrettyURL 			
			  ,vp.IsPrimary as IsPrimary 			 
			  ,vi.CreateUserID as CreateUserId
			  ,vi.CreateDate as CreateDate
			  ,vi.UpdateUserID as UpdateUserID
			  ,vi.UpdateDate as UpdateDate
		  FROM dbo.Video vi
		  JOIN dbo.VideoPrettyURL vp on vi.VideoID = vp.VideoID
		  Where vp.IsPrimary = 1 and vp.PrettyURL !=''

SET @TotalResults = @@ROWCOUNT

	END TRY

	BEGIN CATCH
		RETURN 10802
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_Video_GetAll] TO [websiteuser_role]
GO
