public class modalController {
    
    @AuraEnabled
    public static String sendMail(List<String> emails, String subject, String message,String templateName) { 
        Id templateId;
        List<String> subjects = new List<String>();
        subjects.add(subject); 
        List<String> messages = new List<String>();
        messages.add(message);
        if(templateName != null){
            templateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: templateName].Id; System.debug('templateId:'+templateId);
        }
        EmailManager.sendMail(emails, subjects,messages,templateId);
        return 'Email sent!';
    }
    
    @AuraEnabled
    public static FieloPLT__Member__c getMember(){
        FieloPLT__Settings__c settings = FieloPLT__Settings__c.getInstance(UserInfo.getUserId());
        System.debug('member: '+ settings.CurrentMemberId__c);
        if(settings.CurrentMemberId__c !=null){
            FieloPLT__Member__c m = [SELECT Id, Name, FieloPLT__Program__c,FieloPLT__Program__r.Name FROM FieloPLT__Member__c 
                                     WHERE Id =:settings.CurrentMemberId__c];
            
            return m;
        }else{
            FieloPLT__Member__c m = [SELECT Id, Name, FieloPLT__Program__c FROM FieloPLT__Member__c 
                                     WHERE Name = 'Test Member'];
            return m;
        }
        
        
    }
    
    @AuraEnabled
    public static String sgSendMail(List<String> emails,String emailTemplate, Map<String,String> p){
        EmailTemplate et = [SELECT Id,Name,DeveloperName,Subject,Body,HTMLValue FROM EmailTemplate 
                            WHERE DeveloperName =: emailTemplate];
        sendgrid2Mail sg = new sendgrid2Mail();
        sendgrid2Mail.EmailData emaildata = new sendgrid2Mail.EmailData();
        
        emaildata = sg.getEmailData(et,emails,null,p);
        HttpResponse res = sendgrid2Mail.makeSendCallout(emaildata);
        System.debug('res.getStatus(): '+res.getStatus());
        return res.getStatus();        
        
    }

    @AuraEnabled
    public static String getShortLink(String url){
        BitlyIntegration b = new BitlyIntegration();
        String shortUrl = b.shorten(url);
        return shortUrl;

    }
    
}