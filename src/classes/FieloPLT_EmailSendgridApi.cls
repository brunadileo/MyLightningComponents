global class FieloPLT_EmailSendgridApi implements FieloPLT.EmailProviderInterface {

    private class EmailData{
        String sender;
        String personalizations;
        String content;
        String category;
        Set<Id> emails;
        String errorMessage = null; 
    }

    private class EmailResult{
       Set<Id> sentEmails;
       Map<Id, String> errorEmails;
    }   

    public void sendTransactionalEmails(Set<Id> emailAlertIds, Map<Id,Map<String,String>> dataValues) {
        List<FieloPLT__EmailAlert__c> emails = [SELECT FieloPLT__EmailTemplate__r.FieloPLT__TemplateUniqueName__c, FieloPLT__ToAddress__c FROM FieloPLT__EmailAlert__c WHERE Id in : emailAlertIds ORDER BY FieloPLT__EmailTemplate__r.FieloPLT__TemplateUniqueName__c];
        EmailResult emailResult = sendEmailsGroupedByTemplate(emails, dataValues);

        List<FieloPLT__EmailAlert__c> emailsToUpdate = new List<FieloPLT__EmailAlert__c>();
        for(Id sentEmailId : emailResult.sentEmails){
            emailsToUpdate.add(new FieloPLT__EmailAlert__c(Id = sentEmailId, FieloPLT__Status__c = 'Sent'));
        }
        for(Id errorEmailId : emailResult.errorEmails.keySet()){
            emailsToUpdate.add(new FieloPLT__EmailAlert__c(Id = errorEmailId, FieloPLT__Status__c = 'Error', FieloPLT__ErrorDescription__c = formatErrorDescription(emailResult.errorEmails.get(errorEmailId))));
        }       
        update emailsToUpdate;
    }       

    private EmailResult sendEmailsGroupedByTemplate(List<FieloPLT__EmailAlert__c> emails, Map<Id,Map<String,String>> dataValues){

        EmailResult emailResult = new EmailResult(); 
        Set<Id> sentEmails = new Set<Id>();
        Map<Id, String> errorEmails = new Map<Id, String>();

        Map<String,List<FieloPLT__EmailAlert__c>> emailAlertsbyTemplateMap = new Map<String,List<FieloPLT__EmailAlert__c>>();

        Set<String> emailTemplateNames = new Set<String>();
        Set<String> packagePrefixes = new Set<String>{null,''};
        for(FieloPLT__EmailAlert__c ea : emails){
            if(emailAlertsbyTemplateMap.containsKey(ea.FieloPLT__EmailTemplate__r.FieloPLT__TemplateUniqueName__c)){
                emailAlertsbyTemplateMap.get(ea.FieloPLT__EmailTemplate__r.FieloPLT__TemplateUniqueName__c).add(ea);
            }else{
                emailAlertsbyTemplateMap.put(ea.FieloPLT__EmailTemplate__r.FieloPLT__TemplateUniqueName__c, new List<FieloPLT__EmailAlert__c>{ea});
            }

            List<String> fieldMeta = ea.FieloPLT__EmailTemplate__r.FieloPLT__TemplateUniqueName__c.split('__');
            if(fieldMeta.size() > 1){
                packagePrefixes.add(fieldMeta[0]);
                emailTemplateNames.add(fieldMeta[1]);
            }else{
                emailTemplateNames.add(ea.FieloPLT__EmailTemplate__r.FieloPLT__TemplateUniqueName__c);
            }
        }

        List<EmailTemplate> emailTemplates = [SELECT Id, Body, NamespacePrefix, HTMLValue, Subject, DeveloperName FROM EmailTemplate WHERE IsActive = true AND DeveloperName in : emailTemplateNames AND NamespacePrefix in : packagePrefixes];
        Map<String,EmailTemplate> emailTemplatesMap = new Map<String,EmailTemplate>();

        for (EmailTemplate et: emailTemplates) {
            String devName = String.isBlank(et.NamespacePrefix) ? et.DeveloperName : et.NamespacePrefix + '__' + et.DeveloperName;
            emailTemplatesMap.put(devName, et);
        }

        Integer callOutsCounter = 0;
        for(String templateName : emailAlertsbyTemplateMap.keySet()){
            if(callOutsCounter <= 10){
                
                EmailData emailData = getEmailData(emailTemplatesMap.get(templateName), emailAlertsbyTemplateMap.get(templateName), dataValues, 'FieloPLT__ToAddress__c');
                if (String.isBlank(emailData.errorMessage)) {
	                HttpResponse response = makeSendCallout(emailData);

	                if (responseOk(response.getStatusCode())) {
	                    // Update list of sent emails for changing the status later (not now because it would cause "uncommitted" error)
	                    sentEmails.addAll(emailData.emails);
	                } else {
	                    // Update list of emails with errors
	                    for(Id emailId : emailData.emails) {
	                        errorEmails.put(emailId, formatErrorDescription(response.getBody()));
	                    }
	                }           
	                callOutsCounter++;                	
                } else {
                    // Update list of emails with errors
                    for(SObject email : emailAlertsbyTemplateMap.get(templateName)) {
                        errorEmails.put(email.Id, emailData.errorMessage);
                    }
                }
            }else{
                break;
            }
        }
        emailResult.sentEmails = sentEmails;
        emailResult.errorEmails = errorEmails;
        return emailResult;
    }

    private Boolean sendCampaignEmails(Map<Id,FieloPLT__Member__c> membersMap, EmailTemplate emailTemplate, Map<Id,Map<String,String>> memberValues, String campaignStringId, Id campaignId){
        Boolean success;
        System.debug('membersMap.values() = ' + membersMap.values());
        EmailData emailData = getEmailData(emailTemplate, membersMap.values(), memberValues, 'FieloPLT__Email__c', campaignStringId);
        if (String.isBlank(emailData.errorMessage)) {
	        HttpResponse response = makeSendCallout(emailData);       
	        if (!responseOk(response.getStatusCode())) {
	            update new FieloPLT__EmailCampaign__c(Id = campaignId, FieloPLT__ErrorDescription__c = formatErrorDescription(response.getBody()));
	            success = false;
	        }else {
	            success = true; 
	        }
    	} else {
			update new FieloPLT__EmailCampaign__c(Id = campaignId, FieloPLT__ErrorDescription__c = emailData.errorMessage); 
    		success = false;
    	}
        return success;
    }

    private EmailData getEmailData(EmailTemplate emailTemplate, List<SObject> emailList, Map<Id,Map<String,String>> dataValues, String emailField) {
        return getEmailData(emailTemplate, emailList, dataValues, emailField, null);
    }

    private EmailData getEmailData(EmailTemplate emailTemplate, List<SObject> emailList, Map<Id,Map<String,String>> dataValues, String emailField, String campaignStringId) {
        String sender;
        String subject;
        String content;
        EmailData emailData = new EmailData();

        List<OrgWideEmailAddress> owas = [select id, Address, DisplayName from OrgWideEmailAddress];
        If (owas.size() > 0) {
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
                content =                       
                        '{' +
                            '"type": "text/html",' +
                            '"value": "' + emailTemplate.HTMLValue.replace('<![CDATA[','').replace(']]>','').escapeJava() + '"' +                              
                        '}';
            }
        }else{
            emailData.errorMessage = 'Email template not found or not active.';
        	return emailData;
        }

        String category = '';
        if (!String.isBlank(campaignStringId)) {
            category =  ', "categories": [' +
                            '"' + campaignStringId + '"' +
                        ']';
        }

        String personalizations = '';
        Set<Id> emails= new Set<Id>();   
        System.debug('emailList = ' + emailList);                   
        for(SObject email : emailList){
            emails.add(email.Id);
            Map<String,String> sub = (dataValues != null ? dataValues.get(email.Id) : null);
            String substitutions = '';
            if(sub != null){
                for(String field : sub.keySet()){
                    if (substitutions != '') {
                        substitutions += ',';
                    }                           
                    String key = '{!'+ field + '}';
                    substitutions += '"' + key + '": "' + sub.get(field) + '"';
                }
                substitutions = '{' + substitutions + '}';
            } else {
                substitutions = '{}';
            }

            if(!String.isBlank(personalizations)) {
                personalizations += ',';    
            }
            personalizations += 
                                '{' +
                                    '"to": [' +
                                        '{' +
                                            '"email": "' + email.get(emailField) + '"' +                  
                                        '}' +                           
                                    '],' +
                                    '"subject": "' + subject + '",' +
                                    '"substitutions": ' + substitutions +
                                '}';
        }
        emailData.sender = sender;
        emailData.content = content;    
        emailData.personalizations = personalizations;
        emailData.emails = emails;
        emailData.category = category;
        return emailData;
    }   

    private HttpResponse makeSendCallout(EmailData emailData) {
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

        HttpResponse response = makeCallout('https://api.sendgrid.com/v3/mail/send', 'POST', body);

        System.debug('emailData.emails = ' + emailData.emails);     
        System.debug('response.getBody() = ' + response.getBody()); 
  
        if (!responseOk(response.getStatusCode())) {
            // Handle errors here?
        }
        return response;                                        
    }   

    private HttpResponse makeCampaignCallout(String externalId, Date campaignDate) {
        String datePar = DateTime.newInstance(campaignDate.year(), campaignDate.month(), campaignDate.day()).format('yyyy-MM-dd');
        return makeCallout('https://api.sendgrid.com/v3/categories/stats?start_date=' + datePar + '&end_date=' + datePar + '&aggregated_by=day&categories=' + externalId, 'GET');
    }   

    private HttpResponse makeCallout(String endpoint, String method) {
        return makeCallout(endpoint, method, null);
    }

    private HttpResponse makeCallout(String endpoint, String method, String body) {  // Create method type
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

    private Boolean responseOk(Integer code) {
        return (code >= 200 && code <= 299);
    }

    public void startCampaign(Id campaignId) {
        update new FieloPLT__EmailCampaign__c(Id = campaignId, FieloPLT__Status__c = 'InProgress');
    }

    public Boolean executeCampaign(Id campaignId, Set<Id> memberIds, Map<Id,Map<String,String>> memberValues) {
    	Boolean success;
    	System.debug('memberIds = ' + memberIds);
        FieloPLT__EmailCampaign__c emailCampaign = [SELECT FieloPLT__CampaignId__c, FieloPLT__EmailTemplate__r.FieloPLT__TemplateUniqueName__c, FieloPLT__EmailTemplate__r.FieloPLT__FieldSet__c FROM FieloPLT__EmailCampaign__c WHERE Id =: campaignId];
        Map<Id,FieloPLT__Member__c> membersMap = new Map<Id,FieloPLT__Member__c>([SELECT FieloPLT__Email__c FROM FieloPLT__Member__c WHERE Id in : memberIds]);
        // TODO: NO TEMPLATE = ERROR

        String packagePrefix;
        String devName;
        List<String> metaFields = emailCampaign.FieloPLT__EmailTemplate__r.FieloPLT__TemplateUniqueName__c.split('__');
        if(metaFields.size() > 1){
            packagePrefix = metaFields[0];
            devName = metaFields[1];
        }else{
            devName = emailCampaign.FieloPLT__EmailTemplate__r.FieloPLT__TemplateUniqueName__c;
        }

        // Send the emails
        List<EmailTemplate> emailTemplates = [SELECT Id, Body, HTMLValue, Subject, DeveloperName FROM EmailTemplate WHERE IsActive = true AND DeveloperName =: devName AND NamespacePrefix =: packagePrefix];
        if(emailTemplates.size() > 0) {
            EmailTemplate emailTemplate = emailTemplates[0];        
            try {
                success = sendCampaignEmails(membersMap, emailTemplate, memberValues, emailCampaign.FieloPLT__CampaignId__c, campaignId);        	
            } catch(Exception e) {
    			update new FieloPLT__EmailCampaign__c(Id = campaignId, FieloPLT__ErrorDescription__c = formatErrorDescription(e.getMessage()));
            	success = false;
            }
        } else {
            update new FieloPLT__EmailCampaign__c(Id = campaignId, FieloPLT__ErrorDescription__c = 'Email template not found or not active.');            
            success = false;            
        }
        return success;
    }

    public void finishCampaign(Id campaignId, Boolean success, Id jobId) {
        if(success){
            update new FieloPLT__EmailCampaign__c(Id = campaignId, FieloPLT__Status__c = 'Sent');
        } else {
            update new FieloPLT__EmailCampaign__c(Id = campaignId, FieloPLT__Status__c = 'Error');
        }
    }

    public Map<String,Integer> getStatistics(String campaignId) {
        Map<String, Integer> result;
        FieloPLT__EmailCampaign__c emailCampaign = [SELECT FieloPLT__CampaignId__c, FieloPLT__Date__c FROM FieloPLT__EmailCampaign__c WHERE Id =: campaignId];
        HttpResponse response = makeCampaignCallout(emailCampaign.FieloPLT__CampaignId__c, emailCampaign.FieloPLT__Date__c);
        if (responseOk(response.getStatusCode())) {
            Object data = ((List<Object>) JSON.deserializeUntyped(response.getBody()))[0];           
            Object stats = ((List<Object>)((Map<String, Object>) data).get('stats'))[0];
            Map<String, Object> metrics = (Map<String, Object>)((Map<String, Object>) stats).get('metrics');
            result = new Map<String, Integer>();
            for(String strKey: metrics.keyset()){
                result.put(strKey, Integer.valueof(metrics.get(strKey)));
            }           
        } else {
            // TODO: handle errors
        }
        return result;
    }

	private String formatErrorDescription(String errorDescription) {
        return errorDescription.Length() >= 255 ? errorDescription.substring(0, 255) : errorDescription;
	}
}