IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_SearchPDQ]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_SearchPDQ]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.usp_RetrieveNCIView  
* Owner:Jhe 
* Purpose: For admin side Script Date: 10/07/2003 16:00:49 pm ******/


CREATE PROCEDURE [dbo].[usp_SearchPDQ] 
	(
	@AudienceSelected		VarChar(10),
	@Title				VarChar(255),
	@SummaryID			VarChar(10),
	@XML				VarChar(1500),
	@Language			VarChar(50),
	@Type				VarChar(50),
	@TitleSelected			VarChar(10),
	@SummaryIDSelected		VarChar(10),
	@XMLSelected			VarChar(10),
	@TypeSelected			VarChar(10)
)
AS
BEGIN	
	Declare @Sql 		varchar(2000),
		@tmpLogical	varchar(20),
		@count 		int


	select 	@Title 			= REPLACE(@Title,'''',''''''),
		@XML			= REPLACE(@XML,'''',''''''),
		@SummaryID		= REPLACE(@SummaryID,'''','''''')
	
	if (@AudienceSelected = 'HP')
	BEGIN
		select @Sql = 'SELECT DocumentGUID, DocumentID, Title, Type, Audience =''HP'', Language from vw_summaryhealthprofessional where 1=1 '
	END
	ELSE
	BEGIN
		select @Sql = 'SELECT DocumentGUID, DocumentID, Title, Type, Audience =''Patient'', Language from vw_summarypatient where  1=1  '
	END		


	if 	(len(@Title) > 0
		or len(@XML)> 0 
		or len(@SummaryID) > 0
		or len(@Language) > 0
		or len(@Type) > 0
		)
	BEGIN
		
		select @tmpLogical = ''
		select @sql =  @sql + ' and ('
		

		IF (len(@Title) > 0)
		BEGIN
			select @sql = @sql + ' Title LIKE  ''%' + @Title + '%'' ' 	
			select @tmpLogical = @TitleSelected
		END
			
		if (len(@XML)> 0 )
		BEGIN
			select @sql = @sql + @tmpLogical + ' XML LIKE ''%' + @XML + '%'' '	
			select @tmpLogical = @XMLSelected		
		END
		
		IF (len(@SummaryID) > 0)
		BEGIN
			select @sql = @sql + @tmpLogical + ' DocumentID =  ''' +  @SummaryID  + ''' '
			select @tmpLogical = @SummaryIDSelected		
		END

		IF (len(@Type) > 0)
		BEGIN
			select @sql = @sql + @tmpLogical + ' Type =  ''' +  @Type  + ''' '
			select @tmpLogical = @TypeSelected				
		END

		IF (len(@Language) > 0)
		BEGIN
			select @sql = @sql + @tmpLogical + ' Language=  ''' +  @Language  + ''' '
		END

		select @sql = @sql + ' ) '
	END
	
	PRINT @sql

	execute (@sql)
END

GO
GRANT EXECUTE ON [dbo].[usp_SearchPDQ] TO [webAdminUser_role]
GO
GRANT EXECUTE ON [dbo].[usp_SearchPDQ] TO [webSiteUser_role]
GO
