Update dbo.CGVHTMLCONTENTDATA_CGVHTMLCONTENTDATA 
set body=replace(cast(BODY as nvarchar(max)), 'contenteditable="false"', 'contenteditable="true"') 
where BODY LIKE '%contenteditable="false"%'
