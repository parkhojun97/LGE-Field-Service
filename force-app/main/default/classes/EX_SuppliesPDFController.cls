/**
 * Created by I2MAX.JAEYEONLEE on 2023-01-05.
 */

public without sharing class EX_SuppliesPDFController {

    public String getResult() {
        System.debug('속도측정 -------------------------------------------------- EX_SuppliesPDFController.getResult (start):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
        
        System.debug('EX_SuppliesPDFController. getResult ! ');
        String RecordId = ApexPages.currentPage().getParameters().get('Id');
        String contactId = ApexPages.currentPage().getParameters().get('contactId');
        String orderNumber = ApexPages.currentPage().getParameters().get('orderNumber');
        String quoteHistoryId = '';

        if(ApexPages.currentPage().getParameters().get('quoteHistoryId') != null){
             quoteHistoryId = ApexPages.currentPage().getParameters().get('quoteHistoryId');
        }

        SR_ONLINE_SALE_ESTIMATE__c templateBody = null;

        System.debug(RecordId);
        System.debug(contactId);
        System.debug(orderNumber);
        System.debug(quoteHistoryId);
        
        templateBody = EX_DocPreviewController.getQuoteHistory(orderNumber, quoteHistoryId);
        System.debug(templateBody.Invoice__c);
        
        //23.10.12 PHJ pdf 다운로드 이름 설정
        String pdfName = '';
        if(RecordId == 'quote') pdfName = '견적서';
        if(RecordId == 'regi') pdfName = '사업자등록증';
        if(RecordId == 'bank') pdfName = '통장사본';
        if(RecordId == 'invoice') pdfName = '명세서';

        String fileName = pdfName + '.pdf';
        String encodedFilename = EncodingUtil.urlEncode(filename, 'UTF-8');
        ApexPages.currentPage().getHeaders().put('content-disposition', 'filename="' + encodedFilename + '"');

        if(RecordId == 'quote') {
            System.debug('속도측정 -------------------------------------------------- EX_SuppliesPDFController.getResult (end):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
            System.debug(templateBody.Quote__c);
            return String.valueOf(templateBody.Quote__c) ;
        }
        else if(RecordId == 'regi'){
            return String.valueOf(templateBody.Business_Registration__c);
        }
        else if(RecordId == 'bank') {
            return String.valueOf(templateBody.BankBookCopy__c);
        }
        else if(RecordId == 'invoice') {
            return String.valueOf(templateBody.Invoice__c);
        }
        return '';
    }
}