public class UploadFileController 
{
    public Attachment objAttachment{get;set;}
    //public  blob body{get;set;}
    
    public UploadFileController()
    {
        objAttachment = new Attachment();
    }    
    
    public void uploadFile()
    {
       
        try{
            AmazonS3Connector connector = new AmazonS3Connector('logdog_Root');
            connector.putObject(objAttachment.Name, 'biznussoft', objAttachment.Body);
            objAttachment.Body = null;
            uploaded_File__c UF = New uploaded_File__c(Name = objAttachment.Name);
            insert UF ;
          //  objAttachment.ParentId = UF.id;
            //insert objAttachment;
        }
        catch(exception e)
        {
            ApexPages.addMessages(e);
        }
    }
}