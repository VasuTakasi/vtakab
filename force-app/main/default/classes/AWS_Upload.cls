/***************************************************************************
Created By :tanay.barman@kvpcorp.com
Created Date : Jun 15, 2015
Description : This class supports the following 
operations, related to  Document upload to AWS s3:
1. Policy generate for AWS .
2. Generate The HMAC-SHA256 hash of the security policy.  
********************************************/
public with sharing class AWS_Upload {
   public  Document__c newDocument{get;set;}
   Public  static AWS_Keys__c awsKeySet{get;set;}
   public string ForRedirect{get;set;}  
   public static string appParentId{get;set;}
   public string Content_Type {get;set;}  
   Public String acessType{get;set;}
   
   Datetime expire = system.now().addDays(1);
   string formattedexpire = expire.formatGmt('yyyy-MM-dd')+'T'+ expire.formatGmt('HH:mm:ss')+'.'+expire.formatGMT('SSS')+'Z';
   public string signature{get;set;}
   
   public AWS_Upload()
   {
      newDocument = new Document__c();
      awsKeySet= AWS_Keys__c.getInstance('biznussoft');
      //appParentId = ApexPages.currentPage().getParameters().get('parentIdForRedirect');
      signature = getSignedPolicy();
      
      ForRedirect = URL.getSalesforceBaseUrl().toExternalForm()+'/'+'apex/AWS_SucessRedirectPage?parentIdForRedirect='+appParentId;
      ForRedirect += '&Expires='+(system.now().addDays(1).getTime())/1000+'&Signature='+signature;
      Content_Type ='multipart/form-data';
      acessType ='private';
      
       system.debug('awsKeySet'+awsKeySet); 
       system.debug('policy'+policy);
       system.debug('___________2formattedexpire '+formattedexpire);
   }
       
      string policy { get {return 
        '{ "expiration": "'+formattedexpire+'","conditions": [ {"bucket": "'+
         awsKeySet.Name +'" } ,{ "acl": "'+acessType+'" },'+
        '{"content-type":"'+Content_Type+'"},'+
        '{"success_action_redirect": "'+ForRedirect+'"},' +
        '["starts-with", "$key", ""] ]}';   } } 
    
    public String getPolicy() {
        return EncodingUtil.base64Encode(Blob.valueOf(policy));
    }
    
    public String getSignedPolicy() {    
        return make_sig(EncodingUtil.base64Encode(Blob.valueOf(policy)));        
    }
    
    //method that will sign
    private String make_sig(string canonicalBuffer) 
    {        
        String macUrl ;
        Blob mac = Crypto.generateMac('HMacSHA1', blob.valueof(canonicalBuffer),blob.valueof(awsKeySet.AWS_Secret_Key__c)); 
        macUrl = EncodingUtil.base64Encode(mac);                
        return macUrl;
    }
       
     @RemoteAction
	public static Document__c createNewDocument(String appID, String uploadedFilename,string bucketName, string Signature, string Expires){
		 //stem.debug('ApexPages.currentPage().getParameters() '+ApexPages.currentPage().getParameters().get('parentIdForRedirect')); 
		AWS_Keys__c objAwsKeySet= AWS_Keys__c.getInstance('biznussoft');
		Document__c newDocument = new Document__c();
		   newDocument.Application__c = appID;
			newDocument.Document_Name__c = uploadedFilename;
		    //newDocument.Document_URL__c =  'https://s3-ap-southeast-1.amazonaws.com/'+bucketName+'/'+uploadedFilename;
		    //newDocument.Document_URL__c += '?AWSAccessKeyId=AKIAI726C5DGTQH7UGNA&Signature=';
		    //newDocument.Document_URL__c += Signature;
		    //newDocument.Document_URL__c += '&Expires='+Expires;
		    newDocument.Status__c ='Uploaded';
		    
		    
		     //get the filename in urlencoded format
        String filename = EncodingUtil.urlEncode(uploadedFilename, 'UTF-8');        
        Datetime now = DateTime.now();
        Datetime expireson = now.AddDays(120);
        Long Lexpires = expireson.getTime()/1000;
               
        String stringtosign = 'GET\n\n\n'+Lexpires+'\n/'+bucketName+'/'+filename;
		AWS_Upload obj = new AWS_Upload();
        String signed = obj.make_sig(stringtosign);
        String codedsigned = EncodingUtil.urlEncode(signed,'UTF-8');
        
        String url = 'http://'+bucketName+'.s3.amazonaws.com/'+filename+'?AWSAccessKeyId=AKIAI726C5DGTQH7UGNA&Expires='+Lexpires+'&Signature='+signed;
        //url += 'response-content-disposition=attachment;'+filename;
        system.debug('filename__________________'+filename);
        newDocument.Document_URL__c = url;	    
		   
		 insert  newDocument;
		 return newDocument;  
	}
	
	@RemoteAction
	public static string getAccessKey()
	{
		return  AWS_Keys__c.getInstance('biznussoft').AWS_AccessKey_Id__c;	
	}
	
	public boolean showUrl{get;set;}
	public string fileName{get;set;}
	public decimal expires{
		get
		{
			return (system.now().getTime())/1000;
		}
		set;}
	
	public void generateUrl()
	{
		showUrl = true;
		expires = (system.now().addHours(1).getTime())/1000;
		
	}
    
}