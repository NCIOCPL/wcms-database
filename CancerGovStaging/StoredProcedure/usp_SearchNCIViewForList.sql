IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_SearchNCIViewForList]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_SearchNCIViewForList]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.usp_RetrieveNCIView  
* Owner:Jhe 
* Purpose: For admin side Script Date: 10/07/2003 16:00:49 pm ******/


CREATE PROCEDURE [dbo].[usp_SearchNCIViewForList] 
	(
	@ListID 		uniqueidentifier,
	@Title			varchar(255),
	@Short			varchar(64),
	@Description		varchar(1500),
	@TitleSelected		varchar(10),
	@ShortSelected		varchar(10),
	@PreviewURL		varchar(100) = ''
)
AS
BEGIN	
	Declare @count 		int,
		@sql 		varchar(2000),
		@tmpLogical	varchar(20)


	select 	@Title 			= REPLACE(@Title,'''',''''''),
		@Short			= REPLACE(@Short,'''',''''''),
		@Description 		= REPLACE(@Description,'''','''''')

	select @count = count(V.Type) from list L, ViewObjects V where L.ListID=V.ObjectID and V.Type='NLLIST' AND L.listid=@ListID
	PRINT Convert(varchar(2), @count)


	select @Sql =   'SELECT NCIViewID, case LEFT(url , 7) when ''https:/''  then Title + ''<br><a href="'' + url+ ''">'' + url+ ''</a>'' when ''http://'' then Title + ''<br><a href="'' + url+ ''">'' + url+ ''</a>''
else  Title + ''<br><a href="' + @PreviewURL +''' + url + IsNull(NullIf( ''?''+IsNull(URLArguments,''''),''?''),'''') + ''">'' + url + IsNull(NullIf( ''?''+IsNull(URLArguments,''''),''?''),'''') + ''</a>'' end as ''Title/URL'', ''Short Title''= ShortTitle,Description, CreateDate FROM NCIView '

	if (@count =0)
	BEGIN
		select @Sql = @Sql+ ' where  NCIViewID not in (select NCIViewID from ListItem where ListID=''' + Convert(varchar(36), @ListID) +''') '		
	END
	else
	BEGIN
		select @Sql = @Sql+ ' where  NCIViewID not in (select NCIViewID from NLListItem where ListID=''' +  Convert(varchar(36), @ListID)  +''') '	
	END	
	
	

	if 	(len(@Title) > 0)  
		or (len(@Short)> 0 )
		or (len(@Description) > 0)
	BEGIN
		
		select @tmpLogical = ''
		select @sql =  @sql + ' and ('
		

		IF (len(@Title) > 0)
		BEGIN
			select @sql = @sql + ' Title LIKE  ''%' + @Title + '%'' ' 	
			select @tmpLogical = @TitleSelected
		END
			
		IF  (len(@Short)> 0 )	
		BEGIN
			select @sql = @sql + @tmpLogical + ' ShortTitle LIKE ''%' + @Short + '%'' '
			select @tmpLogical = @ShortSelected
		END
				
		IF (len(@Description) > 0)
		BEGIN
			select @sql = @sql + @tmpLogical + ' Description LIKE ''%' + @Description + '%'' '	
		END
		
		select @sql = @sql + ' ) '
	END
	
		PRINT @sql

	execute (@sql)
END

GO
GRANT EXECUTE ON [dbo].[usp_SearchNCIViewForList] TO [webadminuser_role]
GO
