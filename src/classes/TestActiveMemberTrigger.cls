@isTest
public class TestActiveMemberTrigger {
    @TestSetup static void setup(){
        User u = new User(LastName = 'Test User', 
                         Email = 'bruna.dileo@fielo.com',
                         ProfileId = [SELECT Id FROM Profile WHERE Name LIKE '%Administrator' LIMIT 1].Id,
                         Username = 'bruna.dileo@fielo.com' + System.currentTimeMillis(),
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
        System.debug(m.Id);
        System.debug(s);
        insert s;
        
 
    }
    
    @isTest static void testTrigger(){
        User user = [SELECT Id, Name FROM User WHERE LastName = 'Test User'];
        FieloPLT__Member__c member = [SELECT Id, Name FROM FieloPLT__Member__c LIMIT 1];
        System.debug('user: '+ user);
        System.debug('member: '+ member);
        
        System.runAs(user){
      		System.debug('Current User: ' + UserInfo.getUserId());
            Lead le = new Lead(LastName= 'Test Lead', Company='Test Company', Status='Open - Not Contacted');
            insert le;		
        }
        
        Lead leads = [SELECT Id,Member__c FROM Lead];
        System.debug(leads);
        System.assert(lead.Member__c != null);
            
    }
}