@isTest
public class modalControllerTest {
    @testSetup static void setup(){
        User u = new User(LastName = 'Test User', 
                          Email = 'bruna.dileo@test.com',
                          ProfileId = [SELECT Id FROM Profile WHERE Name LIKE '%Administrator' LIMIT 1].Id,
                          Username = 'bruna.dileo@test.com' + System.currentTimeMillis(),
                          CompanyName = 'TEST',
                          Title = 'title',
                          Alias = 'alias',
                          TimeZoneSidKey = 'America/Los_Angeles',
                          EmailEncodingKey = 'UTF-8',
                          LanguageLocaleKey = 'en_US',
                          LocaleSidKey = 'en_US');
        insert u;
        
        FieloPLT__Program__c p = new FieloPLT__Program__c(Name = 'Test Program');
        insert p;
        
        FieloPLT__Member__c m = new FieloPLT__Member__c(Name = 'Test Member', 
                                                        FieloPLT__Email__c = 'bruna.dileo@fielo.com',
                                                        FieloPLT__User__c = u.Id,
                                                        FieloPLT__Program__c = p.Id);
        insert m;
        
        FieloPLT__Settings__c s = new FieloPLT__Settings__c(CurrentMemberId__c = m.Id);
        
    }
    
    @isTest static void testSendEmail(){
        List<String> emails = new List<String>();
        emails.add('test@test.com');
        String subject = 'Test subject';
        String message = 'Test message';
        
        String resp = modalController.sendMail(emails,subject,message);
        System.assertEquals('Email sent!', resp);
    }
    
    @isTest static void testGetMember(){
       Id p = [select id from profile where name='Fielo Partner Community User'].Id;
       
        Account ac = new Account(name ='TestAcc') ;
        insert ac; 
       
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id);
        insert con;  
                  
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = con.Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com'+ System.currentTimeMillis());
       
        insert user;
        
        System.debug('user: '+ user);
        
        System.runAs(user){
            
            System.debug('Current User: ' + UserInfo.getUserId());
            
            FieloPLT__Member__c m = modalController.getMember();
            System.assert(m !=null);
        }

    }
}