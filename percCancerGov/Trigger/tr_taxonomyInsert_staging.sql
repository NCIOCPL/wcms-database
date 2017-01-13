if OBJECT_ID('tr_TaxonomyInsert_staging') is not null
	drop trigger dbo.tr_TaxonomyInsert_staging
	go 
create trigger dbo.tr_TaxonomyInsert_staging on dbo.cgvstagingPageMetadata after insert
as 
BEGIN

IF (@@ROWCOUNT = 0)
  RETURN;

SET NOCOUNT ON
			if exists (select * from inserted where taxonomytag is not null)
					insert into cgvTaxonRelationstaging (contentid, taxonomyName , taxonID,  taxonLabel)
					select i.CONTENTID , s.taxonomyname, s.taxonid ,s.taxonLabel
					from inserted i 
					 cross apply dbo.taxonomySplit (i.taxonomytag) s
		
END
GO


