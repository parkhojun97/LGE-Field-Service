/**
 * @description       : 
 *                      
 * @author            : hyein.jeon@daeunextier.com
 * @group             :
 * @last modified on  : 2023-05-12
 * @last modified by  : hyein.jeon@daeunextier.com
 * Modifications Log
 * Ver     Date             Author               Modification
 * 1.0   2023-05-12   hyein.jeon@daeunextier.com   Initial Version
 */

@IsTest
public with sharing class IF_GSCS_SFDC_FileUpload_Test {

    @TestSetup
    static void testSetup() {
        Product2 objProduct = testObjectCreator.objProduct2;
        objProduct.ProductCode = 'TP';
        objProduct.Name = 'test.json';
        insert objProduct;

        ContentVersion objCV = testObjectCreator.objContentVersion;
        insert objCV;
    }

    @IsTest
    static void isTest(){

        // Set up test REST request
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/IF_GSCS_SFDC_FileUpload/';
        request.httpMethod = 'POST';
        request.addParameter('modelCode', 'TP');
        request.addParameter('name', 'test.json');

        // Set request body
        Map<String, Object> requestBody = new Map<String, Object>{
                'field1' => 'value1',
                'field2' => 'value2'
        };
        String jsonString = JSON.serialize(requestBody);
        Blob bodyBlob = Blob.valueOf(jsonString);
        request.requestBody = bodyBlob;

        // Make REST call
        RestContext.request = request;
        RestContext.response = new RestResponse();
        IF_GSCS_SFDC_FileUpload.uploadDocument();

    }

}