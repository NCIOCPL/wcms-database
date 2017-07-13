alter table percCancergov.dbo.gloimagemetadata add SocialmediaURL nvarchar(800)
alter table percCancergov.dbo.glostagingimagemetadata add SocialmediaURL nvarchar(800)
GO

alter table percussion.dbo.ct_genimage
add [IMG6] [image] NULL,
	[IMG6_EXT] [nvarchar](50) NULL,
	[IMG6_FILENAME] [nvarchar](512) NULL,
	[IMG6_TYPE] [nvarchar](50) NULL,
	[IMG6_WIDTH] [nvarchar](50) NULL,
	[IMG6_HEIGHT] [nvarchar](50) NULL,
	[IMG6_SIZE] [int] NULL
GO

