public class modalController {
    
    @AuraEnabled
    public static String sendMail(List<String> emails, String subject, String message) {        
        List<String> subjects = new List<String>();
        subjects.add(subject); 
        List<String> messages = new List<String>();
        messages.add(message);
        EmailManager.sendMail(emails, subjects,messages);
        return 'Email sent!';
    }
    
    @AuraEnabled
    public static FieloPLT__Member__c getMember(){
        FieloPLT__Settings__c settings = FieloPLT__Settings__c.getInstance(UserInfo.getUserId());
        System.debug('member: '+ settings.CurrentMemberId__c);
        if(settings.CurrentMemberId__c !=null){
            FieloPLT__Member__c m = [SELECT Id, Name, FieloPLT__Program__c FROM FieloPLT__Member__c 
                                     WHERE Id =:settings.CurrentMemberId__c];
            
            return m;
        }else{
            FieloPLT__Member__c m = [SELECT Id, Name, FieloPLT__Program__c FROM FieloPLT__Member__c 
                                     WHERE Name = 'Test Member'];
            return m;
        }
        
        
    }
    
    /*@AuraEnabled
public static Id createMember(String memberName, String email,Id memberId){
FieloPLT__Member__c n = [SELECT Id, FieloPLT__Program__c FROM FieloPLT__Member__c WHERE Id =:memberId];
System.debug(n);

Account[] a = [SELECT Id FROM Account];

Contact c = new Contact(LastName= memberName,
Email = email,
Account=a[0]);
insert c;

FieloPLT__Member__c m = new FieloPLT__Member__c(Name= memberName,
FieloPLT__Type__c='Individual Account',
FieloPLT__Email__c= email,
FieloPLT__Program__c = n.FieloPLT__Program__c,
FieloPLT__Status__c  = 'Pending User',
FieloPLT__Contact__c = c.Id);

insert m;
System.debug(m);
return m.Id;

}*/
    
}