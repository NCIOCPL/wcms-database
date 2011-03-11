IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_AdvancedSearchNCIView]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_AdvancedSearchNCIView]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



--***********************************************************************
-- Create New Object 
--************************************************************************
/****** Object:  Stored Procedure dbo.usp_UpdateNCIView   Owner:Jhe Purpose: For admin side Script Date: 1/15/2002 16:00:49 pm ******/		
	/****** Object:  Stored Procedure dbo.usp_UpdateNCIView   Owner:Jhe Purpose: For admin side Script Date: 1/15/2002 16:00:49 pm ******/		
					
	/****** Object:  Stored Procedure dbo.usp_searchnewslettersubscriber
* Owner:Jhe 
* Purpose: For admin side Script Date: 10/07/2003 16:00:49 pm ******/


/****** 	Object:  Stored Procedure dbo.usp_UpdateLink
	Owner:	Jay He
	Script Date: 3/17/2003 14:43:49 pM 
******/



--***********************************************************************
-- Create New Object 
--************************************************************************


/****** Object:  Stored Procedure dbo.usp_RetrieveNCIView  
* Owner:Jhe 
* Purpose: For admin side Script Date: 10/07/2003 16:00:49 pm ******/


CREATE PROCEDURE [dbo].[usp_AdvancedSearchNCIView]
	(
	@Type			int,
	@Title			varchar(255),
	@Short			varchar(64),
	@Description		varchar(1500),
	@ViewID 		varchar(36),
	@URL			varchar(1000),
	@Notes			varchar(1000),
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
	@ViewIDSelected	varchar(10),
	@URLSelected		varchar(10),
	@NotesSelected	varchar(10),
	@MetaTitleSelected	varchar(10),
	@MetaDescriptionSelected	varchar(10),
	@MetaKeywordSelected	varchar(10),
	@CreationDateSelected	varchar(10),
	@ExpirationDateSelected	varchar(10),
	@ReleaseDateSelected	varchar(10),
	@URLRedirection	varchar(10),
	@UserName		varchar(50),
	@PreviewURL		varchar(100)
)
AS
BEGIN	
	Declare @templateSql	varchar(1000),
		@sectionSql	varchar(1000),
		@Sql 		varchar(2000),
		@tmpLogical	varchar(20),
		@count 		int

	select 	@Title 			= REPLACE(@Title,'''',''''''),
		@Short			= REPLACE(@Short,'''',''''''),
		@Description 		= REPLACE(@Description,'''',''''''),
		@ViewID		= REPLACE(@ViewID,'''',''''''),
		@URL 			= REPLACE(@URL,'''',''''''),
		@Notes			= REPLACE(@Notes,'''',''''''),
		@MetaTitle 		= REPLACE(@MetaTitle,'''',''''''),
		@MetaDescription	= REPLACE(@MetaDescription,'''',''''''),
		@MetaKeyword		= REPLACE(@MetaKeyword, '''','''''')
	
	SELECT @count = COUNT(*) FROM UserGroupPermissionMap WHERE UserID = 
		(SELECT UserID FROM NCIUsers WHERE loginName =  @UserName  ) AND GroupID = 
		(SELECT GroupID FROM Groups WHERE GroupIDName = 'Site Wide Admin')

	
	if (@count >0)
	BEGIN
		select @sectionSql = ' AND N.NCIsectionID in (SELECT distinct NCISectionID FROM NCISection) '
	END
	else
	BEGIN
		select @sectionSql = ' AND N.NCIsectionID in (SELECT distinct N.SectionID FROM SectionGroupMap N, UserGroupPermissionMap M WHERE N.GroupID = M.GroupID and M.UserID = (SELECT UserID FROM NCIUsers WHERE loginName = ''' + @UserName + ''')) '
	END		
	

	select @Sql = 'SELECT Link=''<a href=NCIViewRedirect.aspx?ReturnURL=&NCIViewID=''+ CONVERT(varchar(38), N.NCIViewID) + ''>Edit</a>'',
case LEFT(url , 7) when ''https:/''  then Title + ''<br><a href="'' + url+ ''">'' + url+ ''</a>'' when ''http://'' then Title + ''<br><a href="'' + url+ ''">'' + url+ ''</a>''
else  Title + ''<br><a href="' + @PreviewURL +''' + url + IsNull(NullIf( ''?''+IsNull(URLArguments,''''),''?''),'''') + ''">'' + url + IsNull(NullIf( ''?''+IsNull(URLArguments,''''),''?''),'''') + ''</a>'' end as ''Title/URL'',
N.ShortTitle, N.Description, ''Owner Group''=G.GroupName, ''Updated''=Convert(varchar,N.UpdateDate,101) + '' by '' + N.UpdateUserID, ''Expires''=Convert(varchar,N.ExpirationDate,101) FROM NCIView N, Groups G where N.GroupID=G.GroupID '  + @sectionSql



	If (@Type =1) -- all
	BEGIN
		select @templateSql ='' 
	END
	Else if (@Type =2)	--Content
	BEGIN
		select @templateSql =' and N.NCITemplateID in ( SELECT NCITemplateID from NCITemplate WHERE ClassName in (''BASICDOCUMENT'',''MULTIPAGEDOCUMENT'', ''POWERPOINTPRESENTATION'') ) ' 
	END
	ELSE if (@Type =3) 	--Navigation Pages
	BEGIN
		select @templateSql =' and N.NCITemplateID in ( SELECT NCITemplateID from NCITemplate WHERE ClassName in (''BASICLIST'', ''CANCERTYPELIST''))'
	END
	Else IF (@Type =5) 			--benchmark
	Begin 
		select @templateSql =' and N.NCITemplateID in ( select  NCITemplateID from NCITemplate WHERE ClassName =''BENCHMARK'')'
	End
	Else IF (@Type =6) 			--CancerTypeList
	Begin 
		select @templateSql =' and N.NCITemplateID in ( select  NCITemplateID from NCITemplate WHERE ClassName = ''CANCERTYPELIST'')'
	End
	Else IF (@Type =7) 			--digest
	Begin 
		select @templateSql =' and N.NCITemplateID in ( select  NCITemplateID from NCITemplate WHERE ClassName =''MULTIPAGEDIGEST'')'
	End
	Else IF (@Type =8) 			--external link view
	Begin 
		select @templateSql =' and N.NCITemplateID is Null and N.URL like ''%http%'' '
	End
	Else IF (@Type =9) 			--newsletter
	Begin 
		select @templateSql =' and N.NCITemplateID in ( select  NCITemplateID from NCITemplate WHERE ClassName =''NEWSLETTER'')'
	End
	ELSE if (@Type =10)			--MultiPageDocument
	Begin 
		select @templateSql =' and N.NCITemplateID in ( SELECT NCITemplateID from NCITemplate WHERE ClassName =''MULTIPAGEDOCUMENT'')'
	End
	Else IF (@Type =11) 			--PDF 
	Begin 
		select @templateSql =' and N.NCITemplateID in ( select  NCITemplateID from NCITemplate WHERE ClassName = ''PDF'')'
	End
	ELSE if (@Type =12)			--SinglePageDocument
	Begin 
		select @templateSql =' and N.NCITemplateID in ( SELECT NCITemplateID from NCITemplate WHERE ClassName =''BASICDOCUMENT'')' 
	End
	Else IF (@Type =13) 			--PowerPointPresentation |--SinglePageNavigation
	Begin 
		--select @templateSql =' and N.NCITemplateID in ( select  NCITemplateID from NCITemplate WHERE ClassName =''BASICLIST'')' 
		select @templateSql =' and N.NCITemplateID in ( select  NCITemplateID from NCITemplate WHERE ClassName =''POWERPOINTPRESENTATION'')' 
	End
	Else IF (@Type =14) 			--Summary
	Begin 
		select @templateSql =' and N.NCITemplateID in ( select  NCITemplateID from NCITemplate WHERE ClassName =''MULTIPAGESUMMARY'')' 
	End
	Else IF (@Type =15) 			--AutomaticRSS
	Begin 
		select @templateSql =' and N.NCITemplateID in ( select  NCITemplateID from NCITemplate WHERE ClassName =''AutomaticRSSFeed'')' 
	End
	Else IF (@Type =16) 			--ManualRSS
	Begin 
		select @templateSql =' and N.NCITemplateID in ( select  NCITemplateID from NCITemplate WHERE ClassName =''ManualRSSFeed'')' 
	End

	select @Sql = @Sql + @templateSql
			
	if (@URLRedirection ='YES')
	BEGIN
		select @Sql = @Sql + ' and N.NCIViewID in (select nciviewid from viewproperty where propertyname=''RedirectUrl'') '
	END
	ELSE
	BEGIN
		select @Sql = @Sql + ' and N.NCIViewID not in (select nciviewid from viewproperty where propertyname=''RedirectUrl'') '
	END

	if 	(len(@Title) > 0)  
		or (len(@Short)> 0 )
		or (len(@Description) > 0)
		or (len(@ViewID) > 0)
		or (len(@URL) > 0 )
		or (len(@Notes) > 0 )
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
		select @Sql =  @Sql + ' and ('
		

		IF (len(@Title) > 0)
		BEGIN
			select @Sql = @Sql + ' N.Title LIKE  ''%' + @Title + '%'' ' 	
			select @tmpLogical = @TitleSelected
		END
			
		IF  (len(@Short)> 0 )	
		BEGIN
			select @Sql = @Sql + @tmpLogical + ' N.ShortTitle LIKE ''%' + @Short + '%'' '
			select @tmpLogical = @ShortSelected
		END
				
		IF (len(@Description) > 0)
		BEGIN
			select @Sql = @Sql + @tmpLogical + ' N.Description LIKE ''%' + @Description + '%'' '	
			select @tmpLogical = @DescriptionSelected
		END

		if (len(@ViewID) > 0)
		BEGIN
			select @Sql = @Sql + @tmpLogical + ' Convert(varchar(36), N.nciviewID) LIKE ''%' +@ViewID + '%'' '
			select @tmpLogical = @ViewIDSelected
		END

		IF (len(@Url) > 0 )
		BEGIN
			select @Sql = @Sql + @tmpLogical + ' N.url + IsNull(NullIf( ''?''+IsNull(N.URLArguments,''''),''?''),'''')  LIKE ''%' + @URL + '%'' '	
			select @tmpLogical = @URLSelected
		END

		IF (len(@Notes) > 0 )
		BEGIN
			select @sql = @sql + @tmpLogical + ' N.NCIViewID in (select distinct NCIViewID from AuditNCIView where ChangeComments LIKE ''%' +  @Notes + '%'') '	
			--select @Sql = @Sql + @tmpLogical + ' N.ChangeComments LIKE ''%' + @Notes + '%'' '	
			select @tmpLogical = @NotesSelected
		END
						
		IF(len(@MetaTitle) > 0)
		BEGIN		
			select @Sql = @Sql + @tmpLogical + ' N.MetaTitle LIKE ''%' + @MetaTitle + '%'' ' 
			select @tmpLogical = @MetaTitleSelected
		END

		if (len(@MetaDescription) > 0)
		BEGIN
			select @Sql = @Sql + @tmpLogical + ' N.MetaDescription LIKE ''%' + @MetaDescription + '%'' '
			select @tmpLogical = @MetaDescriptionSelected
		END

		if (len(@MetaKeyword) > 0)
		BEGIN
			select @Sql = @Sql + @tmpLogical + ' N.MetaKeyword LIKE ''%' + @MetaKeyword + '%'' '
			select @tmpLogical= @MetaKeywordSelected
		END
	
		if (len(@CreateFromDate)> 0) or (len(@CreateToDate) >0)
		BEGIN
			select @Sql = @Sql + @tmpLogical

			if (len(@CreateFromDate) >0) and  (len(@CreateToDate) >0)
			BEGIN
				select @Sql = @Sql + ' ( N.CreateDate >= ''' + @CreateFromDate + ''' AND N.CreateDate <= ''' + @CreateToDate + ''') '	
			END
			ELSE if (len(@CreateFromDate) >0)  and (len(@CreateToDate) = 0)
			BEGIN
				select @Sql = @Sql + ' N.CreateDate >= ''' + @CreateFromDate + ''' '	
			END
			else 
			BEGIN
				select @Sql = @Sql + ' CreateDate <= ''' + @CreateToDate + ''' '
			END
				
			select	@tmpLogical = @CreationDateSelected
		END
			
		if (len(@ReleaseFromDate) > 0 ) or (len(@ReleaseToDate) >0) 
		BEGIN
			select @Sql = @Sql + @tmpLogical
			if (len(@ReleaseFromDate) >0 ) and (len(@ReleaseToDate) >0)
			BEGIN
				select @Sql = @Sql + ' (N.ReleaseDate <= ''' + @ReleaseToDate + ''' AND N.ReleaseDate >= ''' + @ReleaseFromDate + ''') '
			END
			else if (len(@ReleaseFromDate) >0 ) and (len(@ReleaseToDate) =0)
			BEGIN
				select @Sql = @Sql + ' N.ReleaseDate >= '''  +  @ReleaseFromDate + ''' '
			END
			else 
			BEGIN
				select @Sql = @Sql + ' N.ReleaseDate <= '''  +  @ReleaseToDate +''' ' 
			END
			select @tmpLogical = @ReleaseDateSelected
		END
				
		if (len(@ExpirationFromDate)>0)  or (len(@ExpirationToDate) >0)
		BEGIN
			select @Sql = @Sql + @tmpLogical
			if (len(@ExpirationFromDate)>0)  and  (len(@ExpirationToDate) >0)
			BEGIN
				select @Sql = @Sql + ' (N.ExpirationDate <= ''' + @ExpirationToDate + ''' AND N.ExpirationDate >= ''' + @ExpirationFromDate + ''') '		
			END
			else if (len(@ExpirationFromDate)>0)  and (len(@ExpirationToDate) = 0)
			BEGIN
				select @Sql = @Sql + ' N.ExpirationDate >= ''' + @ExpirationFromDate  + ''' '	
			END
			else 
			BEGIN
				select @Sql = @Sql + ' N.ExpirationDate <= ''' + @ExpirationToDate + ''' '	
			END
			select @tmpLogical = @ExpirationDateSelected
		END

		if (len(@UpdateFromDate) >0) Or (len(@UpdateToDate) >0)
		BEGIN
			select @Sql = @Sql + @tmpLogical 
			if (len(@UpdateFromDate) >0) and (len(@UpdateToDate) >0)
			BEGIN
				select @Sql = @Sql + ' (N.UpdateDate <= ''' + @UpdateToDate + ''' AND N.UpdateDate >= ''' + @UpdateFromDate + ''') '
			END
			else if (len(@UpdateFromDate) >0) and (len(@UpdateToDate) =0)
			BEGIN
				select @Sql = @Sql + ' N.UpdateDate >= ''' + @UpdateFromDate + ''' '	
			END
			else 
			BEGIN
				select @Sql = @Sql + ' N.UpdateDate <= ''' + @UpdateToDate + ''' '
			END
		END
		
		select @Sql = @Sql + ' )  order by ''Title/URL'''
	END
	

	PRINT @Sql

	execute (@Sql)
END


GO
GRANT EXECUTE ON [dbo].[usp_AdvancedSearchNCIView] TO [webadminuser_role]
GO
