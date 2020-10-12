global class CLASS_NAME 
{
    webservice static void sendSMS()
    {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('http://api.clickatell.com/http/sendmsg?user=vasu.takasi&password=RZOARDKBOECKcO&api_id=3602445&to=918978136582&text=Hi%20dear');
        req.setMethod('POST');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug(res.getBody());
        //return GSAJSONParser.parse(res.getBody());
    }
}