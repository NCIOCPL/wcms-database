IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_Node_Search]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_Node_Search]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

create PROCEDURE [dbo].Core_Node_Search
	@Title			varchar(255) = null,
	@Short			varchar(50) = null,
	@Description	varchar(1500) = null,
	@PrettyURL		varchar(1000)  = null,
	@SortOrder		int = null
AS

BEGIN
set nocount on 
		
		IF (@SortOrder is null)
			SET @SortOrder = 1

		SELECT 
			W.NodeID, 
			W.Title, 
			W.ShortTitle, 
			W.Description,
			P.PrettyURL,
			W.UpdateUserID, 
			W.UpdateDate			
		FROM dbo.Node W  
		Inner Join prettyurl P on W.NodeID = P.NodeID and P.IsPrimary =1	
		Where
			(@Title is null or len(@Title) =0 or W.Title like '%' + @Title +'%') And
			(@Short is null or len(@Short) =0 or W.ShortTitle like '%' + @Short +'%') And
			(@Description is null or len(@Description) =0 or W.Description like '%' + @Description +'%') And
			(@PrettyURL is null or len(@PrettyURL) =0 or P.PrettyURL like '%' + @PrettyURL +'%')
		Order by 
			CASE 
				WHEN @SortOrder = 1 THEN W.Title
				WHEN @SortOrder = 2 THEN W.ShortTitle
				WHEN @SortOrder = 3 THEN P.PrettyUrl
				WHEN @SortOrder = 4 THEN W.UpdateUserID
				ELSE W.Title
			END 

END

GO
GRANT EXECUTE ON [dbo].[Core_Node_Search] TO [websiteuser_role]
GO
