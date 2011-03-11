IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_LogProtocolSearchExecutionTime]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_LogProtocolSearchExecutionTime]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*************************************************************************************************************
*	NCI - National Cancer Institute
*	
*	Purpose:	
*
*	Objects Used:
*
*	Change History:
*	2/6/2004 	Alex Pidlisnyy	Script Created
*
*	To Do List:
*
*************************************************************************************************************/

CREATE PROC dbo.usp_LogProtocolSearchExecutionTime 
(
	@ProtocolSearchID int,
	@ResultCount int,
	@StartTime datetime,
	@Message varchar(8000)
)
AS
BEGIN 
	DECLARE @FinishTime datetime

	SET @FinishTime = GETDATE()	

	INSERT INTO ProtocolSearchDetails WITH (ROWLOCK) 
		( ProtocolSearchID, ResultCount, StartTime, FinishTime, Message ) 
	VALUES 	( @ProtocolSearchID, @ResultCount, @StartTime, @FinishTime, @Message )

END

GO
