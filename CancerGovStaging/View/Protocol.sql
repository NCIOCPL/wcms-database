IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[Protocol]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[Protocol]
GO

/****** Object:  VIEW [dbo].[Protocol]    Script Date: 10/8/2001 11:57:35 PM ******/
CREATE VIEW [dbo].[Protocol] 
AS 

SELECT ProtocolID ,                          
	StudyTypeID ,                         
	StatusID     ,                        
	StatusDate    ,                                         
	Title          ,                                                                                                                                                                                                                                                  
	ShortTitle      ,                                                                                                                                                                                                                                                 
	LowerAge    ,
	UpperAge    ,
	AgeCriteria  ,                                                                    
	IsNew ,
	IsActive, 
	IsReadyForWeb ,
	IsNCIProtocol ,
	UpdateDate     ,                                        
	UpdateUserID    ,                                   
	SourceID         ,    
	DataSource 
FROM CancerGov..[Protocol]



GO
