USE [PercCancerGov]
GO

/****** Object:  UserDefinedTableType [dbo].[udt_TaxonomyFilter]    Script Date: 08/20/2015 11:54:26 ******/

IF  EXISTS (SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'udt_TaxonomyFilter' AND ss.name = N'dbo')
DROP TYPE [dbo].[udt_TaxonomyFilter]
GO


CREATE TYPE [dbo].[udt_TaxonomyFilter] AS TABLE(
	[taxonomyName] [varchar](250) NULL,
	[taxonID] [int] NULL
)
GO


