use percCancergov

alter table  dbo.cgvpagemetadata add IMAGEID int
alter table  dbo.cgvstagingpagemetadata add IMAGEID int
GO


alter table  dbo.cgvpagemetadata add blogBody nvarchar(max)
alter table  dbo.cgvstagingpagemetadata add blogBody nvarchar(max)

GO


alter table  dbo.cgvpagemetadata add author nvarchar(100)
alter table  dbo.cgvstagingpagemetadata add author nvarchar(100)
GO
