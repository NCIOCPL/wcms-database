IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_SearchViewByDate]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_SearchViewByDate]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/**********************************************************************************

	Object's name:	usp_SearchViewByDate
	Object's type:	Stored procedure
	Purpose:	Return NCIViews and their Properties Based on SearchFilter and date
	Author:		Lijia Chu	08/13/04		
	Change History: Lijia Chu	02/15/05 SCR972

**********************************************************************************/

CREATE PROCEDURE dbo.usp_SearchViewByDate (
	@MaxResults integer,
	@IsSpanish varchar(20),
	@MaxDate datetime,
	@MinDate datetime,
	@SearchFilter varchar(1000),
	@NotSearchFilter varchar(1000),
	@SortFilter int	=NULL,	--1: Sort by date Asc 2: Sort by date desc 3: Sort by title Asc 4: Sort by title desc
	@SortDate int	=NULL)
 AS
BEGIN
	
	EXEC dbo.usp_SearchViewBySeachFilterCore @MaxResults,@IsSpanish,@MaxDate,@MinDate,@SearchFilter,@NotSearchFilter,@SortFilter, @SortDate
	
END



GO
GRANT EXECUTE ON [dbo].[usp_SearchViewByDate] TO [websiteuser_role]
GO
