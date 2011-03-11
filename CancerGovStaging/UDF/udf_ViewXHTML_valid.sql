/**--a.	The view validation function will 
--first check a view’s description, 
then checks the description, data, TOC fields of any child object in Document table 
and the description and text fields of any child object in ExternalObject table. It will return true or false depending on result
--b.	This view validation function will be integrated into usp_retrieveNCIView / usp_retrieveNCIViewInfo to be returned along with all other NCIView info.
**/

if object_id('udf_ViewXHTML_Valid') is not NULL
	drop function dbo.udf_ViewXHTML_Valid
go
create function dbo.udf_ViewXHTML_Valid (@nciviewid uniqueidentifier, @DTDLocation nvarchar(300) = N'C:\\Temp\\xhtml1-transitional.dtd')
returns bit
as
BEGIN
	

	declare @msg varchar(max)
	select @msg = ''	

	if not exists (select * from dbo.nciview where nciviewid = @nciviewid)
		BEGIN
			select @msg = 'No such View'
			GOTO final
		END

		--View description
		if exists (select *
					from dbo.nciview
					where  nciviewid = @nciviewid and dbo.udf_IsValidXHTML(description,@DTDLocation) = 0
				   )	
			
			BEGIN
				select @msg = @msg +  'View''s description invalid. ' 
				GOTO final
			END
			
		--Document data, description, TOC
		if exists ( select *
					from dbo.viewobjects vo inner join dbo.document d on d.documentid = vo.objectid
					where  nciviewid = @nciviewid and type not in ('SEARCH','VirSearch')
							and 
								(dbo.udf_IsValidXHTML(data,@DTDLocation) =0
								 or dbo.udf_IsValidXHTML(description,@DTDLocation) = 0
								 or dbo.udf_IsValidXHTML(TOC,@DTDLocation) = 0
								 )
					)
		
			BEGIN
				select @msg = @msg +  'Document invalid. '
				GOTO final
			END

		

		--ExternalObject Text, description
		if exists (select *
					from dbo.viewobjects vo inner join dbo.externalobject e on e.externalobjectID = vo.objectid
					where  nciviewid = @nciviewid 
							and 
								(dbo.udf_IsValidXHTML(text,@DTDLocation) = 0
									or dbo.udf_IsValidXHTML(description,@DTDLocation) = 0
								)
					)
			BEGIN
				select @msg = @msg +  'ExternalObject invalid. '
				GOTO final
			END


		--List ListDesc
		if exists  (select *
					from dbo.viewobjects vo inner join dbo.list l on l.listID = vo.objectid
					where  vo.nciviewid = @nciviewid 
							and l.listdesc is not null 
							and dbo.udf_IsValidXHTML(listDesc,@DTDLocation) = 0
					)
			BEGIN
				select @msg = @msg +  'List''s description invalid. '
				GOTO final
			END

		--- Image textSource
			if exists ( select * 
							from dbo.viewobjects vo inner join dbo.image i on i.imageid = vo.objectid
						where vo.nciviewid =  @nciviewid
								and len(i.textsource) > 0
								and dbo.udf_IsValidXHTML(textSource,@DTDLocation) = 0
						)

				BEGIN
					select @msg = @msg +  'Image''s textSource invalid. '
					GOTO final
				END


	 final: if @msg = ''
					return 1
			return 0	
			
END
GO

Grant execute on dbo.udf_ViewXHTML_Valid to webadminUser_role


