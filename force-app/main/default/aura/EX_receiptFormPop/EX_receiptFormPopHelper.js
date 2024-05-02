({
	getInitData : function(component, listSecondTarget){

		var listLineId = component.get("v.listRecordId");
		var listRentId = component.get("v.listRentId");
		var pdfType = component.get("v.pdfType");
        var productRequestId = component.get('v.productRequestId');
        var OrderChannel = component.get('v.OrderChannel');
        console.log('productRequestId vfpageurl만들기직전:: ',productRequestId);

        if(listSecondTarget.length > 0) {
            listLineId = listSecondTarget;
            pdfType = component.get("v.pdfType2");
            component.set('v.listResvRecordId', []); // 리셋
        }
		console.log("pdfType :: " + pdfType);
		console.log("listLineId :: " + listLineId);

        component.set("v.vfPageUrl" , "/apex/" + pdfType + "?productRequestId=" + productRequestId+"&OrderChannel=" + OrderChannel + "&pdfType="+pdfType);

		// if(listRentId != null) {
		//     component.set("v.vfPageUrl" , "/apex/" + pdfType + "?Id=" + listLineId+"&rentId=" + listRentId + "&pdfType="+pdfType);
		// } else {
		//     component.set("v.vfPageUrl" , "/apex/" + pdfType + "?Id=" + listLineId+"&pdfType="+pdfType);
		// }
    },

    callSdkPrint : function(component){
        console.log("callSdkPrint");

        var vfWindow = component.find("vfFrameMaster").getElement().contentWindow;
        var message = 'SDK_PRINT';

        vfWindow.postMessage(message, '*');
    }
})