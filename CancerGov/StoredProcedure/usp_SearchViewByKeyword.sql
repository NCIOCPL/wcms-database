IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_SearchViewByKeyword]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_SearchViewByKeyword]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/**********************************************************************************

	Object's name:	usp_SearchViewByKeyword
	Object's type:	Stored procedure
	Purpose:	Return NCIViews and their Properties Based on SearchFilter and KeyWord
	Author:		
	Modified by:    Lijia Chu 08/13/04		
	Change History: Lijia Chu	02/15/05 SCR972

**********************************************************************************/

CREATE PROCEDURE dbo.usp_SearchViewByKeyword (
	@MaxResults integer,
	@IsSpanish varchar(20),
	@Keywords varchar(2000),  
	@SearchFilter varchar(1000),
	@NotSearchFilter varchar(1000),
	@SortFilter int	=NULL,	--1: Sort by date Asc 2: Sort by date desc 3: Sort by title Asc 4: Sort by title desc
	@SortDate int	=NULL
)
AS
BEGIN
	EXEC dbo.usp_SearchViewByKeywordCore @MaxResults,@IsSpanish,@Keywords,NULL,NULL,@SearchFilter,@NotSearchFilter,@SortFilter, @SortDate
	
END



GO
GRANT EXECUTE ON [dbo].[usp_SearchViewByKeyword] TO [websiteuser_role]
GO
