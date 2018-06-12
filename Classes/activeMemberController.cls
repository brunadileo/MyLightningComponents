public class activeMemberController {
    public static String currentMemberId{get;set;}
    
@auraEnabled    
    public static String setMember(String memberId){
       FieloPLT__Settings__c settings = FieloPLT__Settings__c.getInstance(UserInfo.getUserId());
       settings.CurrentMemberId__c = memberId;
       upsert settings;
        
       return  settings.CurrentMemberId__c;
    }
     
}