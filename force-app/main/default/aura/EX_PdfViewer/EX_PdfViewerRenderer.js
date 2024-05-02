/************************************************************************************
 * Ver      Date            Author              Modification
 * ===================================================================================
   1.0      2021-05-09      jy.choi             Create
*************************************************************************************/

({

    getInitData: function(component, helper){
        var action = component.get('c.doGetInitData');
        action.setParams({
            "strRecordId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log(result);

                if(result["extension"] == "pdf"){
                    helper.getPdfData(component, result["strResult"]);
                }
            }
        });
        $A.enqueueAction(action);
    },

    getPdfData:function(component, contentDocumentId){
        component.set("v.status", "NONE");
        var action = component.get('c.getPdfData');
        action.setParams({ "contentDocumentId" : contentDocumentId});
        var self = this;
        action.setCallback(this, function(actionResult) {
            var r = actionResult.getReturnValue();
            console.log(r);
            $A.createComponent(
                "c:PdfViewer",
                {
                    "pdfData": r
                },

                //상태값 처리
                function(pdfViewer, status, errorMessage){
                    component.set("v.status", status);
                    if (status === "SUCCESS") {
                        var pdfContainer = component.get("v.pdfContainer");
                        pdfContainer.push(pdfViewer);
                        component.set("v.pdfContainer", pdfContainer);
                        component.set("v.toggleSpinner", false);
                    }
                    else if (status === "INCOMPLETE") {
                        console.log("No response from server or client is offline.")
                    }
                    else if (status === "ERROR") {
                        console.log("Error: " + errorMessage);
                    }
                    //self.resizeView();
                }
            );
        });
        $A.enqueueAction(action);
    },

    resizeView : function(){
        var winHeight = jQuery(window).height();
        console.log('winHeight : ' +winHeight  );

        jQuery('#drawPdf').height("76vh");
    }
});