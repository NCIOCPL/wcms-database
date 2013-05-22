IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_SearchViewByKeywordCore]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_SearchViewByKeywordCore]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/**********************************************************************************

	Object's name:	usp_SearchViewByKeywordCore
	Object's type:	Stored procedure
	Purpose:	Return NCIViews and their Properties Based on SearchFilter and KeyWord
	Author:		Lijia Chu 08/13/04
	Change History: Lijia Chu	02/15/05 SCR972
					Min Gao		3/1/2007

**********************************************************************************/
CREATE PROCEDURE dbo.usp_SearchViewByKeywordCore (
	@MaxResults integer,
	@IsSpanish varchar(20),
	@Keywords varchar(2000) = NULL,  
	@MaxDate datetime = NULL,
	@MinDate datetime = NULL,
	@SearchFilter varchar(1000),
	@NotSearchFilter varchar(1000),
	@SortFilter int	=NULL,
	@SortDate int	=NULL
)
AS
BEGIN
	IF @Keywords IS NULL OR LEN(RTRIM(LTRIM(@Keywords)))=0
	BEGIN
		-- Do not need to use dynamic stored procedure
		IF @MaxDate IS NULL AND @MinDate IS NULL
			EXEC dbo.usp_SearchViewBySeachFilterCore @MaxResults,@IsSpanish,NULL,NULL,@SearchFilter,@NotSearchFilter,@SortFilter, @sortDate
		ELSE
			EXEC dbo.usp_SearchViewBySeachFilterCore @MaxResults,@IsSpanish,@MaxDate,@MinDate,@SearchFilter,@NotSearchFilter,@SortFilter, @sortDate		
	END
	ELSE
	BEGIN

		--Declarations 
		DECLARE	@selectstr NVARCHAR(4000),
			@whereclausestr NVARCHAR(3000),
			@keywordselect varchar(3000),
			@delimeterPosition  int,
			@tmpStr varchar(2000) ,
			@tmpStrLen int,
			@IsSpanishSelect varchar(1000),
          		@MaxResultsText varchar(100),
			@SearchFilterClause varchar(2000),
			@TableName varchar(100)

		IF @MaxDate IS NOT NULL OR @MinDate IS NOT NULL
		BEGIN
			IF  ISDATE(@MaxDate)=0
				SET	@MaxDate=GETDATE()

			IF ISDATE(@MinDate)=0
				SET	@MinDate=CONVERT(datetime,'1/1/1970')
		END

		IF ISNUMERIC(@MaxResults)=0
		BEGIN
			SET	@MaxResults=0
		END

		IF NOT (UPPER(@IsSpanish)='YES' OR UPPER(@IsSpanish)='NO')
		BEGIN
			SET	@IsSpanish='NO'
		END

		--Get a list of keywords in the form of 
		--AND MetaKeywords like '%KW%' 

		SET	@tmpStr = RTRIM(LTRIM(@Keywords))
		SET	@keywordselect=''
		SET	@tmpStrLen=LEN(@tmpStr)
		SET	@delimeterPosition = CHARINDEX ( ' ', @tmpStr) 
		
		--PRINT 'Entering While Loop'
		WHILE  (@delimeterPosition > 0 )
		BEGIN
			--There is a space
			if @IsSpanish = 'YES'
				SET	@keywordselect=@keywordselect+'MetaKeyword collate modern_spanish_CI_AI like ''%' + LEFT(@tmpStr , @delimeterPosition - 1) + '%'''+CHAR(13)
			else
				SET	@keywordselect=@keywordselect+'MetaKeyword like ''%' + LEFT(@tmpStr , @delimeterPosition - 1) + '%'''+CHAR(13)
			

			SET	@tmpStr=RTRIM(LTRIM(SUBSTRING(@tmpStr,@delimeterPosition, @tmpStrLen-@delimeterPosition+1)))
			SET	@tmpStrLen=LEN(@tmpStr)
			--PRINT   @tmpStr
			--PRINT   @tmpStrLen
			SET	@delimeterPosition = CHARINDEX ( ' ', @tmpStr) 
			SET	@keywordselect=@keywordselect+'OR '
			--PRINT   @delimeterPosition 
		END
				
		if @IsSpanish = 'YES'
			SET	@keywordselect=@keywordselect+'MetaKeyword  collate modern_spanish_CI_AI  like ''%' + @tmpStr + '%'''
		else
			SET	@keywordselect=@keywordselect+'MetaKeyword like ''%' + @tmpStr + '%'''
		--PRINT 'Exiting While Loop'

		IF @IsSpanish = 'Yes'
		BEGIN
			SET	@TableName = 'vw_SpanishSearchFilterView'
		END
		ELSE
		BEGIN
			SET 	@TableName = 'vw_EnglishSearchFilterView'
		END

		IF @MaxResults > 0
			SET	@MaxResultsText='TOP ' + convert(varchar, @MaxResults)
		ELSE
			SET 	@MaxResultsText=' '


		SET	@selectstr= N'DECLARE @NCIViewIDList Table ('+CHAR(13)
		SET	@selectstr = @selectstr+N' ResultNumber int identity(1,1),'+CHAR(13)
		SET	@selectstr = @selectstr+N' NCIViewID	uniqueidentifier)'+CHAR(13)
		SET	@selectstr = @selectstr+N'INSERT INTO @NCIViewIDList (NCIViewID)'+CHAR(13)
		SET	@selectstr = @selectstr + N'SELECT '+@MaxResultsText+' NCIViewID'+CHAR(13)
		SET 	@selectstr =@selectstr+N'FROM '+ @TableName +CHAR(13)


		SET 	@whereclausestr =N'WHERE ('+ @keywordselect + N')'+CHAR(13)


		IF (@SearchFilter IS NOT NULL) AND (@SearchFilter <> '')
			SET	@whereclausestr = @whereclausestr +N'AND SearchFilter like ''%' + @SearchFilter + N'%'' AND SearchFilter is not NULL'+CHAR(13)
	
		IF (@NotSearchFilter IS NOT NULL) AND (@NotSearchFilter <> '')
			SET	@whereclausestr = @whereclausestr +N'AND SearchFilter NOT like ''%' + @NotSearchFilter + N'%'''+CHAR(13)
	

		IF @MaxDate IS NOT NULL OR @MinDate IS NOT NULL
		BEGIN
			SET	@whereclausestr = @whereclausestr +N'AND Date < @MaxDate'+CHAR(13)
			SET	@whereclausestr = @whereclausestr +N'AND Date >=@MinDate'+CHAR(13)
		END
		
		--IF	@SortFilter=2 OR @SortFilter IS NULL
		--	SET	@whereclausestr = @whereclausestr +N'Order by Date desc'

		--IF	@SortFilter=1
		--	SET	@whereclausestr = @whereclausestr +N'Order by Date asc'
		
		IF	@SortFilter=2 OR @SortFilter IS NULL
		BEGIN
			if @SortDate = 1 OR @SortDate is null
				SET	@whereclausestr = @whereclausestr +N'Order by Date desc'
			if @SortDate = 2 
				SET	@whereclausestr = @whereclausestr +N'Order by convert(datetime, PostedDate) desc'
			if @SortDate = 3 
				SET	@whereclausestr = @whereclausestr +N'Order by convert(datetime, ReleaseDate) desc'			
		END

		IF	@SortFilter=1
		BEGIN
			if @SortDate = 1 OR @SortDate is null
				SET	@whereclausestr = @whereclausestr +N'Order by Date asc'
			if @SortDate = 2 
				SET	@whereclausestr = @whereclausestr +N'Order by convert(datetime,PostedDate) asc'
			if @SortDate = 3 
				SET	@whereclausestr = @whereclausestr +N'Order by convert(datetime, ReleaseDate) asc'			
		END

		IF	@SortFilter=4
			SET	@whereclausestr = @whereclausestr +N'Order by title desc'

		IF	@SortFilter=3
			SET	@whereclausestr = @whereclausestr +N'Order by title asc'

		SET 	@selectstr =@selectstr+@whereclausestr+CHAR(13)


		SET	@selectstr = @selectstr+N'SELECT v.*'+CHAR(13)
		SET	@selectstr = @selectstr+N'FROM '+ @TableName+ ' V'+CHAR(13)
		SET	@selectstr = @selectstr+N'JOIN @NCIViewIDList T'+CHAR(13)
		SET	@selectstr = @selectstr+N'  ON V.NCIViewID=T.NCIViewID'+CHAR(13)
		SET	@selectstr = @selectstr+N'ORDER BY ResultNumber'+CHAR(13)


		SET	@selectstr = @selectstr+ N'SELECT vp.NCIViewID, vp.PropertyName, vp.PropertyValue'+CHAR(13)
		SET	@selectstr = @selectstr+ N'FROM ViewProperty vp'+CHAR(13)
		SET 	@selectstr = @selectstr+ N'JOIN @NCIViewIDList T'+CHAR(13)
		SET 	@selectstr = @selectstr+ N'  ON t.NCIViewID = vp.NCIViewID'+CHAR(13)

		print @selectstr

		IF  @MaxDate IS NOT NULL OR @MinDate IS NOT NULL
			EXEC sp_executesql @selectstr,
					   N'@MaxDate datetime,@MinDate datetime',
					   @MaxDate,
					   @MinDate
		ELSE
			EXEC sp_executesql @selectstr

		
	END
END




GO
