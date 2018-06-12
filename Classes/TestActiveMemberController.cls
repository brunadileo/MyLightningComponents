@isTest
public class TestActiveMemberController {
    @testSetup static void setup(){
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
    }
    
    @isTest static void checkResult(){
        
        FieloPLT__Member__c member = [SELECT Id, Name FROM FieloPLT__Member__c LIMIT 1];
        
        System.debug('member: '+ member);
        activeMemberController.setMember(member.Id);
        
        
        FieloPLT__Settings__c n = [SELECT CurrentMemberId__c FROM FieloPLT__Settings__c];
        System.debug(n);
        System.assert(n.CurrentMemberId__c == member.Id);
    }
}