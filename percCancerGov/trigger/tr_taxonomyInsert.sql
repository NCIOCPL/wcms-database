if OBJECT_ID('tr_TaxonomyInsert') is not null
	drop trigger dbo.tr_TaxonomyInsert
	go 
create trigger dbo.tr_TaxonomyInsert on dbo.cgvPageMetadata after insert
as 
BEGIN

IF (@@ROWCOUNT = 0)
  RETURN;

SET NOCOUNT ON
			if exists (select * from inserted where taxonomytag is not null)
					insert into cgvTaxonRelation (contentid, taxonomyName , taxonID )
					select i.CONTENTID , s.taxonomyname, s.taxonid 
					from inserted i 
					 cross apply dbo.taxonomySplit (i.taxonomytag) s
		
END
GO

