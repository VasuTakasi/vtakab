public class DownLoadFileController 
{
   public string attId{get;set;}
   public list<SelectOption>lstUploadedFiles{get;set;}
   public string fileName{get;set;}
    
   public DownLoadFileController()
   {
       lstUploadedFiles = new SelectOption[]{};
       for( Uploaded_File__c obj : [Select Name FROM Uploaded_File__c ] )
           lstUploadedFiles.add( new SelectOption(
               obj.Name, obj.Name
           ) );
   }
   
     
   public Pagereference FileeContent()
   {
       AmazonS3Connector connector = new AmazonS3Connector('logdog_Root');
      //connector.putObject('test$file.text', 'biznussoft', 'poc');
       HttpResponse res = connector.getObject( new AWSS3Object('biznussoft',fileName,'test') );//java-json.jar
       if( res != null ) 
       {     //fileContent  = EncodingUtil.Base64Encode(res.getBodyAsBlob());
       
           Attachment objAtt = new Attachment();
           objAtt.Name = fileName;
           objAtt.body = res.getBodyAsBlob(); 
           objAtt.ParentId = 'a0228000006Ewi3';    
           insert objAtt;
           objAtt.body = null;
           attId = objAtt.Id;
           Pagereference ref = new PageReference('/servlet/servlet.FileDownload?file='+objAtt.Id);
           //https://ap2.salesforce.com/servlet/servlet.FileDownload?file=00P28000001Wei5EAC
           ref.setRedirect(true);
           return ref;
       }
       return null;
   }
   
}