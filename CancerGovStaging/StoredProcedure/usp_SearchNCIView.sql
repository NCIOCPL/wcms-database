IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_SearchNCIView]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_SearchNCIView]
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




--***********************************************************************
-- Create New Object 
--************************************************************************

/****** Object:  Stored Procedure dbo.usp_RetrieveNCIView  
* Owner:Jhe 
* Purpose: For admin side Script Date: 10/07/2003 16:00:49 pm ******/


CREATE PROCEDURE [dbo].[usp_SearchNCIView] 
	(
	@Type			int,
	@Title			varchar(255),
	@Short			varchar(64),
	@Description		varchar(1500),
	@PrettyURL		varchar(1000),
	@TitleSelected		varchar(10),
	@ShortSelected		varchar(10),
	@DescriptionSelected	varchar(10),
	@PrettyURLSelected	varchar(10),
	@Notes			varchar(1000),
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


--	select 	@Title 			= REPLACE(@Title,'''',''''''),
--		@Short			= REPLACE(@Short,'''',''''''),
--		@Description 		= REPLACE(@Description,'''',''''''),
--		@PrettyURL		= REPLACE(@PrettyURL,'''',''''''),
--		@Notes			= REPLACE(@Notes,'''',''''''),
--		@PreviewURL		= REPLACE(@PreviewURL,'''','''''')
	

	SELECT @count = COUNT(*) 
	FROM UserGroupPermissionMap  
	WHERE UserID = 
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

	--select @Sql = 'SELECT Link=''<a href=NCIViewRedirect.aspx?ReturnURL=&NCIViewID=''+ CONVERT(varchar(38), N.NCIViewID) + ''>Edit</a>'', ''Title/URL''= N.Title + ''<br><a href='' + N.url + IsNull(NullIf( ''?''+IsNull(N.URLArguments,''''),''?''),'''') + ''>'' + N.url + IsNull(NullIf( ''?''+IsNull(N.URLArguments,''''),''?''),'''') + ''</a>'',N.ShortTitle, N.Description, ''Owner Group''=G.GroupName, ''Updated''=Convert(varchar,N.UpdateDate,101) + '' by '' + N.UpdateUserID, ''Expires''=Convert(varchar,N.ExpirationDate,101) FROM NCIView N, Groups G where N.GroupID=G.GroupID '  + @sectionSql

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
	Else IF (@Type =13) 			--PowerPointPresentation        / --SinglePageNavigation
	Begin 
		select @templateSql =' and N.NCITemplateID in ( select  NCITemplateID from NCITemplate WHERE ClassName =''POWERPOINTPRESENTATION'')' 
		--select @templateSql =' and N.NCITemplateID in ( select  NCITemplateID from NCITemplate WHERE ClassName =''BASICLIST'')' 
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

	select @Sql =   'SELECT N.NCIViewID, case LEFT(N.url , 7) when ''https:/''  then N.Title + ''<br><a href="'' + N.url+ ''">'' + N.url+ ''</a>''  when ''http://'' then N.Title + ''<br><a href="''+N.url +''">'' + N.url+ ''</a>''
else  N.Title + ''<br><a href="' + @PreviewURL +''' + N.url + IsNull(NullIf( ''?''+IsNull(N.URLArguments,''''),''?''),'''') + ''">'' + N.url + IsNull(NullIf( ''?''+IsNull(N.URLArguments,''''),''?''),'''') + ''</a>'' end as ''Title/URL'', '

	if (@Type = 1)
	BEGIN
		if (len(@Prettyurl) > 0)
		BEGIN
			select @Sql = @Sql+ '''Short Title''=N.ShortTitle, isnull(P.CurrentURL, P.ProposedURL) as Prettyurl, ''Owner Group''=G.GroupName, ''Updated''=Convert(varchar,N.UpdateDate,102), ''Expires''=Convert(varchar,N.ExpirationDate,102) FROM NCIView  AS N  WITH (READUNCOMMITTED), Groups G, PrettyURL P where P.NCIViewID=N.NCIViewID and P.IsRoot=1 and P.ObjectID is null and P.RealURL like ''%viewid=%'' and N.GroupID=G.GroupID '
		END
		else
		BEGIN

			select @Sql = @Sql+ '''Short Title''=N.ShortTitle,  N.Description,''Owner Group''=G.GroupName, ''Updated''=Convert(varchar,N.UpdateDate,102), ''Expires''=Convert(varchar,N.ExpirationDate,102) FROM NCIView  AS N  WITH (READUNCOMMITTED), Groups G where N.GroupID=G.GroupID ' 
		END
	END 
	else if (@Type= 8)
	BEGIN
		if (len(@Prettyurl) > 0)
		BEGIN
			select @Sql = @Sql+ '''Short Title''=N.ShortTitle, isnull(P.CurrentURL, P.ProposedURL) as Prettyurl, ''Owner Group''=G.GroupName, ''Updated''=Convert(varchar,N.UpdateDate,102), ''Expires''=Convert(varchar,N.ExpirationDate,102) FROM NCIView AS N  WITH (READUNCOMMITTED), Groups G, PrettyURL P where P.NCIViewID=N.NCIViewID and P.IsRoot=1 and P.ObjectID is null and N.GroupID=G.GroupID '
		END
		else
		BEGIN
			select @Sql = @Sql+ '''Short Title''=N.ShortTitle, N.Description, ''Owner Group''=G.GroupName, ''Updated''=Convert(varchar,N.UpdateDate,102), ''Expires''=Convert(varchar,N.ExpirationDate,102) FROM NCIView AS N  WITH (READUNCOMMITTED), Groups G where N.GroupID=G.GroupID '
		END
	END
	else
	BEGIN
		if (len(@Prettyurl) > 0)
		BEGIN
			select @Sql = @Sql+ '''Short Title''=N.ShortTitle, isnull(P.CurrentURL, P.ProposedURL) as Prettyurl, ''Owner Group''=G.GroupName, ''Updated''=Convert(varchar,N.UpdateDate,102), ''Expires''=Convert(varchar,N.ExpirationDate,102) FROM NCIView AS N  WITH (READUNCOMMITTED), Groups G , PrettyURL P where P.NCIViewID=N.NCIViewID and P.IsRoot=1 and P.ObjectID is null and N.GroupID=G.GroupID '
		END
		else
		BEGIN	
			select @Sql = @Sql+ ' ''Short Title''=N.ShortTitle, N.Description, ''Owner Group''=G.GroupName, ''Updated''=Convert(varchar,N.UpdateDate,102), ''Expires''=Convert(varchar,N.ExpirationDate,102) FROM NCIView  AS N  WITH (READUNCOMMITTED), Groups G where N.GroupID=G.GroupID '
		END
	END

	select @Sql = @Sql + @templateSql + @sectionSql 

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
		or (len(@PrettyURL)> 0)
		or (len(@Notes) >0)
	BEGIN
		
		select @tmpLogical = ''
		select @sql =  @sql + ' and ('
		

		IF (len(@Title) > 0)
		BEGIN
			select @sql = @sql + ' REPLACE(N.Title,'''''''','''') LIKE  ''%' + @Title + '%'' ' 	
			select @tmpLogical = @TitleSelected
		END
			
		IF  (len(@Short)> 0 )	
		BEGIN
			select @sql = @sql + @tmpLogical + ' REPLACE(N.ShortTitle,'''''''','''')   LIKE ''%' + @Short + '%'' '
			select @tmpLogical = @ShortSelected
		END
				
		IF (len(@Description) > 0)
		BEGIN
			select @sql = @sql + @tmpLogical + ' REPLACE(N.Description,'''''''','''')   LIKE ''%' + @Description + '%'' '	
			select @tmpLogical = @DescriptionSelected
		END
		
				
		IF (len(@PrettyURL) > 0)
		BEGIN
			select @sql = @sql + @tmpLogical + '  (REPLACE(P.ProposedURL,'''''''','''')   LIKE ''%' +  @PrettyURL  + '%'' or REPLACE(P.CurrentURL,'''''''' ,'''')   LIKE ''%' +  @PrettyURL  +  '%'') '
			select @tmpLogical = @PrettyURLSelected
		END

		IF (len(@Notes) > 0)
		BEGIN
			select @sql = @sql + @tmpLogical + 'N.NCIViewID in (select distinct NCIViewID from AuditNCIView where REPLACE(ChangeComments,'''''''','''')   LIKE ''%' +  @Notes + '%'') '	
			--select @sql = @sql + @tmpLogical + 'N.ChangeComments LIKE ''%' +  @Notes + '%'' '	
		END
		select @sql = @sql + ' ) '
	END
	
		PRINT @sql

	execute (@sql)
END


GO
GRANT EXECUTE ON [dbo].[usp_SearchNCIView] TO [webadminuser_role]
GO
