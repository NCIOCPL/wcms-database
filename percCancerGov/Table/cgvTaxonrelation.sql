if OBJECT_ID('cgvTaxonRelation') is not null
	drop table cgvTaxonRelation
go
create table dbo.cgvTaxonRelation (contentid int, taxonomyName varchar(250), taxonID int)
GO
create  clustered index idx_cgvTaxonRelation on cgvTaxonRelation (contentid, taxonomyName, taxonid) 
create  index idx_cgvTaxonRelation_nonclustered on cgvTaxonRelation ( taxonomyName, taxonid) 

