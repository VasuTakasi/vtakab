global class XeroInvoiceProcess
{
   // @webService
    webservice static string createInvoiceInXero( string invoiceId )
    {
        try
        {
            if( string.isNotBlank(invoiceId) )
            {
                Invoice__c objInvoice = [ select Date__c, 
                                                 Due_Date__c, 
                                                 Line_Amount_Types__c, 
                                                 Type__c,
                                                 Xero_Invoice_Id__c,
                                                 Contact__r.Name,
                                                 ( select 
                                                    Account_Code__c,
                                                    Description__c,
                                                    Quantity__c,
                                                    Unit_Amount__c
                                                    FROM
                                                    Line_Items__r
                                                     )
                                                 FROM Invoice__c
                                                 WHERE Id = :invoiceId
                                                 ];
                string strXML = '<Invoices>';     
                       strXML += '<Invoice>';
                       strXML += '<Type>';
                       strXML += objInvoice.Type__c;
                       strXML += '</Type>';
                       strXML += '<Contact>';
                       strXML += '<Name>'+objInvoice.Contact__r.Name+'</Name>';
                       strXML += '</Contact>';
                       strXML += '<Date>';
                       strXML += (objInvoice.Date__c+'');//.replace(' ','T');
                       strXML += '</Date>';
                       strXML += '<DueDate>';
                       strXML += (objInvoice.Due_Date__c+'');//.replace(' ','T');
                       strXML += '</DueDate>';
                       strXML += '<LineAmountTypes>';
                       strXML += objInvoice.Line_Amount_Types__c;
                       strXML += '</LineAmountTypes>';
                       strXML += '<LineItems>';
                       for( Line_Item__c objLI : objInvoice.Line_Items__r )
                       {
                          strXML += '<LineItem>'; 
                          strXML += '<Description>'; 
                          strXML += objLI.Description__c; 
                          strXML += '</Description>'; 
                          strXML += '<Quantity>'; 
                          strXML += objLI.Quantity__c; 
                          strXML += '</Quantity>'; 
                          strXML += '<UnitAmount>'; 
                          strXML += objLI.Unit_Amount__c; 
                          strXML += '</UnitAmount>'; 
                          strXML += ' <AccountCode>'+objLI.Account_Code__c+'</AccountCode>';
                          strXML += '</LineItem>'; 
                       }
                       strXML += '</LineItems>';
                       strXML += '</Invoice>';
                       strXML += '</Invoices>';
               HttpResponse response = XeroPrivateConnection.syncXeroSFDC('POST','Invoices',strXML);   
               system.debug('response____'+response.getBody());
               if( response.getStatus() == 'OK' )
               {
                    Dom.Document document = new Dom.Document();
                    document.load(response.getBody());
                    DOM.XMLNode root = document.getRootElement();
                    
                    Dom.XMLNode invoices = root.getChildElement('Invoices',null);
                    Dom.XMLNode invoice = invoices.getChildElement('Invoice',null);
                    
                    string invId = invoice.getChildElement('InvoiceID',null).getText();
                    system.debug('invId___________'+invId);
                    objInvoice.Xero_Invoice_Id__c = invId;
                    update objInvoice;
                    /*
                    for(integer i=0;i<invoice.getChildElements().size();i++)
                    {
                        Dom.XMLNode invBody= invoice.getChildElements()[i];
                        system.debug('Name___________'+invBody.getName());
                    }
                    */
            }  
            return response.getStatus();          
          }
        }
        catch(Exception e)
        {
          return e.getMessage();
        }
        return 'Success';
    }
    
     webservice static string createContactInXero( string contactId )
     {
        try
        {
            if( string.isNotBlank(contactId) )
            {
                Contact objContact = [select Id,
                                              Phone,
                                              FirstName,
                                              LastName,
                                              Name,
                                              Email,
                                              XERO_Contact_Id__c
                                              FROM Contact
                                              WHERE 
                                              Id =:contactId];
                string strXML = '<Contacts>'; 
                       strXML += '<Contact>';
                       strXML += '<ContactNumber>';
                       strXML += objContact.Phone;
                       strXML += '</ContactNumber>';
                       strXML += '<Name>';
                       strXML += objContact.Name;
                       strXML += '</Name>';
                       strXML += '<EmailAddress>';
                       strXML += objContact.Email;
                       strXML += '</EmailAddress>';
                       strXML += '<FirstName>';
                       strXML += objContact.FirstName;
                       strXML += '</FirstName>';
                       strXML += '<LastName>';
                       strXML += objContact.LastName;
                       strXML += '</LastName>';
                       strXML += '</Contact>';
                       strXML += '</Contacts>';   
                       
                      // strXML = '<Contacts><Contact><Name>Leena</Name></Contact></Contacts>';                                         
                 HttpResponse response = XeroPrivateConnection.syncXeroSFDC('POST','Contacts',strXML);  
                 if( response.getStatus() == 'OK' )
                 {
                    Dom.Document document = new Dom.Document();
                    document.load(response.getBody());
                    DOM.XMLNode root = document.getRootElement();
                    
                    Dom.XMLNode Contacts = root.getChildElement('Contacts',null);
                    Dom.XMLNode Contact = Contacts.getChildElement('Contact',null);
                    
                    string conId = Contact.getChildElement('ContactID',null).getText();
                    objContact.XERO_Contact_Id__c = conId;
                    update objContact;
                 }  
                 return response.getStatus();             
            }
        }
        catch(exception e)
        {
            return e.getMessage();
        }
        return 'success';
     }
}