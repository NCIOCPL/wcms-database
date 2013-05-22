if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[udf_getProtocolStudyCategory]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[udf_getProtocolStudyCategory]
GO
create function [dbo].[udf_getProtocolStudyCategory] (@protocolid int)
returns  varchar(300)
as
begin
declare @s varchar(300)
set @s = ''
select @s = @s + ',  ' + studycategoryname 
from
(select distinct studycategoryname 
from dbo.protocolstudycategory psc inner join dbo.studycategory sc on psc.studycategoryid  = sc.studycategoryid
where protocolid  = @protocolid) a
order by studycategoryname 
return right(@s,len(@s) -3)
end