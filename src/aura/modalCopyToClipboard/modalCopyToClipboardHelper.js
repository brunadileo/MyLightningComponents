({
    showMyToast : function(component, event, helper) {
		var device = component.get("v.device");
        var success = {"type": "success", "message": "Link copied to the clipboard!" };

        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams(success);  
        if(device != 'PHONE'){
            toastEvent.fire();
        }
        
    },
})