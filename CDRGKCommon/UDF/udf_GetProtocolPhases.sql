IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[udf_GetProtocolPhases]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[udf_GetProtocolPhases]
GO

/*************************************************************************************************************
*	NCI - National Cancer Institute
*	
*	Purpose:	
*
*	Objects Used:	CancerType
*
*	Change History:
*	12/10/2003 	Alex Pidlisnyy	Script Created
*************************************************************************************************************/

CREATE FUNCTION dbo.udf_GetProtocolPhases
(
	@ProtocolID int
)
RETURNS varchar(8000)
AS  

BEGIN 

declare @s varchar(300)
set @s = ''
select @s = @s + ', ' + case phase when 1 then 'Phase I' when 2 then 'Phase II' when 3 then 'Phase III' when 4 then 'Phase IV' else '' end 
from protocolphase
where protocolid  = @protocolid
order by phase desc

return case when len(@S) > 2 then right(@s,len(@s) -2) else 'No phase specified' end

END

GO
