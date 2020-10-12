public class AccountSDriveManagerController 
{
    public AWS_Keys__c awsKeySet {get;set;}
    public string policy {get;set;}
    public string signedPolicy {get;set;}
    public string acessType {get;set;}
    public string contentType {get;set;}
    public string forRedirect {get;set;}
    public boolean uploadDoc {get;set;}
    public string fileName {get;set;}
    public string urlString {get;set;}
    public boolean isCopyURL {get;set;}
    public boolean isEdit {get;set;}
    public boolean isEmail {get;set;}
    public string recordId {get;set;}
    public Document__c objDocument {get;set;}
    public string searchString {get;set;}
    public Document__c[] selectedDocs{get;set;}
    
    public string subject{get;set;}
    public string toAddress{get;set;}
    public string ccAddress{get;set;}
    public string bccAddress{get;set;}
    public string emailBody{get;set;}
	public AccountSDriveManagerController(ApexPages.StandardController con)
    {
        awsKeySet = AWS_Keys__c.getInstance('biznussoft');
        contentType ='multipart/form-data';
        acessType ='private';
        uploadDoc = false;
        isCopyURL = false;
        isEdit = false;
        isEmail = false;
        objDocument = new Document__c();
        selectedDocs = new Document__c[]{};
    }
    public pagereference createDocument()
    {
        try
        {
        	string temp = ApexPages.currentPage().getParameters().get('temp');
            string accId = ApexPages.currentPage().getParameters().get('id');
        	system.debug('_________'+temp);
        	return null;
            string descrptn = ApexPages.currentPage().getParameters().get('description');
            string fileName = ApexPages.currentPage().getParameters().get('key');
            if( string.isNotBlank(fileName) )
            {
                list<Document__c> lstDocs = [select Id FROM Document__c WHERE Document_Name__c =:fileName];
                if( lstDocs.isEmpty() )
                {
                    Document__c objDoc = new Document__c(
                                             Document_Name__c = fileName,
                                             Status__c = 'Uploaded',
                                             Description__c = descrptn,
                        					 Account__c = accId	
                                            );
                    insert objDoc;                        
                } 
            }
        }
        catch(exception e)
        {
            ApexPages.addMessages(e);
        }
        return null;
    }
    
    public DocumentsWrap[] lstDocs{get;set;}
    public list<DocumentsWrap> getAWSDocuments()
    {
        lstDocs = new DocumentsWrap[]{};
         string accId = ApexPages.currentPage().getParameters().get('id');
    	for( Document__c objDoc: [select Id, 
				                       Name, 
				                       Document_Name__c, 
				                       Status__c, 
				                       Description__c,
				                       Size__c,
				                       Application__c
				                       FROM Document__c 
				                       WHERE Size__c != null
                                       AND Account__c = :accId
				                       ORDER BY Document_Name__c])
		{
			DocumentsWrap obj = new DocumentsWrap();
			obj.checked = false;
			obj.objDoc = objDoc;
			lstDocs.add(obj);
		}				   
		return lstDocs;      
    }
    
    public void cancelUpload()
    {
        uploadDoc = false;
    }
    
    public void composeMail()
    {
    	selectedDocs.clear();
    	toAddress = '';
    	ccAddress = '';
    	bccAddress = '';
    	subject = '';
    	emailBody = '';
    	for( DocumentsWrap obj : lstDocs )
    	{
    		if( obj.checked )
    			selectedDocs.add(obj.objDoc);
    	}
    }
    
    public void uploadDocument()
    {
        uploadDoc = true;
        string accId = ApexPages.currentPage().getParameters().get('id');
        Datetime expire = system.now().addHours(1);
        string formattedexpire = expire.formatGmt('yyyy-MM-dd')+'T'+ expire.formatGmt('HH:mm:ss')+'.'+expire.formatGMT('SSS')+'Z';
        forRedirect = URL.getSalesforceBaseUrl().toExternalForm()+'/'+'apex/AccountSDriveManager?expire='+expire.getTime()+'&id='+accId;
        string tempPolicy = '{ "expiration": "'+formattedexpire+'","conditions": [ {"bucket": "'+
                             awsKeySet.Name +'" } ,{ "acl": "'+acessType+'" },'+
                            '{"content-type":"'+contentType+'"},'+
                            '{"success_action_redirect": "'+ForRedirect+'"},' +
                            '["starts-with", "$key", ""] ]}';  
        policy = EncodingUtil.base64Encode(Blob.valueOf(tempPolicy));
        signedPolicy = make_sig(EncodingUtil.base64Encode(Blob.valueOf(tempPolicy)));
    }
    
    //method that will sign
    private String make_sig(string canonicalBuffer) 
    {        
        String macUrl ;
        Blob mac = Crypto.generateMac('HMacSHA1', blob.valueof(canonicalBuffer),blob.valueof(awsKeySet.AWS_Secret_Key__c)); 
        macUrl = EncodingUtil.base64Encode(mac);                
        return macUrl;
    }
    
    public PageReference downloadFile()
    {
    	urlString = '';
    	if( string.isNotBlank(fileName) )
        {
        	string bucketName = awsKeySet.Name;
            String fileNameTemp = EncodingUtil.urlEncode(fileName, 'UTF-8');        
            Datetime now = DateTime.now();
            Datetime expireson = now.AddDays(120);
            Long Lexpires = expireson.getTime()/1000;
            
            String stringtosign = 'GET\n\n\n'+Lexpires+'\n/'+bucketName+'/'+fileNameTemp;
            String signed = make_sig(stringtosign);
            urlString = 'http://'+bucketName+'.s3.amazonaws.com/'+fileNameTemp;
            urlString += '?AWSAccessKeyId=AKIAI726C5DGTQH7UGNA&Expires='+Lexpires+'&Signature='+signed;
        }
        return null;
    }
    
    public string openObject()
    {
    	string contentType = 'image/jpg';
		string filename = 'loadernew.gif';
		string contentDisposition = 'inline; fileName="loadernew.gif"; filename*=UTF-8\'\''+fileName;//EncodingUtil.urlEncode(fileName, 'UTF-8');
        
        if( string.isNotBlank(fileName) )
        {
            string bucketName = awsKeySet.Name;
            String fileNameTemp = EncodingUtil.urlEncode(fileName, 'UTF-8');        
            Datetime now = DateTime.now();
            Datetime expireson = now.AddDays(120);
            Long Lexpires = expireson.getTime()/1000;
            
            String fileNameTemp2 = EncodingUtil.urlEncode('response-content-disposition=inline;filename='+fileName, 'UTF-8');
                   
            //String stringtosign = 'GET\n\n\n'+Lexpires+'\n/'+bucketName+'/'+fileNameTemp;
            //String stringtosign = 'GET\n\n\n'+'response-content-disposition=inline;filename='+fileNameTemp+'\n&'+Lexpires+'\n/'+bucketName+'/'+fileNameTemp;
            string stringToSign = 'GET\n\n\n'+Lexpires+'\n/'+bucketName+'/'+fileNameTemp+'\n';
            	   //stringToSign += 'image/jpg'+'\n';
            	   stringToSign += 'response-content-disposition='+':'+contentDisposition;
            //stringToSign = EncodingUtil.urlEncode(stringToSign,'UTF-8');
            String signed = make_sig(stringtosign);
            //String codedsigned = EncodingUtil.urlEncode(signed,'UTF-8');
            
            String url = 'http://'+bucketName+'.s3.amazonaws.com/'+fileNameTemp;
            url += '?response-content-disposition='+EncodingUtil.urlEncode(contentDisposition,'UTF-8');
            url += '&AWSAccessKeyId=AKIAI726C5DGTQH7UGNA&Expires='+Lexpires+'&Signature='+signed;
            //url += '&response-content-type='+EncodingUtil.urlEncode('image/jpg','UTF-8');
            return url;
        }
        return '';
    }
    
     @RemoteAction
	public static void createNewDocument(string fName, string fileType, string description, integer size, string accId)
	{
		list<Document__c> lstExistedDocs = [select Id FROM Document__c WHERE Document_Name__c =:fName AND Account__c =:accId LIMIT 1];
		system.debug('size_____________'+lstExistedDocs);
        //string accId = ApexPages.currentPage().getParameters().get('id');
		if( lstExistedDocs.isEmpty() )
		{
			Document__c objDoc = new Document__c();
			objDoc.Document_Name__c = fName;
			objDoc.Application__c = fileType;
			objDoc.Description__c = description;
			objDoc.Size__c = size;
            objDoc.Account__c = accId;
			system.debug('___________'+objDoc);
			insert objDoc;
		}
	}
	
	public void editDocument()
	{
		if( string.isNotBlank(recordId) )
		{
			isEdit = true;
			objDocument = [select Id, Document_Name__c, Description__c FROM Document__c WHERE Id = :recordId];			
		}
	}
	
	public void updateDocument()
	{
		try
		{
			update objDocument;
			isEdit = false;
		}
		catch(exception e)
		{
			ApexPages.addMessages(e);
		}
	}
	
	public void deleteObject()
	{
		try
		{
			if( string.isNotBlank(fileName) )
            {
				S3.AmazonS3 as3 = new S3.AmazonS3(awsKeySet.AWS_AccessKey_Id__c,awsKeySet.AWS_Secret_Key__c);
				Datetime now = Datetime.now();        
				S3.Status deleteObjectReslt = as3.DeleteObject(awsKeySet.Name,fileName,as3.key,now,as3.signature('DeleteObject',now), as3.secret);
			
                list<Document__c> lstDocs = [select Id FROM Document__c WHERE Document_Name__c =:fileName];
                if( !lstDocs.isEmpty() )
                {
                    delete lstDocs;                
                } 
            }
		}
		catch(exception e)
		{
			ApexPages.addMessages(e);
		}
	}
	
	public void sendEmail()
	{
		try
		{
			Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>{};
			string attachments = '<p><b>Attachments:</b></P>';
			for( Document__c objDoc : selectedDocs )
			{
				fileName = objDoc.Document_Name__c;
				downloadFile();
				attachments += '<a href="'+urlString+'">'+objDoc.Document_Name__c+'</a><br/>'; 
			}
			Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
			message.toAddresses = toAddress.split(',');
			if( string.isNotBlank(ccAddress) )
				message.ccAddresses = ccAddress.split(',');
			if( string.isNotBlank(bccAddress) )
				message.bccAddresses = bccAddress.split(',');	
			//message.optOutPolicy = 'FILTER';
			message.subject = subject;
			message.htmlBody = '<p>'+emailBody+'</p>'+attachments;
			messages.add(message);
			Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
			isEmail = false;
		}
		catch(exception e)
		{
			apexPages.addMessages(e);
		}
	}
	
	public list<Contact> getContacts()
	{
		if( string.isNotBlank(searchString) )
		{
			string temp = '%'+searchString+'%';
			return [select Name, Email FROM Contact WHERE Name like :temp ];
		}
		else
		{
			return [select Name, Email FROM Contact WHERE LastViewedDate !=null];
		}
	}
	
	public class DocumentsWrap
	{
		public boolean checked{get;set;}
		public Document__c objDoc{get;set;}
	}
}