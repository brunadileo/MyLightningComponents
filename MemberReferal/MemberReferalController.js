({
    
    handleShowModal : function(component, event, helper) {
        var url = component.get("v.url");
        var modalBody;
        $A.createComponent("c:modalContent",
                            {
                                "url": component.getReference("v.url"),
                            },
                           function(content, status, url) {
                               if (status === "SUCCESS") {                                   
                                   modalBody = content;
                                   component.find('modal').showCustomModal({
                                       header: "Application Confirmation",
                                       body: modalBody, 
                                       showCloseButton: true,
                                       cssClass: "mymodal",
                                       
                                   })
                               }
                               
                           })
    },
    
})