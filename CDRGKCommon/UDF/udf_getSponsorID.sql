/****** Object:  UserDefinedFunction [dbo].[udf_getSponsorID]    Script Date: 08/02/2006 11:17:47 ******/
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[udf_getSponsorID]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[udf_getSponsorID]
GO
create function dbo.udf_getSponsorID (@trialsponsor varchar(400))
returns table
as
return (SELECT  sponsorid 
		FROM	dbo.udf_GetComaSeparatedIDs( @TrialSponsor ) s 
				inner join dbo.sponsor n on s.objectid  = n.sponsorname
 )
