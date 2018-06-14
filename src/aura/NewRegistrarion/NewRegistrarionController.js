({
    doInit: function(component, event, helper) {
        
        /*var inputbgcolor = component.get("v.inputbgcolor");
        var lalala = component.find("lalala");
        lalala.style.backgroundColor = inputbgcolor;

        var elements = document.getElementsByClassName("inputContainer");
        console.log("elements.length: " + elements.length);
        for (var i=0; i<elements.length; i++) {
            console.log(elements[i].innerHTML);
        }*/
        

        var url = decodeURIComponent(window.location.search.substring(1));
        console.log(url);
        
        //error checking to open the component in the builder
        if(url.includes("&") && url.substring(0,3) != 'app'){
            var listURL = url.split('&');       
            var length = listURL.length++;           
            for(var i=0; i<=length; i++){  
                var temp = listURL[i].split('=');
                if(temp[0] == 'member'){
                    component.set("v.member.Id",temp[1]);
                    console.log('referal member: '+component.get("v.member.Id"));
                }else if(temp[0] == 'prog'){
                    component.set("v.program.Id",temp[1]);
                    console.log('program: '+component.get("v.program.Id"));
                    break;
                }            
            }
        }

        var action = component.get("c.getNames");   

        action.setParams({ 
            programId : component.get("v.program.Id"),
            memberId : component.get("v.member.Id")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var obj = response.getReturnValue();
                console.log(obj);
                component.set("v.program.Name",obj.program);
                component.set("v.member.Name",obj.member);
            }else{
                console.log('ERROR');
            }
        });
        
        $A.enqueueAction(action);
        
        
    },    
    
    saveForm: function(component, event, helper){
        var createUser = component.get("v.createUser");
        var firstname = component.get("v.firstname");
        var lastname= component.get("v.lastname");
        var email = component.get("v.email");
        var program = component.get("v.program");
        var member = component.get("v.member");
        
        var fields2 = {Name: firstname,
                       LastName: lastname,
                       FieloPLT__Email__c:email,
                       FieloPLT__Program__c: program.Id,
                       ReferalMember__c: member.Id};
        
        var fields = JSON.stringify(fields2);
        var action = component.get("c.selfRegister");
        action.setParams({
            fields: fields,
            createUser: createUser
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('funcionou');
                component.set("v.hideSuccessMsg", !component.get("v.hideSuccessMsg"));
            }else{
                var errors = response.getError();
                helper.showMyToast(component, event, helper,false,errors[0].message);
                console.log(response.getError());
            }
        });
        
        $A.enqueueAction(action);
        
    },
    
    setExtraFieldValues: function(component, event, helper){        
        
    }
})