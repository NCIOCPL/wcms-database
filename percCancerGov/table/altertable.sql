alter table cgvPageMetadata add taxonomyTag nvarchar(1000)
GO
alter table cgvstagingPageMetadata add taxonomyTag nvarchar(1000)
GO


alter table cgvpagemetadata add allowComments bit 
alter table cgvstagingpagemetadata add allowComments bit 

