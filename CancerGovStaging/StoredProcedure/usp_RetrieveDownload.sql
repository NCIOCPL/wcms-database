IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_RetrieveDownload]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_RetrieveDownload]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.usp_RetrieveViewObject
   Owner:Jhe Purpose: For admin side Script Date: 1/15/2002 16:00:49 pm 
*/

CREATE PROCEDURE dbo.usp_RetrieveDownload
	(
	@UserName		varchar(40),
	@SectionSelected	varchar(100),
	@DateFrom		varchar(50),
	@DateTo		varchar(50)
	)
AS
BEGIN

	Declare  
		@Sql		varchar(2000),
		@count 		int
	

	SELECT @count = COUNT(*) FROM UserGroupPermissionMap WHERE UserID = 
		(SELECT UserID FROM NCIUsers WHERE loginName =  @UserName  ) AND GroupID = 
		(SELECT GroupID FROM Groups WHERE GroupIDName = 'Site Wide Admin')

				
	select @Sql = 'SELECT ''URL''= N.url + IsNull(NullIf( ''?''+IsNull(N.URLArguments,''''),''?''),'''') , ''Short Title''=N.ShortTitle, N.Description, ''Owner Group''=G.GroupName, 
		''Posted''=Convert(varchar,N.PostedDate,102),  ''Updated''=Convert(varchar,N.UpdateDate,102), ''Expires''=Convert(varchar,N.ExpirationDate,102), 
		''AdminURL''= N.NCIViewID, N.Title FROM NCIView N, Groups G WHERE N.GroupID=G.GroupID '
			
	if (len(@SectionSelected) =0)
	BEGIN
		if (@Count =0)
		BEGIN
			select @Sql =	@Sql +  ' AND N.NCIsectionID in (SELECT distinct N.SectionID FROM SectionGroupMap N, UserGroupPermissionMap M WHERE N.GroupID = M.GroupID and M.UserID = (SELECT UserID FROM NCIUsers WHERE loginName = ''' + @UserName + ''')) '
		
		END
	END
	Else
	BEGIN
		select @Sql =  @Sql +	' AND N.NCISectionID =''' + @SectionSelected +''''
	END
						
	if (len(@DateFrom) >0)
	BEGIN
		select @Sql = @Sql + ' and N.ExpirationDate >=''' + @DateFrom + ''''
	END

	if (len(@DateTo) >0)
	BEGIN
		select @Sql = @Sql + ' and N.ExpirationDate <=''' +  @DateTo +''''
	END

	select	@Sql = @Sql + ' order by G.GroupName, N.ExpirationDate'
			
	print @Sql	
		execute (
			@Sql
		)	
END
GO
GRANT EXECUTE ON [dbo].[usp_RetrieveDownload] TO [webadminuser_role]
GO
