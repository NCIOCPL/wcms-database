IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_SearchLink]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_SearchLink]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.usp_RetrieveNCIView  
* Owner:Jhe 
* Purpose: For admin side Script Date: 10/07/2003 16:00:49 pm ******/


CREATE PROCEDURE [dbo].[usp_SearchLink] 
	(
	@NCIViewID		uniqueidentifier,
	@Title			varchar(255),
	@Short			varchar(64),
	@URL			varchar(2000),
	@ExternalSelected	int,
	@TitleSelected		varchar(10),
	@ShortSelected		varchar(10)
)
AS
BEGIN	
	Declare 
		@sql 		varchar(2000),
		@tmpLogical	varchar(20)


	select 	@Title 			= REPLACE(@Title,'''',''''''),
		@Short			= REPLACE(@Short,'''',''''''),
		@URL			= REPLACE(@URL,'''','''''')


	if (@ExternalSelected =1 )
	BEGIN
		select @sql = 'SELECT NCIViewID,''Title/URL''= Title + ''<br><a href='' + url + IsNull(NullIf( ''?''+IsNull(URLArguments,''''),''?''),'''') + ''>'' + url + IsNull(NullIf( ''?''+IsNull(URLArguments,''''),''?''),'''') + ''</a>'',''Short Title''=ShortTitle,Description, 
				CreateDate FROM NCIView where NCIViewID not in (select objectID from ViewObjects where Type=''LINK'' AND NCIViewID=''' +Convert(varchar(36),@NCIViewID) + ''') and url like ''%http%'' and NCITemplateID is null '
	END
	else
	BEGIN
		select @sql = 'SELECT NCIViewID,''Title/URL''= Title + ''<br><a href='' + url + IsNull(NullIf( ''?''+IsNull(URLArguments,''''),''?''),'''') + ''>'' + url + IsNull(NullIf( ''?''+IsNull(URLArguments,''''),''?''),'''') + ''</a>'',''Short Title''=ShortTitle,Description, 
				CreateDate FROM NCIView where NCIViewID not in (select objectID from ViewObjects where Type=''LINK'' AND NCIViewID='''+Convert(varchar(36),@NCIViewID) +''') and NCITemplateID is not null and isonproduction =1 and 
				NCITemplateID != (select NCITemplateID from NCITemplate where Name like ''%digest%'')'
	END
			
	if (len(@Title) > 0 Or  len(@Short) > 0 Or len(@URL) > 0)
	BEGIN
		select @tmpLogical = ''
		select @sql = @sql + '  and ('

		if (len(@Title) > 0)
		BEGIN
			select @sql = @sql + ' Title LIKE ''%' + @Title + '%'' '
			select @tmpLogical = @TitleSelected
		END
			
		if ( len(@Short) > 0)
		BEGIN
			select @sql = @sql + @tmpLogical   + ' ShortTitle LIKE ''%' + @Short+ '%'' ' 				
			select @tmpLogical = @ShortSelected
		END
		
		if (len(@URL) > 0)
		BEGIN
			select @sql = @sql + @tmpLogical +  ' url + IsNull(NullIf( ''?''+IsNull(URLArguments,''''),''?''),'''')  LIKE ''%' + @URL + '%'' '
		END
		
		select @sql =	@sql + ')'
	END

	select @sql = @sql +' order by Title'

	PRINT @sql

	execute (@sql)
END

GO
GRANT EXECUTE ON [dbo].[usp_SearchLink] TO [webadminuser_role]
GO
