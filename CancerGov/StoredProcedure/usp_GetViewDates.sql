IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetViewDates]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetViewDates]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


-- This is used in order to be able to display a date in any format
-- So yes, it is rough since the whole seconds since 1970 thing
-- causes overflows for the dates that are the year 2100 
-- Created 11/4/2003 Bryan Pizzillo

CREATE PROCEDURE dbo.usp_GetViewDates
	(
	@ViewId	uniqueidentifier
	)
AS
BEGIN

	SELECT 
		MONTH (CreateDate) AS CreateDateMonth,
		DAY (CreateDate) AS CreateDateDay,
		YEAR (CreateDate) AS CreateDateYear,
		DATEPART(dw,CreateDate) AS CreateDateDayOfWeek,

		MONTH(ReleaseDate) AS ReleaseDateMonth,
		DAY(ReleaseDate) AS ReleaseDateDay,
		YEAR(ReleaseDate) AS ReleaseDateYear,
		DATEPART(dw,ReleaseDate) AS ReleaseDateDayOfWeek,

		MONTH(ExpirationDate) AS ExpirationDateMonth,
		DAY(ExpirationDate) AS ExpirationDateDay,
		YEAR(ExpirationDate) AS ExpirationDateYear,
		DATEPART(dw,ExpirationDate) AS ExpirationDateDayOfWeek,

		MONTH(UpdateDate) AS UpdateDateMonth,
		DAY(UpdateDate) AS UpdateDateDay,
		YEAR(UpdateDate) AS UpdateDateYear,
		DATEPART(dw,UpdateDate) AS UpdateDateDayOfWeek,

		MONTH(PostedDate) AS PostedDateMonth,
		DAY(PostedDate) AS PostedDateDay,
		YEAR(PostedDate) AS PostedDateYear,
		DATEPART(dw,PostedDate) AS PostedDateDayOfWeek

	FROM 	NCIView 
	WHERE NCIViewID = @ViewId

END


GO
GRANT EXECUTE ON [dbo].[usp_GetViewDates] TO [websiteuser_role]
GO
