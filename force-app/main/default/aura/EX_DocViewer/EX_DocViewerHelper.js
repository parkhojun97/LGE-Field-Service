({
//     gfnInit : function(component) {
//
//        console.log('EX_DOcView getInint1!!!');
//         var tmpComponent = component.get('v.value');
//            console.log( component.get('v.selectedQuote'));
//            console.log( component.get('v.selectedInvoice'));
//            console.log( component.get('v.selectedRegi'));
//            console.log( component.get('v.selectedBank'));
//            console.log('tmpComponent :: ' + tmpComponent);
//
//            for (var idx in tmpComponent) {
//                if(tmpComponent[idx] == '견적서')component.set('v.quoteYN',true);
//                if(tmpComponent[idx] == '사업자등록증')component.set('v.regiYN',true);
//                if(tmpComponent[idx] == '명세서')component.set('v.specYN',true);
//                if(tmpComponent[idx] == '통장사본')component.set('v.bankYN',true);
//            }
//
//            var order='contactId='+component.get("v.contactId") +'&orderNumber='+(component.get("v.stdConsumableOrderId")==null ? component.get("v.soldOutConsumableOrderId") : component.get("v.stdConsumableOrderId"));
//            if(component.get('v.quoteYN'))
//                component.set('v.pdfUrl','/apex/EX_SuppliesPDF?id=quote&'+ order);
//            if(component.get('v.specYN') )
//                component.set('v.invoicePdfUrl','/apex/EX_SuppliesPDF?id=invoice&'+ order);
//            if(component.get('v.regiYN'))
//                component.set('v.regiPdfUrl', '/apex/EX_SuppliesPDF?id=regi&'+ order);
//            if(component.get('v.bankYN') )
//                component.set('v.bankPdfUrl','/apex/EX_SuppliesPDF?id=bank&'+ order);
//
//        },


gfnInit : function(component) {

        console.log('EX_DOcView getInint1!!!');
        
        //23.09.04 PHJ
        //  var tmpComponent = component.get('v.value');
        // console.log('tmpComponent :: ' + tmpComponent);

        console.log( component.get('v.selectedQuote'));
        console.log( component.get('v.selectedInvoice'));
        console.log( component.get('v.selectedRegi'));
        console.log( component.get('v.selectedBank'));

        //23.09.04 PHJ
        if(component.get('v.selectedQuote')   == 'Y') component.set('v.quoteYN',true);
        if(component.get('v.selectedInvoice') == 'Y') component.set('v.specYN',true);
        if(component.get('v.selectedRegi')    == 'Y') component.set('v.regiYN',true);
        if(component.get('v.selectedBank')    == 'Y') component.set('v.bankYN',true);
        // for (var idx in tmpComponent) {
        //     if(tmpComponent[idx] == '견적서')component.set('v.quoteYN',true);
        //     if(tmpComponent[idx] == '사업자등록증')component.set('v.regiYN',true);
        //     if(tmpComponent[idx] == '명세서')component.set('v.specYN',true);
        //     if(tmpComponent[idx] == '통장사본')component.set('v.bankYN',true);
        // }

        console.log(" component.get(v.contactId) ::  "+component.get("v.contactId"));
        console.log(" (component.get(v.stdConsumableOrderId) ::  "+component.get("v.stdConsumableOrderId"));
        console.log(" (component.get(v.quoteHistoryId) ::  "+component.get("v.quoteHistoryId"))



//            var order='contactId='+component.get("v.contactId") +'&orderNumber='+(component.get("v.stdConsumableOrderId")==null ? component.get("v.soldOutConsumableOrderId") : component.get("v.stdConsumableOrderId"));
            //04.29 생성 이력 ID를 넣어 TEST
            var order='contactId='+component.get("v.contactId") +'&orderNumber='+(component.get("v.stdConsumableOrderId")==null ? component.get("v.soldOutConsumableOrderId") : component.get("v.stdConsumableOrderId"))+'&quoteHistoryId='+component.get("v.quoteHistoryId");

            console.log('order :: ' + order);
            if(component.get('v.quoteYN')) component.set('v.pdfUrl',       '/apex/EX_SuppliesPDF?id=quote&'+   order);
            if(component.get('v.specYN'))  component.set('v.invoicePdfUrl','/apex/EX_SuppliesPDF?id=invoice&'+ order);
            if(component.get('v.regiYN'))  component.set('v.regiPdfUrl',   '/apex/EX_SuppliesPDF?id=regi&'+    order);
            if(component.get('v.bankYN'))  component.set('v.bankPdfUrl',   '/apex/EX_SuppliesPDF?id=bank&'+    order);
                console.log('1!', component.get('v.quoteYN'));
                console.log('2@', component.get('v.specYN'));
                console.log('3#', component.get('v.regiYN'));
                console.log('4$', component.get('v.bankYN'));
        },

        gfnShowToast : function(type, message) {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type"    : type,
                    "message" : message
                });
                toastEvent.fire();
        },


});