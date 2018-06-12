({
    sendMailScript : function(cmp, event, helper) {   
        var createMember = cmp.get("v.createMember");
        var referrerEmail = cmp.get("v.referrerEmail");
        
        var action = cmp.get("c.searchMember");        
        action.setParams({
            referrerEmail: referrerEmail,
            createMember: createMember
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {    
                console.log(response.getReturnValue());
                helper.createLink(cmp, event, helper,response.getReturnValue());        
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                        helper.showMyToast(cmp, event, helper,false,errors[0].message);   
                    }
                } else {
                    console.log("Unknown error");
                    helper.showMyToast(cmp, event, helper,false,"Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    doInit : function(cmp, event, helper) {   

        var url = cmp.get("v.url");
                
        var action = cmp.get("c.searchURL");        

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {    
                console.log(response.getReturnValue());
                cmp.set("v.url",response.getReturnValue());       
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                        helper.showMyToast(cmp, event, helper,false,errors[0].message);   
                    }
                } else {
                    console.log("Unknown error");
                    helper.showMyToast(cmp, event, helper,false,"Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
   
})