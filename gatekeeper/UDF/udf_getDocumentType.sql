IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[udf_getDocumentType]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[udf_getDocumentType]
GO
create function dbo.udf_getDocumentType (@datasetID int)
returns varchar(50)
as

begin
	declare @dt varchar(50)
	select @dt =  name 
		from dbo.documenttypemap m inner join documenttype t on m.documenttypeid = t.documenttypeid 
		where datasetid =  @datasetID
	return @dt 
end

GO
