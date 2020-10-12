public with sharing class SMSSenderController 
{
	public static void sendSMS(string mobileNo, string message)
	{
		HTTP objHTTP = new HTTP();
		HttpRequest req = new HttpRequest();
		string endPoint = 'http://api.mVaayoo.com/mvaayooapi/MessageCompose?user=balusfdc3@gmail.com:balu3377';
		endPoint += '&senderID=TEST SMS&receipientno='+mobileNo+'&dcs=0&msgtxt='+message+'&state=4';
		req.setEndpoint(endPoint);
		req.setMethod('GET');
		//req.setBody('');
		HttpResponse objRes = objHTTP.send(req);
		system.debug(objRes);
        
         req = new HttpRequest();        
string endPointURL = 'https://api.clickatell.com/rest/message';
req.setHeader( 'Content-Type','application/json' );
req.setHeader( 'Authorization','bearer_3VvpzRwsQs68dWHFxIDCWA==' );
req.setHeader( 'Accept','application/json' );
req.setHeader('X-Version','1');
string str = '<request>{"text":"Test Message","to":["+917675914757"]}</request>';
req.setBody(str);
req.setEndpoint(endPointURL);
req.setMethod('POST');
Http http = new Http();
HTTPResponse res = http.send(req);
System.debug(res.getStatus());
	}
}