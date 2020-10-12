global class SMSClickatell 
{
    webservice static string sendSMS( string mobileNo, string message  )
    {
        HttpRequest req = new HttpRequest();
        
        string endPointURL = 'http://api.clickatell.com/http/sendmsg?user=vasu.takasi&password=RZOARDKBOECKcO&api_id=3602445&to=';
               endPointURL += mobileNo+'&text='+message;
        req.setEndpoint(endPointURL);
        req.setMethod('POST');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug(res.getStatus());
        return res.getStatus();
        //return GSAJSONParser.parse(res.getBody());
    }
}