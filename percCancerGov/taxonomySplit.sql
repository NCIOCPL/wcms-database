USE [PercCancerGov]
GO

/****** Object:  UserDefinedFunction [dbo].[TaxonomySplit]    Script Date: 10/12/2016 2:52:29 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

if object_id('TaxonomySplit')  is not null
	drop function [dbo].[TaxonomySplit]
go
create function [dbo].[TaxonomySplit] (@xml xml)
returns table
AS

return  (
	SELECT
Tab.Col.value('(taxonomyName/text())[1]','varchar(300)') as taxonomyName,
Tab.Col.value('(taxonId/text())[1]','int') as taxonId,
Tab.Col.value('(taxonLabel/text())[1]','varchar(300)') as taxonLabel

FROM   @xml.nodes('/taxonomyLabels/taxon') Tab(Col)
	
)	


GO


