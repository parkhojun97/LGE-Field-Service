({
    //초기화
    loadpdf:function(component,event){
        try{
            var pdfData = component.get('v.pdfData');
            var pdfjsframe = component.find('pdfFrame');

            //pdfData의 자료형이 undefined가 아닌 경우 iFrame으로 데이터 전송
            if(typeof pdfData != 'undefined'){
                pdfjsframe.getElement().contentWindow.postMessage(pdfData, '*');
            }
        }catch(e){
            alert('Error: ' + e.message);
        }
    }
});