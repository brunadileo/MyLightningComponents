({
    
    handleShowModal : function(component, event, helper) {
        var url = component.get("v.url");
        var copy = component.get("v.CopyToClipboard");
        var memberMap = component.get("v.memberMap");    
        var sendEmail = component.get("v.sendEmail"); console.log('sendEmail: '+ sendEmail);
        if(!copy){
            var modalBody;
            $A.createComponent(
                "c:modalContent",
                {
                    "url": component.getReference("v.url"),
                },
                function(content, status, url) {
                    if (status === "SUCCESS") { 
                        modalBody = content;             
                        component.find('modal').showCustomModal({
                            header: "Refer a friend",
                            body: modalBody, 
                            showCloseButton: true,
                            cssClass: "mymodal",
                            
                        })
                    }
                    
                })
        } else{ 
            var modalBody;
            $A.createComponent("c:modalCopyToClipboard",
                               {
                                   "url": component.getReference("v.url"),
                                   "memberMap":memberMap,
                                   "showFB":component.getReference("v.showFB"),
                                   "showWP":component.getReference("v.showWP"),
                                   "showTW":component.getReference("v.showTW"),
                                   "showEmail":component.getReference("v.showEmail"),
                                   "sendEmail":component.getReference("v.sendEmail"),
                                   "emailTemplate":component.getReference("v.emailTemplate")
                                   
                               },
                               function(content, status, url) {
                                   if (status === "SUCCESS") {   
                                       modalBody = content;
                                       component.find('modalCopy').showCustomModal({
                                           header: "Send the link to yout friends!",
                                           body: modalBody, 
                                           showCloseButton: true,
                                           cssClass: "mymodal",
                                           
                                       })
                                   }
                                   else{
                                       console.log('chegando aqui 3');
                                   }
                               })
        }
    },
        
    doInit : function(component, event, helper) {
        
        var action = component.get("c.getMember");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {    
                component.set("v.memberMap",response.getReturnValue());
                console.log(component.get("v.memberMap"));              
            }
            
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
        
    },
    
})