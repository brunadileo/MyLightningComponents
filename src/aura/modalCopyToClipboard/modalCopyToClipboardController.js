({
    
    doInit: function(component, event, helper){
        var url = component.get("v.url");
        var memberId = component.get("v.memberMap.Id");  console.log('memberId: '+memberId);       
        var program = component.get("v.memberMap.FieloPLT__Program__c"); console.log('program: '+program);
        
        var link = url+'registration?member='+memberId+'&prog='+program;
        component.set("v.completeURL",link);

        var emailTemplate = component.get("v.emailTemplate"); console.log(emailTemplate);
        var sendEmail = component.get("v.sendEmail"); console.log('sendEmail: '+ sendEmail);

        var action = component.get("c.getShortLink");
        action.setParams({
            url: link
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {    
                console.log("Answer: " + response.getReturnValue());
                component.set("v.shortURL",response.getReturnValue());                  
            }
        });
        $A.enqueueAction(action);

        
    },
    
    afterScriptsLoaded: function(component, event, helper){
       console.log('carregou'); 
        
    },
    
    clickCopyButton: function(component, event, helper) {
        component.set("v.clickedCopy",true);
        console.log(component.get("v.clickedCopy"));
        
        var holdtxt = document.getElementById("holdtext");
        holdtxt.select();
        document.queryCommandSupported('copy');
        document.execCommand('copy');
        console.log(holdtxt);
        
        helper.showMyToast(component, event, helper);
        
    },
    
    clickFBButton: function(cmp, event, helper) {
        var init = encodeURIComponent(cmp.get("v.shortURL")); console.log(init);
        var url = 'https://www.facebook.com/sharer/sharer.php?u='+init+'&src=sdkpreparse&quote=Join our Program!';
        window.open(url,'popUpWindow','height=300,width=400,left=10,top=10,resizable=yes,scrollbars=yes,toolbar=yes,menubar=no,location=no,directories=no,status=yes')

    },
    
    clickWPButton: function(cmp, event, helper) {
        var init = encodeURIComponent(cmp.get("v.shortURL")); console.log(init);
        var url = 'https://api.whatsapp.com/send?text=Join our Program! '+init;
        window.open(url,'popUpWindow','height=300,width=400,left=10,top=10,resizable=yes,scrollbars=yes,toolbar=yes,menubar=no,location=no,directories=no,status=yes')

    },
    
    clickTwButton: function(cmp, event, helper) {
        var init = encodeURIComponent(cmp.get("v.shortURL")); console.log(init);
        var url = 'https://twitter.com/intent/tweet?url='+init+'&text=Join our Program!'
        window.open(url,'popUpWindow','height=300,width=400,left=10,top=10,resizable=yes,scrollbars=yes,toolbar=yes,menubar=no,location=no,directories=no,status=yes')

    },
    
    clickCopyMobile: function(component, event, helper) {
        var holdtxt = document.getElementById("holdtext");
        holdtxt.select();
        console.log(holdtxt);
        
    },
    
    clickEmailButton: function(component, event, helper){
        var modalBody;
            $A.createComponent(
                "c:modalContent",
                {
                    "completeURL": component.getReference("v.shortURL"),
                    "sendEmail": component.getReference("v.sendEmail"),
                    "emailTemplate":component.getReference("v.emailTemplate"),
                },
                function(content, status, url) {
                    if (status === "SUCCESS") { 
                        modalBody = content;             
                        component.find('modal').showCustomModal({
                            header: "Write the e-mails",
                            body: modalBody, 
                            showCloseButton: true,
                            cssClass: "mymodal",
                            
                        })
                    }
                })        
    }
})