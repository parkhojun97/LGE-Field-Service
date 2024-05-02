({
	fnInit : function(component, event, helper){
        console.log("getInitData ");
        console.log("productRequestId ::: ", component.get('v.productRequestId'));
        console.log('FS_ScriptFormPop >>>>> ' + component.get('v.popWidth'));
        console.log('FS_ScriptFormPop >>>>> ' + component.get('v.pdfType'));
        console.log('FS_ScriptFormPop >>>>> ' + component.get('v.pdfType2'));
        var listTemp = [];
        helper.getInitData(component, listTemp);
    },

    fnPrint : function(component, event, helper){
        console.log("fnPrint");

		helper.callSdkPrint(component);
    },

    fnCancel : function(component, event, helper){
        var listResvRecordId = component.get('v.listResvRecordId');
        console.log('fnCancel >> ' + listResvRecordId);
        console.log('fnCancel2 >> ' + listResvRecordId.length);
        if(listResvRecordId.length > 0) {
            helper.getInitData(component, listResvRecordId);
        } else {
            component.destroy();
        }
    }
})