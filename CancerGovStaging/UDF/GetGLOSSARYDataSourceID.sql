IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[GetGLOSSARYDataSourceID]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[GetGLOSSARYDataSourceID]
GO
/*	NCI - National Cancer Institute
*	
*	Purpose:	
*
*	Objects Used:
*
*	Change History:
*	?/?/2001 	Alex Pidlisnyy	Script Created
*	2/22/2002 	Alex Pidlisnyy	Make this function independant from CancerGov database
*/


CREATE FUNCTION [dbo].[GetGLOSSARYDataSourceID] ()  
RETURNS char(3)
WITH SCHEMABINDING
AS  

BEGIN 
	RETURN('GLOSSARYXML') 
END


GO
