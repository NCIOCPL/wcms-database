IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetSubscriberStats]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetSubscriberStats]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


--*************************************************************************
-- Create Object
--*************************************************************************

CREATE PROCEDURE dbo.usp_GetSubscriberStats
AS
BEGIN

select  *
from CancerGov..NLSubscribersSelected 

END

GO
GRANT EXECUTE ON [dbo].[usp_GetSubscriberStats] TO [webadminuser_role]
GO
