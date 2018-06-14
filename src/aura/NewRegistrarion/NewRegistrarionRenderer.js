({
	afterRender : function(cmp,helper){
        this.superAfterRender();
        //var elements = document.getElementsByClassName("inputContainer");
        console.log("elements.length: " + elements.length);
        for (var i=0; i<elements.length; i++) {
            console.log(elements[i].innerHTML);
        }
    }
    
})