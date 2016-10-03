  
  
  
/* NCI - National Cancer Institute  
*   
* Purpose:   
* - Push Extracted data To CDRPreviewGK   
*  
* Objects Used:  
*  
*  
*/  

if object_id('usp_PushDictionaryTermToLive') is not null
    drop procedure dbo.usp_PushDictionaryTermToLive  
go
CREATE PROCEDURE dbo.usp_PushDictionaryTermToLive  
 (  
 @TermID  int  
 )  
AS  
BEGIN  
  
 set nocount on   
   
 DECLARE @r int  
  
  
 BEGIN  
  EXEC @r =  CDRLiveGK.dbo.usp_ClearDictionaryData @TermID  
  IF (@@ERROR <> 0) or (@r <>0)  
  BEGIN  
     
   RAISERROR ( 70001, 16, 1, @TermID, 'Dictionary')  
   RETURN 70001  
  END   
 END  
  
 --**************************************************************************************************************  
  
 INSERT INTO CDRLiveGK.dbo.Dictionary  
  (  
  TermID,  
  TermName,  
  Dictionary,  
  Language,  
  Audience,  
  ApiVers,  
  Object  
  )  
 SELECT  TermID,  
  TermName,  
  Dictionary,  
  Language,  
  Audience,  
  ApiVers,  
  Object  
 FROM  CDRPreviewGK.dbo.Dictionary  
 WHERE  TermID = @TermID  
  
 IF (@@ERROR <> 0)  
 BEGIN  
    
  RAISERROR ( 70000, 16, 1, @TermID, 'Dictionary')  
  RETURN 70000  
 END    
  
 INSERT INTO CDRLiveGK.dbo.DictionaryTermAlias  
  (  
  TermID,  
  Othername,  
  OtherNameType,  
  Language  ,
  othernamelen
  )  
 SELECT TermID,  
   Othername,  
   OtherNameType,  
   Language  ,
   len(othername)
 FROM  CDRPreviewGK.dbo.DictionaryTermAlias  
 WHERE  TermID = @TermID  
  
  
 IF (@@ERROR <> 0)  
 BEGIN  
    
  RAISERROR ( 70000, 16, 1, @TermID, 'Dictionary')  
  RETURN 70000  
 END    
  
END  
 GO
 GRANT EXECUTE ON [dbo].[usp_PushDictionaryTermToLive] TO [Gatekeeper_role]  
  