IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_getTrialTypeManualList]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_getTrialTypeManualList]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

create procedure dbo.usp_getTrialTypeManualList
as
begin
set nocount on
select displayName,displayPosition  from dbo.TrialTypeManualList order by displayPosition
end

GO
GRANT EXECUTE ON [dbo].[usp_getTrialTypeManualList] TO [websiteuser_role]
GO
