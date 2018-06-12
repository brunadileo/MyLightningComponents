({
    createLink: function(cmp, event, helper,memberMap){
        var sendEmail = cmp.get("v.sendEmail");
        var url = cmp.get("v.url");
        var link = url+'registration?member='+memberMap.Id+'&prog='+memberMap.FieloPLT__Program__c;
        var p = {"program":memberMap.FieloPLT__Program__r.Name,
                 "link": link,
                 "memberName":memberMap.Name};    
        console.log(p);
        if(sendEmail == 'Salesforce'){
            console.log('Sent by Salesforce');
            helper.sendSalesforceMail(cmp, event, helper,p);    
        }else{
            console.log('Sent by SendGrid'); 
            helper.sendSendgridMail(cmp, event, helper,p);   
        }           
    },
    
    sendSendgridMail: function(cmp, event, helper,p) {
        var emails = cmp.get("v.emails");
        var memberMap = cmp.get("v.memberMap");
        
        var action = cmp.get("c.sgSendMail");
        
        action.setParams({
            emails: emails,
            p:p
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {    
                console.log(response.getReturnValue());              
                cmp.set("v.hideSuccessMsg", false);
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
    
    sendSalesforceMail: function(cmp, event, helper,p) {
        var emails = cmp.get("v.emails");
        var memberMap = cmp.get("v.memberMap");
        var action = cmp.get("c.sendMail");
        
        action.setParams({
            emails: emails,
            subject: subject, 
            message: message,
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {    
                console.log("Message: " + response.getReturnValue());              
                cmp.set("v.hideSuccessMsg", !component.get("v.hideSuccessMsg"));
                
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
        
        var action = cmp.get("c.sgSendMail");
        
        action.setParams({
            emails: emails
        });
        
    },
    
    showMyToast : function(component, event, helper,result, errorMsg) {
        var message;
        
        var success = {"type": "sucess", "title": "Success!", "message": "The e-mail was sent." };
        var error = {"type": "error", "title": "Error!", "message": errorMsg  };
        
        if(result){
            message = success;           
        }else{
            message = error;      
        }
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams(message); 
        
        toastEvent.fire();
    },
    
    
    
})