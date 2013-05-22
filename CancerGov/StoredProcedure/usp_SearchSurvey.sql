IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_SearchSurvey]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_SearchSurvey]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.usp_RetrieveNCIView  
* Owner:Jhe 
* Purpose: For admin side Script Date: 10/07/2003 16:00:49 pm ******/


CREATE PROCEDURE [dbo].[usp_SearchSurvey] 
	(
	@Type			int,
	@From			varchar(20),
	@To			varchar(20)
)
AS
BEGIN	
	Declare @sql varchar(1000)

	if (@Type =1)
	BEGIN
		select @sql = 'select * from SurveyCT '
	END
	else if (@Type= 2)
	BEGIN
		select @sql = 'select * from Survey '
	END


	if (len(@From) >0  and len(@To) >0)
	BEGIN
		select @sql = @sql + ' where UpdateDate >= ''' +  @From + ''' and UpdateDate <= '''+  @To +''''
	END
	ELSE if (len(@From) >0 and len(@To) =0)
	BEGIN
		select @sql = @sql + ' where  UpdateDate >=''' +  @From +''''
	END
	ELSE if (len(@From) =0 and len(@To) >0)
	BEGIN
		select @sql = @sql + ' where UpdateDate <= '''+  @To +''''
	END
	

	select @sql =@sql + ' order by updatedate'

	print @sql

	execute (@sql)
	/*

	if (@Type =1)
	BEGIN
		if (len(@From) >0 and len(@To) >0)
		BEGIN
			select * from SurveyCT 
			where  UpdateDate >=  @From and UpdateDate <= @To
		END
		ELSE if (len(@From) >0 and len(@To) =0)
		BEGIN
			select * from SurveyCT 
			where  UpdateDate > @From 
		END
		ELSE if (len(@From) =0 and len(@To) >0)
		BEGIN
			select * from SurveyCT 
			where  UpdateDate <= @To
		END
		ELSE 
		BEGIN
			select * from SurveyCT
		END
	END
	else if (@Type= 2)
	BEGIN
		if (len(@From) >0 and len(@To) >0)
		BEGIN
			select * from Survey where  UpdateDate > @From and UpdateDate <= @To
		END
		ELSE if (len(@From) >0 and len(@To) =0)
		BEGIN
			select * from Survey where  UpdateDate > @From 
		END
		ELSE if (len(@From) =0 and len(@To) >0)
		BEGIN
			select * from Survey where  UpdateDate <= @To
		END
		ELSE 
		BEGIN
			select * from Survey
		END
	END
*/
	
END
GO
