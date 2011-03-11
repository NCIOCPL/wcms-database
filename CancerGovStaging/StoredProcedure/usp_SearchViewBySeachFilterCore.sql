IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_SearchViewBySeachFilterCore]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_SearchViewBySeachFilterCore]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/**********************************************************************************

	Object's name:	usp_SearchViewBySeachFilterCore
	Object's type:	Stored procedure
	Purpose:	Return NCIViews and their Properties Based on SearchFilter or date
	Author:		Lijia Chu	08/13/04		
	Change History: Lijia Chu	02/15/05 SCR972

**********************************************************************************/

CREATE PROCEDURE dbo.usp_SearchViewBySeachFilterCore (
	@MaxResults integer,
	@IsSpanish varchar(20),
	@MaxDate datetime = NULL,
	@MinDate datetime = NULL,
	@SearchFilter varchar(1000),
	@NotSearchFilter varchar(1000),
	@SortFilter int	=NULL,
	@SortDate int	=NULL
)
 AS

DECLARE	@ViewIDTable TABLE  (
	NCIViewID	uniqueidentifier
	)
BEGIN
	IF @MaxDate IS NOT NULL OR @MinDate IS NOT NULL
	BEGIN
		IF  ISDATE(@MaxDate)=0
			SET	@MaxDate=GETDATE()

		IF ISDATE(@MinDate)=0
			SET	@MinDate=CONVERT(datetime,'1/1/1970')
	END


	IF @MaxResults > 0
		SET ROWCOUNT @MaxResults

	IF @IsSpanish = 'Yes'
	Begin
		INSERT INTO @ViewIDTable (NCIViewID)
		SELECT	NCIViewID
		FROM	vw_SpanishSearchFilterView 
		WHERE	(@SearchFilter IS NULL	OR
		  	@SearchFilter = ''	OR
		  	(@SearchFilter IS NOT NULL AND	@SearchFilter <> '' AND	SearchFilter IS NOT NULL AND SearchFilter like '%'+@SearchFilter+'%'))
		  AND	(@NotSearchFilter IS NULL OR
			 @NotSearchFilter=''      OR
			(@NotSearchFilter IS NOT NULL AND @NotSearchFilter <> '' AND SearchFilter IS NOT NULL AND SearchFilter NOT like '%'+ @NotSearchFilter + '%'))
		  AND	((@MaxDate IS NULL AND @MinDate IS NULL) OR (Date < @MaxDate AND Date >= @MinDate))
		ORDER BY 
			CASE WHEN @sortFilter = 1 and (@sortDate  =1 or @sortDate is NULL) THEN date
				 WHEN @sortFilter = 1 and @sortDate  =2 THEN PostedDate
				 WHEN @sortFilter = 1 and @sortDate  =3 THEN ReleaseDate
			END,	
			CASE WHEN (@sortFilter = 2 OR @SortFilter IS NULL) and (@sortDate  =1 or @sortDate is NULL) THEN date
				 WHEN (@sortFilter = 2 OR @SortFilter IS NULL) and @sortDate  =2 THEN PostedDate
				 WHEN (@sortFilter = 2 OR @SortFilter IS NULL) and @sortDate  =3 THEN ReleaseDate
			END desc,
				CASE WHEN @sortFilter = 3  THEN Title
			END, 
				CASE WHEN @sortFilter = 4 THEN Title 
			END desc
					
			

		SELECT	*
		FROM	vw_SpanishSearchFilterView 
		WHERE	nciviewid in (select nciviewid from @viewIDTable)
		ORDER BY 
			CASE WHEN @sortFilter = 1 and (@sortDate  =1 or @sortDate is NULL) THEN date
				 WHEN @sortFilter = 1 and @sortDate  =2 THEN PostedDate
				 WHEN @sortFilter = 1 and @sortDate  =3 THEN ReleaseDate
			END,	
			CASE WHEN (@sortFilter = 2 OR @SortFilter IS NULL) and (@sortDate  =1 or @sortDate is NULL) THEN date
				 WHEN (@sortFilter = 2 OR @SortFilter IS NULL) and @sortDate  =2 THEN PostedDate
				 WHEN (@sortFilter = 2 OR @SortFilter IS NULL) and @sortDate  =3 THEN ReleaseDate
			END desc,
				CASE WHEN @sortFilter = 3  THEN Title
			END, 
				CASE WHEN @sortFilter = 4 THEN Title 
			END desc
				
				
		

	END
	ELSE
	Begin
		INSERT INTO @ViewIDTable (NCIViewID)
		SELECT	NCIViewID
		FROM	vw_EnglishSearchFilterView 
		WHERE	(@SearchFilter IS NULL	OR
		  	@SearchFilter = ''	OR
		  	(@SearchFilter IS NOT NULL AND	@SearchFilter <> '' AND	SearchFilter IS NOT NULL AND SearchFilter like '%'+@SearchFilter+'%'))
		  AND	(@NotSearchFilter IS NULL OR
			 @NotSearchFilter=''      OR
			(@NotSearchFilter IS NOT NULL AND @NotSearchFilter <> '' AND SearchFilter IS NOT NULL AND SearchFilter NOT like '%'+ @NotSearchFilter + '%'))
		  AND	((@MaxDate IS NULL AND @MinDate IS NULL) OR (Date < @MaxDate AND Date >= @MinDate))
		ORDER BY 			
			CASE WHEN @sortFilter = 1 and (@sortDate  =1 or @sortDate is NULL) THEN date
				 WHEN @sortFilter = 1 and @sortDate  =2 THEN PostedDate
				 WHEN @sortFilter = 1 and @sortDate  =3 THEN ReleaseDate
			END,	
			CASE WHEN (@sortFilter = 2 OR @SortFilter IS NULL) and (@sortDate  =1 or @sortDate is NULL) THEN date
				 WHEN (@sortFilter = 2 OR @SortFilter IS NULL) and @sortDate  =2 THEN PostedDate
				 WHEN (@sortFilter = 2 OR @SortFilter IS NULL) and @sortDate  =3 THEN ReleaseDate
			END desc,
				CASE WHEN @sortFilter = 3  THEN Title
			END, 
				CASE WHEN @sortFilter = 4 THEN Title 
			END desc
					
		
		SELECT	*
		FROM	vw_EnglishSearchFilterView
		WHERE	nciviewid in (select nciviewid from @viewIDTable)
		ORDER BY 
			CASE WHEN @sortFilter = 1 and (@sortDate  =1 or @sortDate is NULL) THEN date
				 WHEN @sortFilter = 1 and @sortDate  =2 THEN PostedDate
				 WHEN @sortFilter = 1 and @sortDate  =3 THEN ReleaseDate
			END,	
			CASE WHEN (@sortFilter = 2 OR @SortFilter IS NULL) and (@sortDate  =1 or @sortDate is NULL) THEN date
				 WHEN (@sortFilter = 2 OR @SortFilter IS NULL) and @sortDate  =2 THEN PostedDate
				 WHEN (@sortFilter = 2 OR @SortFilter IS NULL) and @sortDate  =3 THEN ReleaseDate
			END desc,
				CASE WHEN @sortFilter = 3  THEN Title
			END, 
				CASE WHEN @sortFilter = 4 THEN Title 
			END desc
					
	END

	SET ROWCOUNT 0

	SELECT	vp.NCIViewID, vp.PropertyName, vp.PropertyValue
	FROM	ViewProperty vp
	JOIN 	@ViewIDTable V
	ON	v.NCIViewID = vp.NCIViewID
	
END



GO
