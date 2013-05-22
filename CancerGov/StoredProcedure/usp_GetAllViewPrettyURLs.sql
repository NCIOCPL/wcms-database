SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].usp_GetAllViewPrettyURLs') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].usp_GetAllViewPrettyURLs
GO

CREATE  PROCEDURE [dbo].usp_GetAllViewPrettyURLs
AS
BEGIN
	BEGIN TRY
		
		SELECT 
			  p.[NCIViewID]
			  ,[RealURL]
			  ,[CurrentURL] as [PrettyURL]
			  ,(
						SELECT PropertyValue 
						FROM ViewProperty  
					WHERE [NCIViewID] = p.[NCIViewID] and PropertyName = 'RedirectUrl'
					  ) as RedirectUrl
		  FROM [dbo].[PrettyURL] p , NCIView v 
		WHERE p.NCIViewID = v.NCIViewID 
		AND v.NCITemplateID != 'FFF2D734-6A7A-46F0-AF38-DA69C8749AD0' 
	
	

	END TRY

	BEGIN CATCH
		RETURN 10802
	END CATCH 
END
GO

GRANT EXECUTE ON [dbo].usp_GetAllViewPrettyURLs TO websiteuser_role

GO

