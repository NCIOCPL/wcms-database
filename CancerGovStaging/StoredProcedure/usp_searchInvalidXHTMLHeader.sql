IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_SearchInvalidXHTMLHeader]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_SearchInvalidXHTMLHeader]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Object:  Stored Procedure dbo.[usp_SearchInvalidXHTMLHeader]  
* Owner:Jhe 
* Purpose: For admin side Script Date: 12/28/2009  ******/


CREATE PROCEDURE [dbo].[usp_SearchInvalidXHTMLHeader]
AS
BEGIN	
	select headerid, Name, Updateuserid as 'Update User ID', updatedate as Updated from header where type='contentheader' 
	and dbo.udf_isvalidXHTML(data, 'c:\\Temp\\xhtml1-transitional.dtd') = 0 
	order by name
END


GO
GRANT EXECUTE ON [dbo].[usp_SearchInvalidXHTMLHeader] TO [webadminuser_role]
GO
