IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_LogClick]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_LogClick]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE usp_LogClick
	(
		@EventSrc	varchar(1000),
		@ClientIP	varchar(15),
		@ClickItem	varchar(1000),
		@ClickValue	varchar(1000),
		@UserSessionID varchar(50) = null
	)

AS
BEGIN 
	--INSERT INTO ClickEventLog(EventSrc, DestUrl, ClientIP, ClickItem, DateLogged)
	--Values(@EventSrc, @ClickValue, @ClientIP, @ClickItem, getDate())

	INSERT INTO ClickLog ( 
		EventSrc, 
		DestUrl, 
		ClientIP, 
		UserSessionID,
		ClickItem, 
		DateLogged
		)
	Values ( 
		@EventSrc, 
		@ClickValue, 
		@ClientIP, 
		@UserSessionID,
		@ClickItem, 
		getDate()
		)
END
GO
GRANT EXECUTE ON [dbo].[usp_LogClick] TO [websiteuser_role]
GO
