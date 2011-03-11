IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_AdvancedSearchNCIViewForList]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_AdvancedSearchNCIViewForList]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.usp_RetrieveNCIView  
* Owner:Jhe 
* Purpose: For admin side Script Date: 10/07/2003 16:00:49 pm ******/


CREATE PROCEDURE [dbo].[usp_AdvancedSearchNCIViewForList] 
	(
	@ListID 		uniqueidentifier,
	@Title			varchar(255),
	@Short			varchar(64),
	@Description		varchar(1500),
	@OldURL		varchar(1000),
	@MetaTitle		varchar(255),
	@MetaDescription	varchar(255),
	@MetaKeyword		varchar(255),
	@CreateFromDate	varchar(100), 
	@CreateToDate		varchar(100),
	@ExpirationFromDate	varchar(100),
	@ExpirationToDate	varchar(100),
	@ReleaseFromDate	varchar(100),
	@ReleaseToDate	varchar(100),
	@UpdateFromDate	varchar(100),
	@UpdateToDate	varchar(100),
	@TitleSelected		varchar(10),
	@ShortSelected		varchar(10),
	@DescriptionSelected	varchar(10),
	@OldUrlSelected	varchar(10),
	@MetaTitleSelected	varchar(10),
	@MetaDescriptionSelected	varchar(10),
	@MetaKeywordSelected	varchar(10),
	@CreationDateSelected	varchar(10),
	@ExpirationDateSelected	varchar(10),
	@ReleaseDateSelected	varchar(10),
	@PreviewURL		varchar(100) = ''

)
AS
BEGIN	
	Declare @count 		int,
		@sql 		varchar(2000),
		@tmpLogical	varchar(20)


	select 	@Title 			= REPLACE(@Title,'''',''''''),
		@Short			= REPLACE(@Short,'''',''''''),
		@Description 		= REPLACE(@Description,'''',''''''),
		@OldURL 		= REPLACE(@OldURL,'''',''''''),
		@MetaTitle 		= REPLACE(@MetaTitle,'''',''''''),
		@MetaDescription	= REPLACE(@MetaDescription,'''',''''''),
		@MetaKeyword		= REPLACE(@MetaKeyword, '''','''''')

	select @count = count(V.Type) from list L, ViewObjects V where L.ListID=V.ObjectID and V.Type='NLLIST' AND L.listid=@ListID
	PRINT Convert(varchar(2), @count)

	if (@count =0)
	BEGIN
		select @sql = 'SELECT NCIViewID,
case LEFT(url , 7) when ''https:/''  then Title + ''<br><a href="'' + url+ ''">'' + url+ ''</a>'' when ''http://'' then Title + ''<br><a href="'' + url+ ''">'' + url+ ''</a>''
else  Title + ''<br><a href="' + @PreviewURL +''' + url + IsNull(NullIf( ''?''+IsNull(URLArguments,''''),''?''),'''') + ''">'' + url + IsNull(NullIf( ''?''+IsNull(URLArguments,''''),''?''),'''') + ''</a>'' end as ''Title/URL'',

''Short Title''= ShortTitle,Description, CreateDate FROM NCIView where NCIViewID not in (select NCIViewID from ListItem where ListID=''' + Convert(varchar(36), @ListID) +''') '
	END
	else
	BEGIN
		select @sql = 'SELECT NCIViewID,
case LEFT(url , 7) when ''https:/''  then Title + ''<br><a href="'' + url+ ''">'' + url+ ''</a>'' when ''http://'' then Title + ''<br><a href="'' + url+ ''">'' + url+ ''</a>''
else  Title + ''<br><a href="' + @PreviewURL +''' + url + IsNull(NullIf( ''?''+IsNull(URLArguments,''''),''?''),'''') + ''">'' + url + IsNull(NullIf( ''?''+IsNull(URLArguments,''''),''?''),'''') + ''</a>'' end as ''Title/URL'',

''Short Title''= ShortTitle,Description, CreateDate FROM NCIView where NCIViewID not in (select NCIViewID from NLListItem where ListID=''' +  Convert(varchar(36), @ListID)  +''') '	
	END	
	
	

	if 	(len(@Title) > 0)  
		or (len(@Short)> 0 )
		or (len(@Description) > 0)
		or (len(@OldUrl) > 0 )
		or (len(@MetaTitle) > 0) 
		or (len(@MetaDescription) > 0)
 		or (len(@MetaKeyword) > 0)
		or (len(@CreateFromDate) >0)
		or (len(@CreateToDate) > 0) 		
		or (len(@ExpirationFromDate) > 0) 		
		or (len(@ExpirationToDate) > 0) 		
		or (len(@ReleaseFromDate) > 0) 		
		or (len(@ReleaseToDate) > 0) 		
		or (len(@UpdateFromDate) > 0) 		
		or (len(@UpdateToDate) > 0)
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
			select @tmpLogical = @DescriptionSelected
		END

		IF (len(@OldUrl) > 0 )
		BEGIN
			select @sql = @sql + @tmpLogical + ' URL LIKE ''%' + @OldUrl + '%'' '	
			select @tmpLogical = @OldUrlSelected
		END
			
		IF(len(@MetaTitle) > 0)
		BEGIN		
			select @sql = @sql + @tmpLogical + ' MetaTitle LIKE ''%' + @MetaTitle + '%'' ' 
			select @tmpLogical = @MetaTitleSelected
		END

		if (len(@MetaDescription) > 0)
		BEGIN
			select @sql = @sql + @tmpLogical + ' MetaDescription LIKE ''%' + @MetaDescription + '%'' '
			select @tmpLogical = @MetaDescriptionSelected
		END

		if (len(@MetaKeyword) > 0)
		BEGIN
			select @sql = @sql + @tmpLogical + ' MetaKeyword LIKE ''%' + @MetaKeyword + '%'' '
			select @tmpLogical= @MetaKeywordSelected
		END
	
		if (len(@CreateFromDate)> 0) or (len(@CreateToDate) >0)
		BEGIN
			select @sql = @sql + @tmpLogical

			if (len(@CreateFromDate) >0) and  (len(@CreateToDate) >0)
			BEGIN
				select @sql = @sql + ' ( CreateDate >= ''' + @CreateFromDate + ''' AND CreateDate <= ''' + @CreateToDate + ''') '	
			END
			ELSE if (len(@CreateFromDate) >0)  and (len(@CreateToDate) = 0)
			BEGIN
				select @sql = @sql + ' CreateDate >= ''' + @CreateFromDate + ''' '	
			END
			else 
			BEGIN
				select @sql = @sql + ' CreateDate <= ''' + @CreateToDate + ''' '
			END
				
			select	@tmpLogical = @CreationDateSelected
		END
			
		if (len(@ReleaseFromDate) > 0 ) or (len(@ReleaseToDate) >0) 
		BEGIN
			select @sql = @sql + @tmpLogical
			if (len(@ReleaseFromDate) >0 ) and (len(@ReleaseToDate) >0)
			BEGIN
				select @sql = @sql + ' (ReleaseDate <= ''' + @ReleaseToDate + ''' AND ReleaseDate >= ''' + @ReleaseFromDate + ''') '
			END
			else if (len(@ReleaseFromDate) >0 ) and (len(@ReleaseToDate) =0)
			BEGIN
				select @sql = @sql + ' ReleaseDate >= '''  +  @ReleaseFromDate + ''' '
			END
			else 
			BEGIN
				select @sql = @sql + ' ReleaseDate <= '''  +  @ReleaseToDate +''' ' 
			END
			select @tmpLogical = @ReleaseDateSelected
		END
				
		if (len(@ExpirationFromDate)>0)  or (len(@ExpirationToDate) >0)
		BEGIN
			select @sql = @sql + @tmpLogical
			if (len(@ExpirationFromDate)>0)  and  (len(@ExpirationToDate) >0)
			BEGIN
				select @sql = @sql + ' (ExpirationDate <= ''' + @ExpirationToDate + ''' AND ExpirationDate >= ''' + @ExpirationFromDate + ''') '		
			END
			else if (len(@ExpirationFromDate)>0)  and (len(@ExpirationToDate) = 0)
			BEGIN
				select @sql = @sql + ' ExpirationDate >= ''' + @ExpirationFromDate  + ''' '	
			END
			else 
			BEGIN
				select @sql = @sql + ' ExpirationDate <= ''' + @ExpirationToDate + ''' '	
			END
			select @tmpLogical = @ExpirationDateSelected
		END

		if (len(@UpdateFromDate) >0) Or (len(@UpdateToDate) >0)
		BEGIN
			select @sql = @sql + @tmpLogical 
			if (len(@UpdateFromDate) >0) and (len(@UpdateToDate) >0)
			BEGIN
				select @sql = @sql + ' (UpdateDate <= ''' + @UpdateToDate + ''' AND UpdateDate >= ''' + @UpdateFromDate + ''') '
			END
			else if (len(@UpdateFromDate) >0) and (len(@UpdateToDate) =0)
			BEGIN
				select @sql = @sql + ' UpdateDate >= ''' + @UpdateFromDate + ''' '	
			END
			else 
			BEGIN
				select @sql = @sql + ' UpdateDate <= ''' + @UpdateToDate + ''' '
			END
		END
		
		select @sql = @sql + ' ) '
	END
	
		PRINT @sql

	execute (@sql)
END

GO
GRANT EXECUTE ON [dbo].[usp_AdvancedSearchNCIViewForList] TO [webadminuser_role]
GO
