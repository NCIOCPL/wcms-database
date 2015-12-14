
if OBJECT_ID('tr_TaxonomyDelete_staging') is not null
	drop trigger dbo.tr_TaxonomyDelete_staging
	go 
create trigger dbo.tr_TaxonomyDelete_staging on dbo.cgvstagingPageMetadata after  delete
as 
BEGIN

IF (@@ROWCOUNT = 0)
  RETURN;

SET NOCOUNT ON
		if exists (select * from deleted where taxonomytag is not null)
					delete m 
					from  deleted d 
					cross apply dbo.taxonomySplit (d.taxonomytag) s
					inner join cgvTaxonRelationstaging m on  m.contentid = d.CONTENTID 
						and m.taxonomyname = s.taxonomyname 
						and m.taxonid = s.taxonid 
					
		
END
GO