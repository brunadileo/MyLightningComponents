global class NewRegistrationController {
    public NewRegistrationController() {
        
    }
    
    /*@TestVisible 
private static boolean isValidPassword(String password, String confirmPassword) {
return password == confirmPassword;
}


@TestVisible 
private static void validatePassword(User u, String password, String confirmPassword) {
if(!Test.isRunningTest()) {
Site.validatePassword(u, password, confirmPassword);
}
return;
}*/
    
    @AuraEnabled
    public static Map<String,String> getNames(Id memberId,Id programId){
        Map<String,String> lista = new Map<String,String>();
        FieloPLT__Program__c p = [SELECT Name FROM FieloPLT__Program__c WHERE Id =:programId];
        lista.put('program',p.Name);
        FieloPLT__Member__c m = [SELECT Name,FieloPLT__Program__c, FieloPLT__Program__r.Name FROM FieloPLT__Member__c WHERE Id =:memberId];
        lista.put('member',m.Name);
        return lista;
    }
    
    @AuraEnabled
    public static String selfRegister(String fields, Boolean createUser) {
        Savepoint sp = null;
        try {
            sp = Database.setSavepoint();
            Map<String,Object> fieldset = (Map<String, Object>) JSON.deserializeUntyped(fields);
            System.debug('fieldset: '+fieldset);            
            String firstname = (String) fieldset.get('Name'); System.debug(firstname);           
            String lastname = (String) fieldset.get('LastName');System.debug(lastname); 
            String email = (String) fieldset.get('FieloPLT__Email__c'); System.debug(email); 
            String accountId = (String) fieldset.get('FieloPLT__Account__c'); System.debug(accountId);
            String referalId = (String) fieldset.get('ReferalMember__c'); System.debug(referalId);
            fieldset.remove('LastName');
            
            Id userId;
            
            User u = new User();
            u.Username = email;
            u.put('Email',email);
            
            u.FirstName = firstname;
            u.LastName = lastname;

            String nickname = ((firstname != null && firstname.length() > 0) ? firstname.substring(0,1) : '' ) + lastname.substring(0,1);
            nickname += String.valueOf(Crypto.getRandomInteger()).substring(1,7);
            u.put('CommunityNickname', nickname);                                               
            
            if(createUser){
                // lastName is a required field on user, but if it isn't specified, we'll default it to the username
                userId = Site.createExternalUser(u, accountId, null);
            }
            
            FieloPLT__Member__c member = new FieloPLT__Member__c();                
            fieldset.put('Name', u.FirstName + ' ' + u.LastName);            
            fieldset.put('FieloPLT__User__c', userId);
            for(String field : fieldset.keySet()){                    
                member.put(field, fieldset.get(field));
            }
            member.FieloPLT__Type__c = 'Individual Account';
            insert member;

            FieloPLT__Event__c e1 = new FieloPLT__Event__c(FieloPLT__Member__c= referalId,
                                                          FieloPLT__Type__c = 'Referal');
            
            FieloPLT__Event__c e2 = new FieloPLT__Event__c(FieloPLT__Member__c= member.Id,
                                                          FieloPLT__Type__c = 'Registration');
            
            List<FieloPLT__Event__c> e = new List<FieloPLT__Event__c>();
            e.add(e1);
            e.add(e2);
            insert e;
            
            return null;
        } catch (DmlException e) {
            throw new AuraHandledException(e.getDmlMessage(0));
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    
}