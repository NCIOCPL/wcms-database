IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_SearchHeader]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_SearchHeader]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



--***********************************************************************
-- Create New Object 
--************************************************************************
/****** Object:  Stored Procedure dbo.usp_RetrieveHeader
* Owner:Jhe 
* Purpose: For admin side Script Date: 12/11/2003 16:00:49 pm ******/


CREATE PROCEDURE [dbo].[usp_SearchHeader] 
	(
	@NCIViewID		uniqueidentifier,
	@Name			varchar(50),
	@Content		varchar(2000),
	@Type			varchar(30),
	@NameSelected	varchar(10),
	@ContentSelected	varchar(10)
)
AS
BEGIN	
	Declare 
		@sql 		varchar(2000),
		@tmpLogical	varchar(20)


	select 	@Name 			= REPLACE(@Name,'''',''''''),
		@Content			= REPLACE(@Content,'''','''''')


	select @sql = 'SELECT HeaderID, Name, ContentType, UpdateDate, UpdateUserID FROM HEADER 
			where HeaderID not in (select objectID from ViewObjects where Type in (''BODYHEADER'') AND NCIViewID=''' +Convert(varchar(36),@NCIViewID) + ''') and Type =''CONTENTHEADER'' and ISAPPROVED=1 '
	/*
	select @sql = 'SELECT HeaderID, Name, ContentType, UpdateDate, UpdateUserID FROM HEADER 
			where HeaderID not in (select objectID from ViewObjects where Type in (''HEADER'', ''LEFTHEADER'') AND NCIViewID=''' +Convert(varchar(36),@NCIViewID) + ''') and Type =''CONTENTHEADER'' and ISAPPROVED=1 '
		*/	
	if (len(@Name) > 0 Or  len(@Content) > 0 or len(@Type) >0)
	BEGIN
		select @tmpLogical = ''
		select @sql = @sql + '  and ('

		if (len(@Name) > 0)
		BEGIN
			select @sql = @sql + ' Name LIKE ''%' + @Name + '%'' '
			select @tmpLogical = @NameSelected
		END
			
		if ( len(@Content) > 0)
		BEGIN
			select @sql = @sql + @tmpLogical   + ' Data LIKE ''%' + @Content +'%'' ' 				
			select @tmpLogical = @ContentSelected
		END
		
		select @sql = @sql + @tmpLogical   + ' ContentType=''' + @Type +  ''')'
	END

	select @sql = @sql +' order by Name'

	PRINT @sql

	execute (@sql)
END

GO
GRANT EXECUTE ON [dbo].[usp_SearchHeader] TO [webadminuser_role]
GO
