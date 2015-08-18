if OBJECT_ID('tr_TaxonomyDelete') is not null
	drop trigger dbo.tr_TaxonomyDelete
	go 
create trigger dbo.tr_TaxonomyDelete on dbo.cgvPageMetadata after  delete
as 
BEGIN

IF (@@ROWCOUNT = 0)
  RETURN;

SET NOCOUNT ON
		if exists (select * from deleted where taxonomytag is not null)
					delete m 
					from  deleted d 
					cross apply dbo.taxonomySplit (d.taxonomytag) s
					inner join cgvTaxonRelation m on  m.contentid = d.CONTENTID 
						and m.taxonomyname = s.taxonomyname 
						and m.taxonid = s.taxonid 
					
		
END
GO