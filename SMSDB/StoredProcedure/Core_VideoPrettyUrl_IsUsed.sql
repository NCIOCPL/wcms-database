IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_VideoPrettyUrl_IsUsed]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_VideoPrettyUrl_IsUsed]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************
* Purpose:	Checks to see if a pretty url is being used by a video.
* Author:	BryanP
* Date:		11/6/07
* Params: 
*	
********************************************************/
CREATE PROCEDURE [dbo].[Core_VideoPrettyUrl_IsUsed] 
	@PrettyUrl varchar(512),
	@IsUsed bit OUTPUT
AS
BEGIN
	SET @IsUsed = 0

	if (EXISTS(SELECT VideoPrettyUrlID FROM VideoPrettyUrl WHERE PrettyUrl = @PrettyUrl))
		SET @IsUsed = 1

END

GO
GRANT EXECUTE ON [dbo].[Core_VideoPrettyUrl_IsUsed] TO [websiteuser_role]
GO
