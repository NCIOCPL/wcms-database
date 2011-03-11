IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetProtocolDrugsByID]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetProtocolDrugsByID]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE dbo.usp_GetProtocolDrugsByID

	     @IDList varchar(4000)

AS
BEGIN

	Declare @DrugIDs Table(item int)

	insert into @DrugIDs
	select objectID from udf_GetComaSeparatedIDs(@IDList)

	SELECT TermID as CDRID,
		DrugName as [Name],
		DisplayName
	FROM dbo.TermDrug
	WHERE TermID in (select item from @DrugIDs)
		and DrugName = DisplayName
	ORDER BY [Name] ASC


END
GO
GRANT EXECUTE ON [dbo].[usp_GetProtocolDrugsByID] TO [websiteuser_role]
GO
