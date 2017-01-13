if OBJECT_ID('cgvTaxonRelationstaging') is not null
	drop table cgvTaxonRelationstaging
go
create table dbo.cgvTaxonRelationstaging (contentid int, taxonomyName varchar(250), taxonID int, TaxonLabel varchar(500))
GO
create  clustered index idx_cgvTaxonRelationstaging on cgvTaxonRelationstaging (contentid, taxonomyName, taxonid) 
create  index idx_cgvTaxonRelation_nonclusteredstaging on cgvTaxonRelationstaging ( taxonomyName, taxonid) 

