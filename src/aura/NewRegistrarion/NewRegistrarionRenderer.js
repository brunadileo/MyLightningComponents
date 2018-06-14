({
	afterRender : function(cmp,helper){
        this.superAfterRender();
<<<<<<< HEAD

        var bgcolor = cmp.get("v.bgcolor");
        cmp.find('body').getElements()[0].style.backgroundColor = bgcolor;
        
        /*var inputbgcolor = cmp.get("v.inputbgcolor");
        cmp.find('input2').style.backgroundColor = inputbgcolor;*/

        
        /*document.styleSheets[0].insertRule('input{ background-color: #000;}');
        document.styleSheets[0].insertRule('.testClass{ background-color: #000;}');
        $A.util.addClass(cmp.find('input2'),'testClass');*/
        
        //document.styleSheets[0].addRule('.inputContainer','background-color: #ccc;',1);
        
        //document.getElementsByTagName("INPUT"); //console.log(inputs);
        
       	
        //document.styleSheets[0].insertRule('.testClass{ background-color: #ccc;}');
        /*for(var i=0;inputs.length<i;i++){
            $A.util.addClass(document.getElementsByTagName("INPUT")[i],'testClass');
            //console.log(document.getElementsByTagName("INPUT")[i]);
        }*/
        
        //$A.util.addClass(input,'testClass');
		var i = cmp.find('input2');
        //i.getElementsByTagName("INPUT");
        console.log(i[0]);
        debugger;
        
=======
        //var elements = document.getElementsByClassName("inputContainer");
        console.log("elements.length: " + elements.length);
        for (var i=0; i<elements.length; i++) {
            console.log(elements[i].innerHTML);
        }
>>>>>>> 09b7f88acdc16287bc0d6408fd9469154d5ccf2e
    }
    
})