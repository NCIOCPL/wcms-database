if object_id('udf_getDocumentTitle') is not null
	drop function dbo.udf_getDocumentTitle
go
create function dbo.udf_getDocumentTitle(@requestDataid int, @datasetid int)
returns varchar(800)
as
BEGIN
	
return

(
	case when @datasetid = 7
	then (select convert(xml,data).value('data((//SummaryTitle)[1])', 'varchar(800)')
	from documentdata
	where requestdataid = @requestdataid
	)
	 when @datasetid = 4
	then (select convert(xml,data).value('data((//PreferredName)[1])', 'varchar(800)')
	from documentdata
	where requestdataid = @requestdataid
	)

	when @datasetid = 13
	then (select convert(xml,data).value('data((//PDQProtocolTitle)[1])', 'varchar(800)')
	from documentdata
	where requestdataid = @requestdataid
	)
	when @datasetid = 14
	then (select convert(xml,data).value('data((//OfficialTitle)[1])', 'varchar(800)')
	from documentdata
	where requestdataid = @requestdataid
	)
	when @datasetid = 1
	then (select convert(xml,data).value('data((//TermName)[1])', 'varchar(800)')
	from documentdata
	where requestdataid = @requestdataid
	)
	when @datasetid = 8
	then (select convert(xml,data).value('data((//OfficialName/Name)[1])', 'varchar(800)')
	from documentdata
	where requestdataid = @requestdataid
	)
	when @datasetid = 11
	then (select convert(xml,data).value('data((//PoliticalSubUnitFullName)[1])', 'varchar(800)')
	from documentdata
	where requestdataid = @requestdataid
	)
	when @datasetid = 12
	then (select convert(xml,data).value('data((//LASTNAME)[1])', 'varchar(800)')
	from documentdata
	where requestdataid = @requestdataid
	)
	when @datasetid = 16
	then (select convert(xml,data).value('data((//DrugInfoTitle)[1])', 'varchar(800)')
	from documentdata
	where requestdataid = @requestdataid
	)
	else '' END
)
END
go
