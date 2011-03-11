IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetNewsletterStats]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetNewsletterStats]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--*************************************************************************
-- Create Object
--*************************************************************************

CREATE PROCEDURE dbo.usp_GetNewsletterStats
AS
BEGIN
create table #TempNLStats
(
   [Date] varchar(11),
   Subscribes int null,
   Unsubscribes int null
)

insert into #TempNLStats
([Date])

select [Date] from (
	select * from (
		select distinct convert(varchar(11),subscriptiondate,111) as [Date] from usersubscriptionmap
		where subscriptiondate is not null
		AND NewsletterID = '21D177EB-19D0-46EC-BFDC-5BC089568963'
	) as tbl1
	UNION
	select * from (
		select distinct convert(varchar(11),unsubscribedate,111) as [Date] from usersubscriptionmap
		where unsubscribedate is not null
		AND NewsletterID = '21D177EB-19D0-46EC-BFDC-5BC089568963'
	) as tbl2
) as tbl3
order by [Date]

update #TempNLStats
set Subscribes = Sub.Subscribes
FROM (
   select [Date], count([Date]) as Subscribes
   FROM ( 
	   select convert(varchar(11),subscriptiondate,111) as [Date]
   	   from usersubscriptionmap
	   Where NewsletterID = '21D177EB-19D0-46EC-BFDC-5BC089568963'
   ) as Sub
   Group by [Date]
) as sub
where #TempNLStats.[Date] = sub.[Date]

update #TempNLStats
set Unsubscribes = UnSub.UnSubscribes
FROM (
   select [Date], count([Date]) as UnSubscribes
   FROM ( 
	   select convert(varchar(11),unsubscribedate,111) as [Date]
   	   from usersubscriptionmap
	   where NewsletterID = '21D177EB-19D0-46EC-BFDC-5BC089568963'
   ) as UnSub
   Group by [Date]
) as Unsub
where #TempNLStats.[Date] = Unsub.[Date]

select [Date],ISNULL(subscribes,0) as subscribes, ISNULL(unsubscribes,0) as unsubscribes  from #TempNLStats

drop table #TempNLStats
END

GO
GRANT EXECUTE ON [dbo].[usp_GetNewsletterStats] TO [webadminuser_role]
GO
GRANT EXECUTE ON [dbo].[usp_GetNewsletterStats] TO [websiteuser_role]
GO
