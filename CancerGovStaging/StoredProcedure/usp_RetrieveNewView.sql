IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_RetrieveNewView]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_RetrieveNewView]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.usp_RetrieveViewObject
   Owner:Jhe Purpose: For admin side Script Date: 1/15/2002 16:00:49 pm 
*/

CREATE PROCEDURE dbo.usp_RetrieveNewView
	(
	@Name varchar(50),
 	@NumberOfDays varchar(10),
	@NumberOfRows varchar(10)
	)
AS
BEGIN
				
		execute (
			'SELECT TOP '  + @NumberOfRows + ' ShortTitle, ''URL''=url + IsNull(NullIf( ''?''+IsNull(URLArguments,''''),''?''),'''') FROM NCIView WHERE 
			NCISectionID =  (Select NCISectionID from NCISection WHERE name=''' + @Name +''' ) AND DATEDIFF(day, CreateDate, GETDATE()) <= '
			+ @NumberOfDays + ' AND NCITemplateID is not null  AND isonproduction=1 ORDER BY CreateDate DESC, ShortTitle ASC'
		)	
END
GO
GRANT EXECUTE ON [dbo].[usp_RetrieveNewView] TO [webadminuser_role]
GO
