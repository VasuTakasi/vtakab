global class SendSMS 
{
	WebService static string SendEmailNotification(string phoneNo, string messageBody) 
    {
        try{
            String ACCOUNT_SID = 'ACdc25b09c03aee2cb7752f1ab2c2a02d3';
            String AUTH_TOKEN = 'eb6fa00473bbdb59e787f2b11d71ba24';
            TwilioRestClient client = new TwilioRestClient(ACCOUNT_SID, AUTH_TOKEN);
            
            Map<String,String> properties = new Map<String,String> {
                    'To'   => phoneNo,//'+15708156896',
                    'From' => '+12678734043',
                    'Body' => messageBody
                };
            TwilioMessage message = client.getAccount().getMessages().create(properties);
            return 'Message has been sent.';
        }
        catch(exception e)
        {
            return e.getMessage();
        }
    }
    
    public void sendSMS()
    {
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
}