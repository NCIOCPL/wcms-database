/****** Object:  UserDefinedFunction [dbo].[udf_getStudyCategoryID]    Script Date: 08/02/2006 11:17:47 ******/
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[udf_getStudyCategoryID]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[udf_getStudyCategoryID]
GO
create function dbo.udf_getStudyCategoryID (@trialType varchar(400))
returns table
as
return 
(select studycategoryid from dbo.udf_GetComaSeparatedIDs(@TrialType) t
					  inner join dbo.studycategory sc on sc.studycategoryname = t.objectid	 )