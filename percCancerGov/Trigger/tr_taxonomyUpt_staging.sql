
if OBJECT_ID('tr_TaxonomyUpt_staging') is not null
	drop trigger dbo.tr_TaxonomyUpt_staging
	go 
create trigger dbo.tr_TaxonomyUpt_staging on dbo.cgvstagingPageMetadata after update
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
					
		if exists (select * from inserted where taxonomytag is not null)
					insert into cgvTaxonRelationstaging (contentid, taxonomyName , taxonID )
					select i.CONTENTID , s.taxonomyname, s.taxonid 
					from inserted i 
					 cross apply dbo.taxonomySplit (i.taxonomytag) s
				

		
END
GO
