public class sendgrid2Mail {

	public class EmailData{
        String sender;
        String personalizations;
        String content;
        String category;
        List<String> emails;
        String errorMessage = null; 
    }

    public EmailData getEmailData(EmailTemplate emailTemplate, List<String> emailList, String sender, Map<String,String> p) {
        String subject;
        String content;
        String substitutions = '';
    	EmailData emailData = new EmailData();

	    if (sender == null){
	        List<OrgWideEmailAddress> owas = [select id, Address, DisplayName from OrgWideEmailAddress];
	        if(owas.size() > 0) {
	            System.debug('owas = ' + owas);
	            OrgWideEmailAddress owa = owas[0];  
	            System.debug('owa = ' + owa);             
	            sender = owa.Address;
        	} else {
	            emailData.errorMessage = 'No sender email configured.';
	            return emailData;            
	    	}

	        if(emailTemplate != null){
	            //set and replace body with data
	            subject = emailTemplate.Subject;
	            if (String.isBlank(emailTemplate.HTMLValue)) {
	                content = 
	                        '{' +
	                            '"type": "text/plain",' +
	                            '"value": "' + emailTemplate.Body.replace('\r\n', ' \\n') + '"' +   
	                        '}';
	            } else {
                    String precontent1 = emailTemplate.HTMLValue.replace('{!EmailMessage.EmailPersonalization__c}',p.get('memberName'));
                    String precontent2 = precontent1.replace('{!EmailMessage.EmailPersonalization2__c}',p.get('link'));
                    String precontent3 = precontent2.replace('{!FieloPLT__Program__c.Name}',p.get('program'));
	                content =                       
	                        '{' +
	                            '"type": "text/html",' +
	                            '"value": "' + precontent3.replace('<![CDATA[','').replace(']]>','').escapeJava() + '"' +                              
	                        '}';
	            }
	        }else{
	            emailData.errorMessage = 'Email template not found or not active.';
	        	return emailData;
	        }
		}

	    String category = '';
	    String personalizations = '';           
	    System.debug('emailList = ' + emailList);                   
	    for(String email : emailList){
	        if(!String.isBlank(personalizations)) {
	            personalizations += ',';    
	        }
	        personalizations += 
	                            '{' +
	                                '"to": [' +
	                                    '{' +
	                                        '"email": "' + email + '"' +                  
	                                    '}' +                           
	                                '],' +
	                                '"subject": "' + subject + '",' +
	                                //'"substitutions": ' + substitutions +
	                            '}';
	    }

	    emailData.sender = sender;
	    emailData.content = content;    
	    emailData.personalizations = personalizations;
	    emailData.emails = emailList;
	    emailData.category = category;
	    return emailData;
    }   
    
    public static HttpResponse makeSendCallout(EmailData emailData) {
        String body =   '{' +
                            '"personalizations": [' + 
                                emailData.personalizations + 
                            '],' +
                            '"from": ' + 
                                '{' +
                                '"email": "' + emailData.sender + '"' +
                                '},' +
                            '"content": [' +
                                emailData.content +
                            ']' +       
                            emailData.category +            
                        '}';
        System.debug('Before callout - body = ' + body);        

        HttpResponse response = sendgridMail.makeCallout('https://api.sendgrid.com/v3/mail/send', 'POST', body);

        System.debug('emailData.emails = ' + emailData.emails);     
        System.debug('response: ' + response.getStatus()); 
  
        return response;                                        
    }

    public static HttpResponse makeCallout(String endpoint, String method, String body) {  // Create method type
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod(method);
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setHeader('Authorization', 'Bearer ' + FieloPLT__PublicSettings__c.getOrgDefaults().FieloPLT_SendgridApiKey__c);
        
        if (!String.isBlank(body)) {
            request.setBody(body);
        }
        HttpResponse response = new Http().send(request);
        System.debug('Call response >>> ' + response.getStatusCode() + ' ' + response.getStatus());
        return response;
    }   
}