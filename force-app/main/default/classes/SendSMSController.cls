global with sharing class SendSMSController
{
	public string message {get;set;}
	
	public SendSMSController()
	{
	}
	
	public void sendSMS()
	{
		//string phone = ApexPages.currentPage().getParameters().get('phone');
		//string response = SendSMS.SendEmailNotification( phone, message ); 
		try
        {
            string phNo = ApexPages.currentPage().getParameters().get('phone');
            if( string.isNotBlank(phNo) )
                SMSClickatell.sendSMS( phNo,'test');
        }
        catch( exception e )        
        {
            ApexPages.addMessages(e);
        }
	}
	
	WebService static string sendSMS( string phNo, string message )
	{
	    string status =  SMSClickatell.sendSMS( phNo, message);
	    //status = ( status == 'OK') ? 'Success' : status;
	    return status;
	}
}