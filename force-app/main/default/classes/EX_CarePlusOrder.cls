/**
 * Created by A80598 on 2023-02-20.
 */

@RestResource(UrlMapping='/v1/api/ma/newbest/IF_MACN_NEWBEST_SFDC_0013')
global with sharing class EX_CarePlusOrder {
    // /services/apexrest/v1/api/ma/newbest/IF_MACN_NEWBEST_SFDC_0013
    // {"Body":{"data":{"inputData":"test"}}}

    global class Input {
        public InputBody Body;
        public Input(){
            Body = new InputBody();
        }
    }

    global class InputBody {
        public InputDetail data;
        public InputBody(){
            data = new InputDetail();
        }
    }

    global class InputDetail{
        public String inputData;
    }

    global class Output {
        public String code;
        public String message;
    }

    public static String F_ST_DEPT_CODE = 'PH0300';
    public static String F_ST_DEPT_NAME = '케어용품센터';

    /**
     * @AUTHOR I2MAX.SANGHUNYEO
     * @date  2023-02-20
     * @param
     * @description 케어플러스 인터페이스 후처리 (케어플러스 주문 대상 정보 조회)
     * @return
     */
    @HttpPost
    global static Output doPost() {
        Output objOutput = new Output();
        Input objInput = new Input();
        Savepoint sp = Database.setSavepoint();
        try {
            RestRequest request = RestContext.request;
            /*String requestBody = request.requestBody.toString();

            if (requestBody != null && requestBody != '') {
                objInput = (Input) JSON.deserializeStrict(requestBody, Input.class);
                String temp = objInput.Body.data.inputData;
            }*/

            objOutput.code = '200';
            objOutput.message = '케어플러스 주문수신 성공.';
            /**
             * Step3. 케어플러스 주문 대상 정보 조회
             */
            String strQuery = '';
            strQuery += ' SELECT ' + SObjectUtil.getFieldForQuery('SI_CAREPLUS_ORDER__c');
            strQuery += ' FROM SI_CAREPLUS_ORDER__c ';
            strQuery += ' WHERE TRANS_TYPE__c = \'O\' ';
            strQuery += ' AND WORK_FLAG__c IN ( \'N\', \'R\', \'H\', \'I\', \'O\', \'D\',\'\') ';
            strQuery += ' ORDER BY LAST_UPDATE_DATE__c ASC ';
            //strQuery += ' LIMIT 5 ';
            //System.debug('strQuery >>> ' + strQuery);

            List<sObject> siCarePlusOrderList = Database.query(strQuery);

            if (!siCarePlusOrderList.isEmpty()) {
                List<String> sPartNoList = new List<String>();
                List<String> billToCodeList = new List<String>();
                List<String> orderNoList = new List<String>();
                List<String> sDivCodeList = new List<String>();
                List<Integer> ifIdList = new List<Integer>();
                for (sObject lData : siCarePlusOrderList) {
                    String partNo = getStringNotNull(lData.get('PART_NO__c'));
                    String billToCode = getStringNotNull(lData.get('BILL_TO_CODE__c'));
                    String orderNo = getStringNotNull(lData.get('ORDER_NO__c'));
                    String sDivCode = getStringNotNull(lData.get('DIV_CODE__c'));
                    Integer ifId = getIntegerNotNull(lData.get('INTERFACE_ID__c'));
                    if(!partNo.equals('')){
                        sPartNoList.add(partNo); //파트넘버 리스트
                    }
                    if(!billToCode.equals('')){
                        billToCodeList.add(billToCode); //billToCode 리스트
                    }
                    if(!orderNo.equals('')){
                        orderNoList.add(orderNo); //orderNo 리스트
                    }
                    if(!sDivCode.equals('')){
                        sDivCodeList.add(sDivCode);
                    }
                    ifIdList.add(ifId);
                }

                Id departmentId = [SELECT Id FROM SM_DEPT__c WHERE DEPT_CODE__c = :EX_ConsumableUtil.PH0300]?.Id;
                Id warehouseLocationId = EX_ConsumableUtil.getCarePlusWareHouseId(); // 케어플러스 적치장소 Location Id

                /** 케어용품, 단종여부 체크 */
                List<product2> mPartDataList = new List<product2>();
                if(!sPartNoList.isEmpty()){
                    mPartDataList = [SELECT Id, DISABLED_DT__c, Name FROM product2 WHERE Name IN :sPartNoList AND CAREPLUS_YN__c = 'Y'];
                    system.debug('케어용품 단종여부 체크 TOTAL : ' + sPartNoList.size() + ', result : ' + mPartDataList);
                }

                /** BillToCode 체크 */
                List<Account> billtoCodeDataList = new List<Account>();
                if(!billToCodeList.isEmpty()){
                    billtoCodeDataList = [SELECT Id, Name, AR_CODE__c FROM ACCOUNT WHERE AR_CODE__c IN :billToCodeList]; //AR_CODE__c 로 체크
                    system.debug('BillToCode 체크 TOTAL : ' + billToCodeList.size() + ', result : ' + billtoCodeDataList);
                }

                /** Contact 체크 */
                List<Contact> contactsList = new List<Contact>();
                if(!billtoCodeDataList.isEmpty()){
                    List<String> accountIdList = new List<String>();
                    for(Account ac : billtoCodeDataList){
                        accountIdList.add(ac.Id);
                    }
                    if(!accountIdList.isEmpty()){
                        contactsList = [SELECT Id, AccountId, Name, MobilePhone, ADDRESS_NEW__c, POSTAL_CODE__c FROM CONTACT WHERE AccountId IN :accountIdList];
                        system.debug('Contact 체크 TOTAL : ' + accountIdList.size() + ', result : ' + contactsList);
                    }
                }

                /** ProductRequest 체크 */
                List<ProductRequest> productRequestList = new List<ProductRequest>();
                if(!orderNoList.isEmpty()){
                    strQuery = '';
                    strQuery += ' SELECT ' + SObjectUtil.getFieldForQuery('ProductRequest');
                    strQuery += ' FROM ProductRequest ';
                    strQuery += ' WHERE Order_Number__c IN (';
                    Integer i = 0;
                    for(String orderNo : orderNoList){
                        if(i == 0){
                            strQuery += '\'' + orderNo + '\'';
                        }else{
                            strQuery += ',\'' + orderNo + '\'';
                        }
                        i++;
                    }
                    strQuery += ') ';
                    strQuery += ' AND Order_CHNL_TYPE_Code__c = \'BestShop\' ';
                    strQuery += ' AND RecordTypeId = \'' + EX_ConsumableUtil.PR_CARE_SUPPLIES_RECORDTYPE_ID + '\' ';
                    productRequestList = Database.query(strQuery);
                    System.debug('ProductRequest 체크');
                }

                /** ProductRequestLineItem 체크 */
                List<ProductRequestLineItem> productRequestLineItemList = new List<ProductRequestLineItem>();
                if(!orderNoList.isEmpty() && !sPartNoList.isEmpty()){
                    strQuery = '';
                    strQuery += ' SELECT ' + SObjectUtil.getFieldForQuery('ProductRequestLineItem');
                    strQuery += ' FROM ProductRequestLineItem ';
                    strQuery += ' WHERE Order_Number__c IN (';
                    Integer i = 0;
                    for(String orderNo : orderNoList){
                        if(i == 0){
                            strQuery += '\'' + orderNo + '\'';
                        }else{
                            strQuery += ',\'' + orderNo + '\'';
                        }
                        i++;
                    }
                    strQuery += ') ';
                    strQuery += ' AND Order_CHNL_TYPE_Code__c = \'BestShop\' ';
                    strQuery += ' AND PART_NO__c IN (';
                    Integer j = 0;
                    for(String sPartNo : sPartNoList){
                        if(j == 0){
                            strQuery += '\'' + sPartNo + '\'';
                        }else{
                            strQuery += ',\'' + sPartNo + '\'';
                        }
                        j++;
                    }
                    strQuery += ') ';
                    strQuery += ' AND RecordTypeId = \'' + EX_ConsumableUtil.PRLI_CARE_SUPPLIES_RECORDTYPE_ID + '\' ';
                    productRequestLineItemList = Database.query(strQuery);
                    System.debug('ProductRequestLineItem 체크');
                }

                /** 가용재고 조회 */
                System.debug('가용재고 조회');
                List<ProductItem> ProductItemList = [
                        SELECT Id, Product2Id, fm_Available_Quantity__c, DIV_CODE__c, fm_Parts_Number__c
                        FROM ProductItem
                        WHERE fm_Available_Quantity__c >= 0
                        AND fm_DEPT_CODE__c = :F_ST_DEPT_CODE
                        AND DIV_CODE__c IN :sDivCodeList
                        AND fm_Parts_Number__c IN :sPartNoList
                        AND Location.RecordType.DeveloperName = 'Location'
                        AND Location.Name = :System.Label.EX_Location
                ];

                /** 케어플러스 ERP 결과 조회 */
                List<SI_CAREPLUS_ORDER_COMPLETE__c> orderCompleteYPOList = [
                        SELECT Id, LINE_STATUS_CODE__c, LINE_ID__c, ORIG_SYS_DOCUMENT_REF__c, ITEM_NO__c, WORK_FLAG__c
                        FROM SI_CAREPLUS_ORDER_COMPLETE__c
                        WHERE ORIG_SYS_DOCUMENT_REF__c IN :orderNoList
                        AND ITEM_NO__c IN :sPartNoList
                        AND LINE_STATUS_CODE__c NOT IN ('SHIPPED', 'CANCELLED', 'RETRUNED', 'PENDING_WORKFLOW', 'Not Defined')
                        AND (WORK_FLAG__c = null OR WORK_FLAG__c = 'Y' OR WORK_FLAG__c = 'N')
                        AND ORDER_TYPE__c = 'PO'
                        ORDER BY INTERFACE_ID__c DESC
                ];

                /** 케어플러스 max request */
                List<SI_CAREPLUS_ORDER_REQUEST__c> getRequestMaxList = [SELECT SO_INTERFACE_ID__c FROM SI_CAREPLUS_ORDER_REQUEST__c ORDER BY SO_INTERFACE_ID__c DESC LIMIT 1];
                Integer requestMaxInterfaceId = 0;
                if(!getRequestMaxList.isEmpty()){
                    requestMaxInterfaceId = getIntegerNotNull(getRequestMaxList[0].SO_INTERFACE_ID__c);
                }

                /** 케어플러스 max backif */
                List<SI_CAREPLUS_BACKIF__c> getBackIfMaxList = [SELECT INTERFACE_ID__c FROM SI_CAREPLUS_BACKIF__c ORDER BY INTERFACE_ID__c DESC LIMIT 1];
                Integer backIfMaxInterfaceId = 0;
                if(!getBackIfMaxList.isEmpty()){
                    backIfMaxInterfaceId = getIntegerNotNull(getBackIfMaxList[0].INTERFACE_ID__c);
                }

                /** 케어플러스 subMax backif */
                List<SI_CAREPLUS_BACKIF__c> getBackIfSubMaxList = [SELECT BACK_SUB_SEQ__c, INTERFACE_ID__c, ORDER_NO__c FROM SI_CAREPLUS_BACKIF__c
                    WHERE INTERFACE_ID__c IN :ifIdList
                    AND TRANS_TYPE__c = 'O'
                    AND ORDER_NO__c IN :orderNoList
                    ORDER BY BACK_SUB_SEQ__c DESC LIMIT 1];

                List<ProductRequest> listUpsertPR = new List<ProductRequest>();
                List<ProductRequestLineItem> listUpsertPRLI = new List<ProductRequestLineItem>();
                List<SI_CAREPLUS_ORDER_COMPLETE__c> listUpdateComplete = new List<SI_CAREPLUS_ORDER_COMPLETE__c>();
                List<SI_CAREPLUS_BACKIF__c> listInsertSiBackIf = new List<SI_CAREPLUS_BACKIF__c>();
                List<SI_CAREPLUS_ORDER_REQUEST__c> listInsertSiRequest = new List<SI_CAREPLUS_ORDER_REQUEST__c>();
                List<SI_CAREPLUS_ORDER__c> listUpdateSiOrder = new List<SI_CAREPLUS_ORDER__c>();
                Integer loopCnt = 1;
                Integer loopCnt2 = 1;
                List<ProductRequest> listInsertPR = new List<ProductRequest>();
                List<ProductRequestLineItem> listInsertPRLI = new List<ProductRequestLineItem>();
                List<ProductRequestLineItem> execApplyPRLI = new List<ProductRequestLineItem>();
                List<Map<String, Object>> mapList = new List<Map<String, Object>>();
                List<Map<String, Object>> rsrvCancelMapList = new List<Map<String, Object>>();

                System.debug('주문 생성 작업 시작. 수신 TOTAL : ' + siCarePlusOrderList.size());

                for (sObject lData : siCarePlusOrderList) {
                    Map<String, Object> rsrvCancelMap = new Map<String, Object>();
                    ProductRequest nowPR = new ProductRequest();
                    ProductRequestLineItem nowPRLI = new ProductRequestLineItem();
                    String result = 'SUCCESS';
                    String carePlustOrderNo = getStringNotNull(lData.get('ORDER_NO__c'));
                    /* 트랜잭션 요청 타입 O : 매입 주문 생성 요청, C : 취소요청, R : 환입 주문 생성 요청 */
                    String sTransType = 'O';
                    /* 사업부코드 */
                    String sDivCode = getStringNotNull(lData.get('DIV_CODE__c'));
                    /* PART_NO */
                    String sPartNo = getStringNotNull(lData.get('PART_NO__c'));
                    /* WROK FLAG */
                    String workFlag = '';
                    /* RESERV_NO */
                    String attribute2 = getStringNotNull(lData.get('ATTRIBUTE2__c'));
                    /* REQUEST_NUM */
                    String attribute3 = getStringNotNull(lData.get('ATTRIBUTE3__c'));
                    /* REQUEST SEQ */
                    String attribute4 = getStringNotNull(lData.get('ATTRIBUTE4__c'));
                    /* 직영점, 전문점 구분값 H:하이프라자, A:전문점 */
                    String attribute8 = getStringNotNull(lData.get('ATTRIBUTE8__c'));
                    /* ATTRIBUTE10 ERP(LINE_ID) 값 할당 변수 */
                    String sAttribute10 = getStringNotNull(lData.get('ATTRIBUTE10__c'));
                    /* 현재 WORK FLAG 예약된건인경우 재처리시 가용재고가 없어 또 예약되는걸 방지하기 위한 변수 */
                    //개발 중 필요없으면 대체
                    String nowWorkFlag = getStringNotNull(lData.get('WORK_FLAG__c'));
                    if(nowWorkFlag.equals('')){nowWorkFlag = 'N';}
                    /* 요청유형 */
                    String reqType = 'A';
                    /* MODEL_CODE */
                    String sModelCode = getStringNotNull(lData.get('MODEL_CODE__c'));
                    /* ATTRIBUTE1 */
                    String sAttribute1 = '';

                    /* 주문수량 */
                    Integer orderQty = getIntegerNotNull(lData.get('ORDER_QTY__c'));
                    Integer shipQty = 0;
                    /* 취소수량 */
                    Integer cancelQty = 0;
                    /* 주문금액 */
                    Double orderAmt = getDoubleNotNull(lData.get('ORDER_AMT__c'));
                    /* 주문단가 */
                    Double orderPrice = getDoubleNotNull(lData.get('ORDER_PRICE__c'));
                    /* billtocode */
                    String billToCode = '';
                    billToCode = getStringNotNull(lData.get('BILL_TO_CODE__c'));
                    /* 취소여부 */
                    String cancelFlag = '';
                    /* 단종여부 */
                    Boolean bDisabled = false;
                    /* billtoCheck */
                    Boolean bBilltoCheckPass = true;
                    /* 여신체크 */
                    Boolean bCreditHold = false;
                    /* CUSTOMER_NO 체크 */
                    Boolean customerNoIsEmpty = false;

                    String toDay = '';
                    String urgentFlag = '';
                    Integer currTime = 0;

                    String rsrvNo = ''; // TEXT C000000296
                    //List<String> prIdList = new List<String>(); //ProductRequest Id
                    //List<String> prliIdList = new List<String>(); //ProductRequestLineItem Id

                    Integer backIfSubMaxInterfaceId = 0;
                    if(!getBackIfSubMaxList.isEmpty()){
                        for(SI_CAREPLUS_BACKIF__c scb : getBackIfSubMaxList){
                            if(scb.INTERFACE_ID__c == getDecimalNotNull(lData.get('INTERFACE_ID__c')) && scb.ORDER_NO__c == carePlustOrderNo){
                                backIfSubMaxInterfaceId = getIntegerNotNull(getBackIfSubMaxList[0].BACK_SUB_SEQ__c);
                            }
                        }
                    }

                    /** 케어용품 체크 */
                    List<Product2> mPartData = new List<Product2>();
                    //List<ProductItem> mPartData = [SELECT Id, Product2.DISABLED_DT__c, fm_Parts_Number__c FROM ProductItem WHERE fm_Parts_Number__c = :sPartNo AND product2.CAREPLUS_YN__c = 'Y'];
                    for(Product2 pd : mPartDataList){
                        if(sPartNo.equals(pd.Name)){
                            mPartData.add(pd);
                        }
                    }

                    /** BillToCode 체크 */
                    List<Account> billtoCodeData = new List<Account>();
                    //List<Account> billtoCodeData = [SELECT Id, AR_CODE__c FROM ACCOUNT WHERE AR_CODE__c = :billToCode]; //AR_CODE__c 로 체크
                    for(Account ac : billtoCodeDataList){
                        if(billToCode.equals(ac.AR_CODE__c)){
                            billtoCodeData.add(ac);
                        }
                    }
                    String accountId = '';
                    String accountName = '';
                    String accountAddr = '';
                    String accountPostal = '';
                    String accountTel = '';
                    String contactId = '';
                    if (!billtoCodeData.isEmpty()) {
                        bBilltoCheckPass = true;
                        accountId = billtoCodeData[0].Id;
                        accountName = billtoCodeData[0].Name;
                        List<Contact> contacts = new List<Contact>();
                        //List<Contact> contacts = [SELECT Id, Name, MobilePhone, ADDRESS_NEW__c, POSTAL_CODE__c FROM CONTACT WHERE AccountId = :accountId];
                        for(Contact ct : contactsList){
                            if(accountId.equals(ct.AccountId)){
                                contacts.add(ct);
                            }
                        }
                        if(!contacts.isEmpty()){
                            contactId = contacts[0].Id;
                            accountAddr = contacts[0].ADDRESS_NEW__c;
                            accountPostal = contacts[0].POSTAL_CODE__c;
                            accountTel = contacts[0].MobilePhone;
                        }
                    }else{
                        bBilltoCheckPass = false;
                    }

                    /** 단종여부체크 */
                    if ('N'.equals(nowWorkFlag)) {
                        if (!mPartData.isEmpty()) {
                            if (mPartData[0].DISABLED_DT__c != null && !''.equals(mPartData[0].DISABLED_DT__c)) {
                                bDisabled = true;
                            }
                        }
                    }

                    List<ProductItem> piforPrli = new List<ProductItem>();
                    if(!ProductItemList.isEmpty()){
                        for(ProductItem pi : ProductItemList){
                            if(pi.DIV_CODE__c.equals(sDivCode) && pi.fm_Parts_Number__c.equals(sPartNo)){
                                piforPrli.add(pi);
                            }
                        }
                    }

                    //케어용품, BillToCode, 단종, customerNo 체크
                    if (!mPartData.isEmpty() && bBilltoCheckPass && !bDisabled && !customerNoIsEmpty) {
                        System.debug('케어용품, BillToCode, 단종 확인 완료');

                        /** ProductRequest, ProductRequestLineItem Upsert */
//                        strQuery = '';
//                        strQuery += ' SELECT ' + SObjectUtil.getFieldForQuery('ProductRequest');
//                        strQuery += ' FROM ProductRequest ';
//                        strQuery += ' WHERE Order_Number__c = \'' + carePlustOrderNo + '\' ';
//                        strQuery += ' AND Order_CHNL_TYPE_Code__c = \'BestShop\' ';
//                        strQuery += ' AND RecordTypeId = \'' + EX_ConsumableUtil.PR_CARE_SUPPLIES_RECORDTYPE_ID + '\' ';
//                        List<ProductRequest> prList = Database.query(strQuery);
                        List<ProductRequest> prList = new List<ProductRequest>();
                        if(!productRequestList.isEmpty()){
                            system.debug('productRequestList size chk : ' + productRequestList.size());
                            for(ProductRequest pr : productRequestList){
                                if(carePlustOrderNo.equals(pr.Order_Number__c)){
                                    prList.add(pr);
                                }
                            }
                        }

                        //List<ProductRequestLineItem> prliList = new List<ProductRequestLineItem>();
                        //참고 소스 : EX_SuppliesController - doSaveConsumableOrder
                        if (prList.isEmpty()) { //Insert
                            /** ProductRequest */
                            ProductRequest pr = new ProductRequest();
                            if(accountId != null && !accountId.equals('')){
                                system.debug('accountId : ' + accountId);
                                pr.AccountId = accountId;
                                pr.Order_CUST_Address__c = accountAddr;	//고객주소
                                //pr.Order_CUST_Address_DETAIL__c = accountAddr;	//고객상세주소
                                pr.Order_CUST_Name__c = accountName;	//주문고객명
                                pr.Order_CUST_PostalCode__c = accountPostal;	//고객우편번호
                                pr.Order_CUST_TPNO_1__c = accountTel;	//고객전화번호1
                                //pr.Order_CUST_TPNO_2__c = '';	//고객전화번호2
                                if(contactId != null && !contactId.equals('')){
                                    pr.Order_CUST_Id__c = contactId;
                                }
                            }
                            if(departmentId != null){
                                pr.Department_Id__c = departmentId;
                            }
                            if(warehouseLocationId != null){
                                pr.SourceLocationId = warehouseLocationId;
                            }
                            pr = setProductRequest(lData, pr);
                            listInsertPR.add(pr);
                            nowPR = pr;

                            /** ProductRequestLineItem */
                            ProductRequestLineItem prli = new ProductRequestLineItem();
                            prli = setProductRequestLineItem(lData, pr, prli, mPartData, piforPrli, false);
                            listInsertPRLI.add(prli);
                            nowPRLI = prli;

                            //prIdList.add(pr.Id);
                            //prliIdList.add(prli.Id);
                        } else { //Update
                            for (ProductRequest pr : prList) {
                                if(!accountId.equals('')){
                                    pr.AccountId = accountId;
                                    pr.Order_CUST_Address__c = accountAddr;	//고객주소
                                    //pr.Order_CUST_Address_DETAIL__c = accountAddr;	//고객상세주소
                                    pr.Order_CUST_Name__c = accountName;	//주문고객명
                                    pr.Order_CUST_PostalCode__c = accountPostal;	//고객우편번호
                                    pr.Order_CUST_TPNO_1__c = accountTel;	//고객전화번호1
                                    //pr.Order_CUST_TPNO_2__c = '';	//고객전화번호2
                                    if(contactId != null && !contactId.equals('')){
                                        pr.Order_CUST_Id__c = contactId;
                                    }
                                }
                                if(departmentId != null){
                                    pr.Department_Id__c = departmentId;
                                }
                                if(warehouseLocationId != null){
                                    pr.SourceLocationId = warehouseLocationId;
                                }
                                /** ProductRequest */
                                pr = setProductRequest(lData, pr);
                                listUpsertPR.add(pr);
                                nowPR = pr;
                                /** ProductRequestLineItem */
//                                strQuery = '';
//                                strQuery += ' SELECT ' + SObjectUtil.getFieldForQuery('ProductRequestLineItem');
//                                strQuery += ' FROM ProductRequestLineItem ';
//                                strQuery += ' WHERE Order_Number__c = \'' + carePlustOrderNo + '\' ';
//                                strQuery += ' AND Order_CHNL_TYPE_Code__c = \'BestShop\' ';
//                                strQuery += ' AND PART_NO__c = \'' + sPartNo + '\' ';
//                                strQuery += ' AND RecordTypeId = \'' + EX_ConsumableUtil.PRLI_CARE_SUPPLIES_RECORDTYPE_ID + '\' ';
//                                List<ProductRequestLineItem> existPrliList = Database.query(strQuery);
                                List<ProductRequestLineItem> existPrliList = new List<ProductRequestLineItem>();
                                if(!productRequestLineItemList.isEmpty()){
                                    for(ProductRequestLineItem prli : productRequestLineItemList){
                                        if(carePlustOrderNo.equals(prli.Order_Number__c) && sPartNo.equals(prli.PART_NO__c)){
                                            existPrliList.add(prli);
                                        }
                                    }
                                }
                                if (existPrliList.isEmpty()) { //기존 ProductRequestLineItem 없으면
                                    ProductRequestLineItem prli = new ProductRequestLineItem();
                                    //prli도 기존 것 검사
                                    prli = setProductRequestLineItem(lData, pr, prli, mPartData, piforPrli, false);
                                    //prliList.add(prli);
                                    listUpsertPRLI.add(prli);
                                    nowPRLI = prli;
                                    //prliIdList.add(prli.Id);
                                } else { //기존 ProductRequestLineItem 있으면
                                    for (ProductRequestLineItem prli : existPrliList) {
                                        prli = setProductRequestLineItem(lData, pr, prli, mPartData, piforPrli, true);
                                        //prliList.add(prli);
                                        listUpsertPRLI.add(prli);
                                        nowPRLI = prli;
                                        //prliIdList.add(prli.Id);
                                    }
                                }
                                //prIdList.add(pr.Id);
                            }
                            //upsert prList;
                            //upsert prliList;
                        }

                        /*
                         * 주문요청에 최초 WORK_FLAG 값이 'N' 인경우 ERP에 값을 전송한다 ERP에서는
                         * 주문정보을 생성하고 여신체크하여 결과값을 리턴해준다 I/F방식은 MQ 방식
                         */
                        if ('N'.equals(nowWorkFlag)) {
                            /** ERP 데이터 전송(MQ) */
                            SI_CAREPLUS_ORDER_REQUEST__c siR = new SI_CAREPLUS_ORDER_REQUEST__c();
                            siR = insertSiCareplusOrderRequest(ldata, false, null, loopCnt2, requestMaxInterfaceId);
                            listInsertSiRequest.add(siR);
                            result = 'SUCCESS';
                            workFlag = 'I';
                            loopCnt2++;
                        } //nowWorkFlag 'N' 끝

                        if ('I'.equals(nowWorkFlag) || 'H'.equals(nowWorkFlag) || 'O'.equals(nowWorkFlag) || 'D'.equals(nowWorkFlag)) {

                            /** ERP 주문생성 결과 조회 */
                            system.debug('ERP 주문생성 결과 조회');
                            //List<SI_CAREPLUS_ORDER_COMPLETE__c> orderCompleteMDataList = getSiCareplusOrderComplete(carePlustOrderNo, sPartNo, 'N', 'PO');
                            List<SI_CAREPLUS_ORDER_COMPLETE__c> orderCompleteMDataList = new List<SI_CAREPLUS_ORDER_COMPLETE__c>();
                            for(SI_CAREPLUS_ORDER_COMPLETE__c scoc : orderCompleteYPOList){
                                if(scoc.ORIG_SYS_DOCUMENT_REF__c == carePlustOrderNo && scoc.ITEM_NO__c == sPartNo && scoc.WORK_FLAG__c == 'N'){
                                    System.debug('Add orderCompleteMDataList OrderNo : ' + carePlustOrderNo + ', sPartNo : ' + sPartNo);
                                    orderCompleteMDataList.add(scoc);
                                }
                            }

                            if (orderCompleteMDataList.isEmpty()) { //ERP 주문생성 결과 조회 없음
                                system.debug('ERP 주문생성 결과 조회 없음');
                                if ('I'.equals(nowWorkFlag)) {
                                    workFlag = 'I';
                                } else if ('H'.equals(nowWorkFlag)) {
                                    bCreditHold = true;
                                    workFlag = 'H';
                                } else if ('O'.equals(nowWorkFlag)) {
                                    bCreditHold = true;
                                    workFlag = 'O';
                                } else if ('D'.equals(nowWorkFlag)) {
                                    bCreditHold = true;
                                    workFlag = 'D';
                                }
                            } else { //ERP 주문생성 결과 조회 있음
                                system.debug('ERP 주문생성 결과 조회 있음');
                                SI_CAREPLUS_ORDER_COMPLETE__c orderCompleteMData = (SI_CAREPLUS_ORDER_COMPLETE__c) orderCompleteMDataList[0];
                                String lineStatusCode = getStringNotNull(orderCompleteMData.get('LINE_STATUS_CODE__c'));
                                if ('AWAITING_SHIPPING'.equals(lineStatusCode)) {
                                    bCreditHold = false;
                                    sAttribute10 = getStringNotNull(orderCompleteMData.get('LINE_ID__c'));
                                } else if ('CREDIT_HOLD_RELEASED'.equals(lineStatusCode)) {
                                    bCreditHold = false;
                                    sAttribute10 = getStringNotNull(orderCompleteMData.get('LINE_ID__c'));
                                } else if ('CREDIT_HOLD'.equals(lineStatusCode)) {
                                    bCreditHold = true;
                                    workFlag = 'H';
                                    result = 'SUCCESS';
                                } else if ('OVERDUE_HOLD'.equals(lineStatusCode)) {
                                    bCreditHold = true;
                                    workFlag = 'O';
                                    result = 'SUCCESS';
                                } else if ('CREDIT&OVER_DUE'.equals(lineStatusCode)) {
                                    bCreditHold = true;
                                    workFlag = 'D';
                                    result = 'SUCCESS';
                                }
                            } //ERP 주문생성 결과 조회 끝

                            if (!orderCompleteMDataList.isEmpty()) {
                                /**  ERP 주문생성 결과 테이블 WORK_FLAG 업데이트 */
                                if ('SUCCESS'.equals(result)) {
                                    SI_CAREPLUS_ORDER_COMPLETE__c orderCompleteMData = (SI_CAREPLUS_ORDER_COMPLETE__c) orderCompleteMDataList[0];

                                    /*update new SI_CAREPLUS_ORDER_COMPLETE__c(
                                            Id = orderCompleteMData.Id,
                                            WORK_FLAG__c = 'Y',
                                            WORK_DATE__c = Date.today()
                                    );*/

                                    SI_CAREPLUS_ORDER_COMPLETE__c siC = new SI_CAREPLUS_ORDER_COMPLETE__c();
                                    siC.Id = orderCompleteMData.Id;
                                    siC.WORK_FLAG__c = 'Y';
                                    siC.WORK_DATE__c = System.now();
                                    listUpdateComplete.add(siC);

                                }
                            }
                        } //I,H,O,D 검사 끝
                        if (!bCreditHold && !'I'.equals(workFlag) && !'H'.equals(workFlag) && !'O'.equals(workFlag) && !'D'.equals(workFlag)) {
                        //if (1==1) {
                            // 가용재고 조회
//                            List<ProductItem> piList = [
//                                    SELECT fm_Available_Quantity__c
//                                    FROM ProductItem
//                                    WHERE fm_Available_Quantity__c >= :orderQty
//                                    AND fm_DEPT_CODE__c = :F_ST_DEPT_CODE
//                                    AND DIV_CODE__c = :sDivCode
//                                    AND fm_Parts_Number__c = :sPartNo
//                            ];

                            List<ProductItem> piList = new List<ProductItem>();
                            if(!ProductItemList.isEmpty()){
                                for(ProductItem pi : ProductItemList){
                                    //fm_Available_Quantity__c, DIV_CODE__c, fm_Parts_Number__c
                                    if(pi.DIV_CODE__c.equals(sDivCode) && pi.fm_Parts_Number__c.equals(sPartNo) && pi.fm_Available_Quantity__c >= orderQty){
                                        piList.add(pi);
                                    }
                                }
                            }

                            if (!piList.isEmpty()) { /* 가용재고 있음 */
                                system.debug('가용재고 존재');
                                reqType = 'A'; // 요청유형
                                workFlag = 'Y';
                                shipQty = orderQty;
                                if (attribute2 != null && !''.equals(attribute2)) { // RESERV_NO 예약번호가 있는경우
                                    if (orderQty == nowPRLI.ENDP_RSV_Quantity__c) { //입고완료 : 요청수량 == 사업부입고수량
                                        if (nowPRLI.Adjust_Quantity__c != null && nowPRLI.Adjust_Quantity__c == orderQty) { //정리수량 있음
                                            result = 'SUCCESS';
                                        } else { //정리수량 없음
                                            /** 약속정리(약속취소) */
                                            system.debug('약속정리');
                                            //EX_RsrvUtil.CANCEL_RESRV(nowPRLI, 'AE'); //'AE' : 사업부약속취소(재입고알림)
                                            rsrvCancelMap.put('ProductRequestLineItem',nowPRLI);
                                            rsrvCancelMap.put('code','AE');
                                            rsrvCancelMapList.add(rsrvCancelMap);
                                        }//정리수량 검사 끝
                                        workFlag = 'C';
                                        cancelQty = orderQty;
                                        cancelFlag = 'Y';
                                    } else { // 입고안됨
                                        workFlag = '';
                                        shipQty = 0;
                                        if (nowPRLI.Adjust_Quantity__c != null && nowPRLI.Adjust_Quantity__c == orderQty) { //정리수량
                                            //사용자 취소
                                            workFlag = 'C';
                                            cancelQty = orderQty;
                                            cancelFlag = 'Y';
                                        }
                                        result = 'SUCCESS';
                                    } //입고 검사 끝
                                } else { // RESERV_NO 예약번호가 없는경우
                                    /** 할당수량 증가 재고 공통모듈 호출 */
                                    //EX_RsrvUtil.execApplyProductItem(orderQty, 'AA', nowPRLI);
                                    execApplyPRLI.add(nowPRLI);
                                } // RESERV_NO 예약번호체크 끝
                            } else { /* 가용재고 없음 */
                                system.debug('가용재고 없음');
                                reqType = 'S'; // 요청유형
                                if (!'R'.equals(nowWorkFlag)) {
                                    //사업부 조회
                                    String resrvNo = '';
                                    String orderNo = '';
                                    Integer orderSeq = 1;
                                    workFlag = 'R';
                                    shipQty = 0;

                                    //Map<String, Object> rtnMap = new Map<String, Object>();
                                    Map<String, Object> mapItem = new Map<String, Object>();
                                    if(!prList.isEmpty()){
                                        mapItem.put('oriPrId', nowPR.Id); //원주문 ProductRequestId
                                        mapItem.put('oriPrliId', nowPRLI.Id); //원주문 ProductRequestLineItemId
                                        mapItem.put('oriOrderNo', nowPRLI.Order_Number__c); //원주문번호
                                        mapItem.put('oriOrderSeq', nowPRLI.Order_SEQ__c); //원주문Seq
                                    }else{
                                        //mapItem.put('oriPrId', nowPR.Id); //원주문 ProductRequestId
                                        //mapItem.put('oriPrliId', nowPRLI.Id); //원주문 ProductRequestLineItemId
                                        mapItem.put('oriOrderNo', nowPRLI.Order_Number__c); //원주문번호
                                        mapItem.put('oriOrderSeq', nowPRLI.Order_SEQ__c); //원주문Seq
                                    }

                                    mapItem.put('deptCode', F_ST_DEPT_CODE); //부서코드
                                    mapItem.put('partNo', sPartNo); //파트넘버
                                    mapItem.put('req_qty', orderQty); //요청수량
                                    mapItem.put('div_code', sDivCode); //사업부
                                    mapList.add(mapItem);
//                                    /** 약속모듈 호출 */
//                                    system.debug('약속생성');
//                                    rtnMap = EX_RsrvUtil.RESRV_MODULE(mapList);
//                                    if (rtnMap.get('isSuccess') != null && Boolean.valueOf(rtnMap.get('isSuccess'))) {
//                                        result = 'SUCCESS';
//                                        if (rtnMap.get('rsrvNo') != null) {
//                                            rsrvNo = getStringNotNull(rtnMap.get('rsrvNo'));
//                                        }
//                                    } else { //약속관련 공통모듈(다건) 호출 실패
//                                        result = getStringNotNull(rtnMap.get('errMsg'));
//                                    }
//
//                                    lData.put('ATTRIBUTE2__c', resrvNo);
                                    lData.put('ATTRIBUTE3__c', orderNo);
                                    lData.put('ATTRIBUTE4__c', getStringNotNull(orderSeq));

                                    if (result.equals('SUCCESS')) {
                                    } else {
                                        workFlag = 'E';
                                        sAttribute1 = result;
                                    }
                                } // nowworkflag 'R' 검사 끝
                            }// 가용재고 검사 끝
                        } //I,H,O,D 검사 끝
                    } else { //케어용품, BillToCode, 단종, customerNo 미충족
                        System.debug('케어용품, BillToCode, 단종 미충족');
                        /* 케어용품체크 결과 */
                        if (mPartData.isEmpty()) {
                            sAttribute1 = sAttribute1 + 'PART_NO : ' + sPartNo + ' 케어용품아님,';
                            result = 'SUCCESS';
                        }
                        /* BILL TO CODE 체크 결과 */
                        if (!bBilltoCheckPass) {
                            sAttribute1 = sAttribute1 + ' BILLTOCODE : ' + billToCode + ' 미존재,';
                            result = 'SUCCESS';
                        }
                        /* 단종여부 체크 결과 */
                        if (bDisabled) {
                            sAttribute1 = sAttribute1 + 'PART_NO : ' + sPartNo + ' 단종';
                            result = 'SUCCESS';
                        }
                        /* CUSTOMER_NO 체크 결과 */
                        if (customerNoIsEmpty) {
                            sAttribute1 = sAttribute1 + 'CUSTOMER_NO 미존재';
                            result = 'SUCCESS';
                        }
                        /* 여신 체크 결과 */
                        if (bCreditHold) {
                            workFlag = 'H';
                            result = 'SUCCESS';
                        }
                        if (mPartData.isEmpty() || !bBilltoCheckPass || bDisabled || customerNoIsEmpty) {
                            workFlag = 'E';
                        }
                    } //케어용품, BillToCode, 단종, customerNo 체크 끝
                    if ('R'.equals(nowWorkFlag) && ''.equals(workFlag)) {
                        workFlag = nowWorkFlag;
                    }
                    System.debug('lData.Id : ' + lData.Id + ', carePlustOrderNo : ' + carePlustOrderNo + ', nowWorkFlag : ' + nowWorkFlag + ', workFlag : ' + workFlag);
                    if (!nowWorkFlag.equals(workFlag)) {
                        if ('SUCCESS'.equals(result)) {

                            lData.put('CANCEL_FLAG__c', cancelFlag);
                            lData.put('WORK_FLAG__c', workFlag);
                            lData.put('ATTRIBUTE1__c', sAttribute1);
                            lData.put('ATTRIBUTE10__c', sAttribute10);

                            /** SI_CAREPLUS_ORDER 테이블 WORK_FLAG 업데이트 */
                            SI_CAREPLUS_ORDER__c siO = new SI_CAREPLUS_ORDER__c();
                            siO.Id = lData.Id;
                            siO.ORDER_NO__c = carePlustOrderNo;
                            siO.WORK_FLAG__c = workFlag;
                            siO.ATTRIBUTE1__c = sAttribute1;
                            siO.ATTRIBUTE10__c = sAttribute10;
                            siO.LAST_UPDATED_BY__c = 'SYSTEM';
                            siO.LAST_UPDATE_DATE__c = System.now();
                            listUpdateSiOrder.add(siO);

                            result = 'SUCCESS';

                            lData.put('CANCEL_QTY__c', cancelQty);

                            /** ProductRequest 테이블 업데이트 */
                            //WORK_FLAG에 따른 TO-BE 상태도 update (소모품주문상태 Consumables_Order_Status__c : EX_ConsumableUtil 참고)
                            for(ProductRequest pr_u : listInsertPR){
                                if(pr_u.Order_Number__c == getStringNotNull(lData.get('ORDER_NO__c'))){
                                    pr_u.BACK_IF_SEND_YN__c = true;
                                    pr_u.BILL_TO_CODE__c = billToCode;
                                    /** 상태:결제완료 시 Update*/
                                    //결제여부
                                    pr_u.PAYMENT_YN__c = true;
                                    //결제전송일시
                                    pr_u.PAYMENT_COMPLETED_DTM__c = getDatetimeWithNull(lData.get('ORDER_DATE__c'));
                                    //결제요청일시
                                    pr_u.PAYMENT_REQUEST_DATE__c = getDatetimeWithNull(lData.get('ORDER_DATE__c'));
                                    //승인일자 date
                                    pr_u.APPR_DT__c = Date.today();
                                    //결제유형
                                    pr_u.PAYMENT_TYPE__c = 'B2B';
                                }
                            }
                            for(ProductRequest pr_u : listUpsertPR){
                                if(pr_u.Order_Number__c == getStringNotNull(lData.get('ORDER_NO__c'))){
                                    pr_u.BACK_IF_SEND_YN__c = true;
                                    pr_u.BILL_TO_CODE__c = billToCode;
                                    /** 상태:결제완료 시 Update*/
                                    //결제여부
                                    pr_u.PAYMENT_YN__c = true;
                                    //결제전송일시
                                    pr_u.PAYMENT_COMPLETED_DTM__c = getDatetimeWithNull(lData.get('ORDER_DATE__c'));
                                    //결제요청일시
                                    pr_u.PAYMENT_REQUEST_DATE__c = getDatetimeWithNull(lData.get('ORDER_DATE__c'));
                                    //승인일자 date
                                    pr_u.APPR_DT__c = Date.today();
                                    //결제유형
                                    pr_u.PAYMENT_TYPE__c = 'B2B';
                                }
                            }
                            result = 'SUCCESS';

                            /** ProductRequestLineItem 테이블 업데이트 */
                            //Consumables_Order_Status__c
                            String orderStatus = setOrderStatus(workFlag);

                            if (cancelFlag != null && cancelFlag.equals('Y')) {
                                for(ProductRequestLineItem prli_u : listInsertPRLI){
                                    if(prli_u.Order_Number__c == getStringNotNull(lData.get('ORDER_NO__c'))){
                                        prli_u.SHIP_QTY__c = shipQty;
                                        prli_u.Consumables_Order_Status__c = orderStatus;
                                        prli_u.CANCEL_Quantity__c = cancelQty;
                                        prli_u.CANCEL_Reason__c = '사용자 주문취소';
                                        prli_u.CANCEL_Date__c = Date.today();
                                        prli_u.CANCEL_User__c = 'SYSTEM';
                                        prli_u.CONSUMABLES_ERROR__c = sAttribute1;
                                    }
                                }
                                for(ProductRequestLineItem prli_u : listUpsertPRLI){
                                    if(prli_u.Order_Number__c == getStringNotNull(lData.get('ORDER_NO__c'))){
                                        prli_u.SHIP_QTY__c = shipQty;
                                        prli_u.Consumables_Order_Status__c = orderStatus;
                                        prli_u.CANCEL_Quantity__c = cancelQty;
                                        prli_u.CANCEL_Reason__c = '사용자 주문취소';
                                        prli_u.CANCEL_Date__c = Date.today();
                                        prli_u.CANCEL_User__c = 'SYSTEM';
                                        prli_u.CONSUMABLES_ERROR__c = sAttribute1;
                                    }
                                }
                            }else{
                                for(ProductRequestLineItem prli_u : listInsertPRLI){
                                    if(prli_u.Order_Number__c == getStringNotNull(lData.get('ORDER_NO__c'))){
                                        prli_u.SHIP_QTY__c = shipQty;
                                        prli_u.Consumables_Order_Status__c = orderStatus;
                                        prli_u.CONSUMABLES_ERROR__c = sAttribute1;
                                    }
                                }
                                for(ProductRequestLineItem prli_u : listUpsertPRLI){
                                    if(prli_u.Order_Number__c == getStringNotNull(lData.get('ORDER_NO__c'))){
                                        prli_u.SHIP_QTY__c = shipQty;
                                        prli_u.Consumables_Order_Status__c = orderStatus;
                                        prli_u.CONSUMABLES_ERROR__c = sAttribute1;
                                    }
                                }
                            }
                            result = 'SUCCESS';

                            Double shipAmt = 0;
                            if ('Y'.equals(workFlag)) {
                                shipQty = orderQty; //출고수량
                                shipAmt = orderAmt; //판매금액
                            } else {
                                shipQty = 0; //출고수량
                                shipAmt = 0; //판매금액
                            }

                            /** BACK_IF 생성 */
                            String back_if_status = '';
                            String back_if_error_desc = '';
                            String trans_type = '';
                            if ('E'.equals(workFlag)) {
                                back_if_status = 'ERROR';
                                back_if_error_desc = sAttribute1;
                                sAttribute1 = '';
                            } else if ('R'.equals(workFlag)) {
                                back_if_status = 'BACKORDER_HOLD';
                            } else if ('Y'.equals(workFlag)) {
                                back_if_status = 'AWAITING_SHIPPING';
                            } else if ('C'.equals(workFlag)) {
                                back_if_status = 'SMILE_CANCELLED';
                                trans_type = 'C';

                                /**
                                 * CAREPLUS 3차 SMILE_CANCELLED 일때도 ERP에 취소 요청을 보낸다.
                                 */
                                /** ERP 주문생성 결과 조회 */
                                //List<SI_CAREPLUS_ORDER_COMPLETE__c> orderCompleteMDataList = getSiCareplusOrderComplete(carePlustOrderNo, sPartNo, 'Y', 'PO');
                                List<SI_CAREPLUS_ORDER_COMPLETE__c> orderCompleteMDataList = new List<SI_CAREPLUS_ORDER_COMPLETE__c>();
                                for(SI_CAREPLUS_ORDER_COMPLETE__c scoc : orderCompleteYPOList){
                                    if(scoc.ORIG_SYS_DOCUMENT_REF__c == carePlustOrderNo && scoc.ITEM_NO__c == sPartNo && scoc.WORK_FLAG__c == 'Y'){
                                        orderCompleteMDataList.add(scoc);
                                    }
                                }

                                if (!orderCompleteMDataList.isEmpty()) { //ERP 주문생성 결과 조회 있음
                                    SObject orderRequestLData = ldata;
                                    /** ERP 데이터 전송 (SI_CAREPLUS_ORDER_REQUEST__c) */
                                    SI_CAREPLUS_ORDER_REQUEST__c siR = new SI_CAREPLUS_ORDER_REQUEST__c();
                                    siR = insertSiCareplusOrderRequest(orderRequestLData, true, orderCompleteMDataList[0].LINE_ID__c, loopCnt2, requestMaxInterfaceId);
                                    listInsertSiRequest.add(siR);
                                    result = 'SUCCESS';
                                    loopCnt2++;
                                }
                            } else if ('H'.equals(workFlag)) {
                                back_if_status = 'CREDIT_HOLD';
                            } else if ('I'.equals(workFlag)) {
                                back_if_status = 'CREDIT_CHECKING';
                            } else if ('O'.equals(workFlag)) {
                                back_if_status = 'OVERDUE_HOLD';
                            } else if ('D'.equals(workFlag)) {
                                back_if_status = 'CREDIT&OVER_DUE';
                            }

                            /** SI_CAREPLUS_BACKIF 테이블에 저장 */
                            if ('SUCCESS'.equals(result)) {
                                SI_CAREPLUS_BACKIF__c siB = new SI_CAREPLUS_BACKIF__c();
                                siB = insertCareplusBackIf(lData, back_if_status, back_if_error_desc, shipQty, shipAmt, loopCnt, backIfMaxInterfaceId, backIfSubMaxInterfaceId);
                                listInsertSiBackIf.add(siB);
                                result = 'SUCCESS';
                                loopCnt++;
                            }
                        } //result 성공여부 검사 끝
                    } //nowWorkFlag == workFlag 검사 끝
                } //for(SI_CAREPLUS_ORDER__c) 끝
                if(!rsrvCancelMapList.isEmpty()){
                    EX_RsrvUtil.CANCEL_RESRV_MULTI(rsrvCancelMapList);
                }
                if(!listInsertPR.isEmpty()){
                    insert listInsertPR;
                    system.debug('INSERT ProductRequest TOTAL : ' + listInsertPR.size());

                    if(!listInsertPRLI.isEmpty()){
                        for(ProductRequestLineItem prli : listInsertPRLI){
                            for(ProductRequest pr : listInsertPR){
                                if(prli.Order_Number__c == pr.Order_Number__c){
                                    prli.parentId = pr.Id;
                                    break;
                                }
                            }
                        }
                        insert listInsertPRLI;
                        system.debug('INSERT ProductRequest TOTAL : ' + listInsertPRLI.size());
                    }
                }
                if(!listUpsertPR.isEmpty()){
                    upsert listUpsertPR;
                    system.debug('UPSERT ProductRequest TOTAL : ' + listUpsertPR.size());
                }
                if(!listUpsertPRLI.isEmpty()){
                    upsert listUpsertPRLI;
                    system.debug('UPSERT ProductRequestLineItem TOTAL : ' + listUpsertPRLI.size());
                }

                List<String> rsrvOrderNoList = new List<String>();
                if(!mapList.isEmpty()){
                    for(Map<String, Object> mapItem : mapList){
                        //이미 생성이 되있는 주문건은 PRID, PRLIID가 세팅되어있음
                        if(!listInsertPRLI.isEmpty()){
                            for(ProductRequestLineItem prli : listInsertPRLI){
                                if(prli.Order_Number__c == getStringNotNull(mapItem.get('oriOrderNo')) && prli.Order_SEQ__c == getDecimalNotNull(mapItem.get('oriOrderSeq'))){
                                    mapItem.put('oriPrId', prli.ParentId); //원주문 ProductRequestId
                                    mapItem.put('oriPrliId', prli.Id); //원주문 ProductRequestLineItemId
                                }
                            }
                        }
                        String orderNo = getStringNotNull(mapItem.get('oriOrderNo'));
                        rsrvOrderNoList.add(orderNo);
                    }
                    system.debug('약속생성');
                    Map<String, Object> rtnMap = new Map<String, Object>();
                    rtnMap = EX_RsrvUtil.RESRV_MODULE(mapList);
                }

                if(!listUpdateComplete.isEmpty()){
                    update listUpdateComplete;
                    system.debug('UPDATE SI_CAREPLUS_ORDER_COMPLETE TOTAL : ' + listUpdateComplete.size());
                }
                if(!execApplyPRLI.isEmpty()){
                    /** 할당수량 증가 재고 공통모듈 호출 */
                    EX_RsrvUtil.execApplyProductItemMulti('AA',execApplyPRLI);
                    system.debug('execApplyPRLI TOTAL : ' + execApplyPRLI.size());
                }
                if(!listInsertSiBackIf.isEmpty()){
                    Insert listInsertSiBackIf;
                    system.debug('INSERT SI_CAREPLUS_BACKIF TOTAL : ' + listInsertSiBackIf.size());
                }
                if(!listInsertSiRequest.isEmpty()){
                    Insert listInsertSiRequest;
                    system.debug('INSERT SI_CAREPLUS_ORDER_REQUEST TOTAL : ' + listInsertSiRequest.size());
                }
                if(!listUpdateSiOrder.isEmpty()){
                    List<ProductRequest> rsrvPrList = new List<ProductRequest>();
                    rsrvPrList = [SELECT Id, Order_Number__c, RSRV_Number__c FROM ProductRequest WHERE Order_Number__c IN :rsrvOrderNoList];
                    for(SI_CAREPLUS_ORDER__c sio : listUpdateSiOrder){
                        for(ProductRequest rsrvPr : rsrvPrList){
                            if(sio.ORDER_NO__c == rsrvPr.Order_Number__c){
                                sio.ATTRIBUTE2__c = rsrvPr.RSRV_Number__c;
                            }
                        }
                    }
                    update listUpdateSiOrder;
                    system.debug('UPDATE SI_CAREPLUS_ORDER TOTAL : ' + listUpdateSiOrder.size());
                }

            } else {
                objOutput.code = '500';
                objOutput.message = '케어플러스 주문수신 실패. SI_CAREPLUS_ORDER__c 데이터 없음.';
                Database.rollback(sp);
            }//siCarePlusOrderList isEmpty
        }catch (JSONException je){
            System.debug('*** je.getMessage: ' + je.getMessage());
            System.debug('*** je.getLine -> ' + je.getLineNumber());
            objOutput.code = '500';
            objOutput.message = 'reason:'+je.getMessage();
            Database.rollback(sp);
        } catch (NullPointerException ne){
            System.debug('*** ne.getMessage: ' + ne.getMessage());
            System.debug('*** ne.getLine -> ' + ne.getLineNumber());
            objOutput.code = '500';
            objOutput.message = ' 조회된 값이 없습니다.  '+ ne.getMessage();
            Database.rollback(sp);
        } catch (Exception e) {
            System.debug('*** e.getMessage: ' + e.getMessage());
            System.debug('*** e.getLine -> ' + e.getLineNumber());
            objOutput.code = '500';
            objOutput.message =  e.getMessage();
            Database.rollback(sp);
        }

        return objOutput;
    }
    @AuraEnabled
    public static SI_CAREPLUS_BACKIF__c insertCareplusBackIf(sObject lData, String back_if_status, String back_if_error_desc, Integer shipQty, Double ShipAmt, Integer LoopCnt, Integer backIfMaxInterfaceId, Integer backIfSubMaxInterfaceId) {
        /** SI_CAREPLUS_BACKIF 테이블에 저장 */
        Decimal maxNum = backIfMaxInterfaceId + LoopCnt;
        /*List<SI_CAREPLUS_BACKIF__c> getMaxList = new List<SI_CAREPLUS_BACKIF__c>();
        getMaxList = [SELECT INTERFACE_ID__c FROM SI_CAREPLUS_BACKIF__c ORDER BY INTERFACE_ID__c DESC LIMIT 1];
        if(!getMaxList.isEmpty()){
            SI_CAREPLUS_BACKIF__c getMax = getMaxList[0];
            if(getMax.INTERFACE_ID__c != null && getMax.INTERFACE_ID__c > 0){
                maxNum = getMax.INTERFACE_ID__c + LoopCnt;
            }
        }*/

        Decimal ifId = getDecimalNotNull(lData.get('INTERFACE_ID__c'));
        String t_type = getStringNotNull(lData.get('TRANS_TYPE__c'));
        String oNo = getStringNotNull(lData.get('ORDER_NO__c'));

        Decimal maxSubNum = backIfSubMaxInterfaceId + 1;
        /*List<SI_CAREPLUS_BACKIF__c> getMaxSubList = new List<SI_CAREPLUS_BACKIF__c>();
        getMaxSubList = [SELECT BACK_SUB_SEQ__c FROM SI_CAREPLUS_BACKIF__c WHERE INTERFACE_ID__c = :ifId AND TRANS_TYPE__c = :t_type AND ORDER_NO__c = :oNo ORDER BY BACK_SUB_SEQ__c DESC LIMIT 1];
        if(!getMaxSubList.isEmpty()){
            SI_CAREPLUS_BACKIF__c getMaxSub = getMaxSubList[0];
            if(getMaxSub.BACK_SUB_SEQ__c != null && getMaxSub.BACK_SUB_SEQ__c > 0){
                maxSubNum = getMaxSub.BACK_SUB_SEQ__c + 1;
            }
        }*/

        SI_CAREPLUS_BACKIF__c siCareplusBackif = new SI_CAREPLUS_BACKIF__c();
        siCareplusBackif.INTERFACE_ID__c = maxNum;
        siCareplusBackif.TRANS_TYPE__c = t_type;
        siCareplusBackif.ORDER_NO__c = oNo;
        siCareplusBackif.REQUEST_NO__c = getStringNotNull(lData.get('REQUEST_NO__c'));
        siCareplusBackif.REQUEST_SEQ__c = getDecimalNotNull(lData.get('REQUEST_SEQ__c'));
        siCareplusBackif.BACK_SUB_SEQ__c = maxSubNum;
        siCareplusBackif.ORDER_DATE__c = getDatetimeWithNull(lData.get('ORDER_DATE__c'));
        siCareplusBackif.BILL_TO_CODE__c = getStringNotNull(lData.get('BILL_TO_CODE__c'));
        siCareplusBackif.DIV_CODE__c = getStringNotNull(lData.get('DIV_CODE__c'));
        siCareplusBackif.MODEL_CODE__c = getStringNotNull(lData.get('MODEL_CODE__c'));
        siCareplusBackif.PART_NO__c = getStringNotNull(lData.get('PART_NO__c'));
        siCareplusBackif.ORDER_QTY__c = getDecimalNotNull(lData.get('ORDER_QTY__c'));
        siCareplusBackif.SHIPPED_QTY__c = shipQty;
        siCareplusBackif.CANCEL_QTY__c = getDecimalNotNull(lData.get('CANCEL_QTY__c'));
        siCareplusBackif.ORDER_PRICE__c = getDecimalNotNull(lData.get('ORDER_PRICE__c'));
        siCareplusBackif.ORDER_AMT__c = getDecimalNotNull(lData.get('ORDER_AMT__c'));
        siCareplusBackif.SHIP_AMT__c = ShipAmt;
        siCareplusBackif.RECEIVER_NAME__c = getStringNotNull(lData.get('RECEIVER_NAME__c'));
        siCareplusBackif.SHIP_TO_CODE__c = getStringNotNull(lData.get('SHIP_TO_CODE__c'));
        siCareplusBackif.POSTAL_CODE__c = getStringNotNull(lData.get('POSTAL_CODE__c'));
        siCareplusBackif.BASIC_ADDRESS__c = getStringNotNull(lData.get('BASIC_ADDRESS__c'));
        siCareplusBackif.DETAIL_ADDRESS__c = getStringNotNull(lData.get('DETAIL_ADDRESS__c'));
        siCareplusBackif.RECEIVER_PHONE_NO__c = getStringNotNull(lData.get('RECEIVER_PHONE_NO__c'));
        siCareplusBackif.ORIGINAL_REQUEST_NO__c = getStringNotNull(lData.get('ORIGINAL_REQUEST_NO__c'));
        siCareplusBackif.ORIGINAL_REQUEST_SEQ__c = getDecimalNotNull(lData.get('ORIGINAL_REQUEST_SEQ__c'));
        //siCareplusBackif.BOOKED_FLAG__c = getStringNotNull(lData.BOOKED_FLAG__c);
        siCareplusBackif.CANCEL_FLAG__c = getStringNotNull(lData.get('CANCEL_FLAG__c'));
        if(lData.get('CANCEL_FLAG__c') != null && !lData.get('CANCEL_FLAG__c').equals('')){
            siCareplusBackif.CANCEL_DATE__c = getDatetimeWithNull(lData.get('CANCEL_DATE__c'));
        }
        siCareplusBackif.ORDER_DESCRIPTION__c = getStringNotNull(lData.get('ORDER_DESCRIPTION__c'));
        siCareplusBackif.BACK_IF_STATUS__c = back_if_status;
        siCareplusBackif.BACK_IF_ERROR_DESC__c = back_if_error_desc;
        siCareplusBackif.TRANSFER_FLAG__c = 'N';
        siCareplusBackif.ATTRIBUTE1__c = getStringNotNull(lData.get('ATTRIBUTE1__c'));
        siCareplusBackif.ATTRIBUTE2__c = getStringNotNull(lData.get('ATTRIBUTE2__c'));
        siCareplusBackif.ATTRIBUTE3__c = getStringNotNull(lData.get('ATTRIBUTE3__c'));
        siCareplusBackif.ATTRIBUTE4__c = getStringNotNull(lData.get('ATTRIBUTE4__c'));
        siCareplusBackif.ATTRIBUTE5__c = getStringNotNull(lData.get('ATTRIBUTE5__c'));
        siCareplusBackif.ATTRIBUTE6__c = getStringNotNull(lData.get('ATTRIBUTE6__c'));
        siCareplusBackif.ATTRIBUTE7__c = getStringNotNull(lData.get('ATTRIBUTE7__c'));
        siCareplusBackif.ATTRIBUTE8__c = getStringNotNull(lData.get('ATTRIBUTE8__c'));
        siCareplusBackif.ATTRIBUTE9__c = getStringNotNull(lData.get('ATTRIBUTE9__c'));
        siCareplusBackif.ATTRIBUTE10__c = getStringNotNull(lData.get('ATTRIBUTE10__c'));
        siCareplusBackif.NUM_ATT1__c = getDecimalNotNull(lData.get('NUM_ATT1__c'));
        siCareplusBackif.NUM_ATT2__c = getDecimalNotNull(lData.get('NUM_ATT2__c'));
        siCareplusBackif.NUM_ATT3__c = getDecimalNotNull(lData.get('NUM_ATT3__c'));
        siCareplusBackif.NUM_ATT4__c = getDecimalNotNull(lData.get('NUM_ATT4__c'));
        siCareplusBackif.NUM_ATT5__c = getDecimalNotNull(lData.get('NUM_ATT5__c'));
        siCareplusBackif.NUM_ATT6__c = getDecimalNotNull(lData.get('NUM_ATT6__c'));
        siCareplusBackif.NUM_ATT7__c = getDecimalNotNull(lData.get('NUM_ATT7__c'));
        siCareplusBackif.NUM_ATT8__c = getDecimalNotNull(lData.get('NUM_ATT8__c'));
        siCareplusBackif.NUM_ATT9__c = getDecimalNotNull(lData.get('NUM_ATT9__c'));
        siCareplusBackif.NUM_ATT10__c = getDecimalNotNull(lData.get('NUM_ATT10__c'));
        siCareplusBackif.DATE_ATT1__c = getDatetimeWithNull(lData.get('DATE_ATT1__c'));
        siCareplusBackif.DATE_ATT2__c = getDatetimeWithNull(lData.get('DATE_ATT2__c'));
        siCareplusBackif.DATE_ATT3__c = getDatetimeWithNull(lData.get('DATE_ATT3__c'));
        siCareplusBackif.DATE_ATT4__c = getDatetimeWithNull(lData.get('DATE_ATT4__c'));
        siCareplusBackif.DATE_ATT5__c = getDatetimeWithNull(lData.get('DATE_ATT5__c'));
        siCareplusBackif.CREATION_DATE__c = Date.today();
        siCareplusBackif.CREATED_BY__c = 'SYSTEM';
        siCareplusBackif.LAST_UPDATE_DATE__c = Date.today();
        siCareplusBackif.LAST_UPDATED_BY__c = 'SYSTEM';

        return siCareplusBackif;
    }

    @AuraEnabled
    public static SI_CAREPLUS_ORDER_REQUEST__c insertSiCareplusOrderRequest(sObject lData, Boolean isCancel, Decimal line_id, Integer loopCnt, Integer requestMaxInterfaceId) {
        /** ERP 데이터 전송 (SI_CAREPLUS_ORDER_REQUEST__c) */
        String result = 'SUCCESS';

        SI_CAREPLUS_ORDER_REQUEST__c siCareplusOrderRequest = new SI_CAREPLUS_ORDER_REQUEST__c();

        Decimal maxNum = requestMaxInterfaceId + loopCnt;
        siCareplusOrderRequest.SO_INTERFACE_ID__c = maxNum;
        siCareplusOrderRequest.CORPORATION_CODE__c = 'LGEKR'; /** 법인코드 */
        siCareplusOrderRequest.ORIG_SYS_DOCUMENT_REF__c = getStringNotNull(lData.get('ORDER_NO__c')); /** BEST 주문번호 */
        siCareplusOrderRequest.ORIG_SYS_LINE_REF__c = getStringNotNull(lData.get('REQUEST_SEQ__c')); /** BEST 주문 시퀀스 */
        if(isCancel){
            siCareplusOrderRequest.ORDER_TYPE__c = 'CP'; /** 주문유형 (PO : PART ORDER, CP : CANCEL PART ORDER) */
            siCareplusOrderRequest.RETURN_CONTEXT__c = 'BESTSHOP 취소 요청'; /** 취소인경우 사유 */
            siCareplusOrderRequest.ORIGINAL_LINE_ID__c = line_id; /** 원주문 LINE ID(ERP LINE ID) */
        }else{
            siCareplusOrderRequest.ORDER_TYPE__c = 'PO'; /** 주문유형 (PO : PART ORDER, CP : CANCEL PART ORDER) */
            siCareplusOrderRequest.RETURN_CONTEXT__c = ''; /** 취소인경우 사유 */
        }

        siCareplusOrderRequest.SHIP_TO_CODE__c = getStringNotNull(lData.get('SHIP_TO_CODE__c')); /** SHIP_TO CODE */
        siCareplusOrderRequest.CUSTOMER_NAME__c = getStringNotNull(lData.get('RECEIVER_NAME__c')); /** SHIP_TO NAME */
        siCareplusOrderRequest.ITEM_NO__c = getStringNotNull(lData.get('PART_NO__c'));
        siCareplusOrderRequest.ORDER_QTY__c = getIntegerNotNull(lData.get('ORDER_QTY__c'));
        siCareplusOrderRequest.CREATION_DATE__c = Date.today();
        siCareplusOrderRequest.CREATED_BY__c = 1;
        siCareplusOrderRequest.LAST_UPDATE_DATE__c = Date.today();
        siCareplusOrderRequest.LAST_UPDATED_BY__c = 1;
        siCareplusOrderRequest.CUST_PO_NO__c = getStringNotNull(lData.get('ORDER_NO__c')); /** BEST 주문번호 */
        siCareplusOrderRequest.REPLACEMENT_MODEL_CODE__c = getStringNotNull(lData.get('MODEL_CODE__c')); /** BEST MODEL_CODE */
        siCareplusOrderRequest.ORDER_SOURCE_NAME__c = 'OMV_CSONE';
        siCareplusOrderRequest.ATTRIBUTE1__c = getStringNotNull(getDoubleNotNull(lData.get('ORDER_PRICE__c'))); //단가
        siCareplusOrderRequest.ATTRIBUTE2__c = getStringNotNull(lData.get('DIV_CODE__c')); //사업부코드
        siCareplusOrderRequest.TRANSFER_FLAG__c = 'N';
        siCareplusOrderRequest.AUTHORIZED_SERVICE_CENTER_CODE__c = F_ST_DEPT_CODE;
        //서인석 책임 요청 PROCESS_STATUS_CODE__c = 'I'
        siCareplusOrderRequest.PROCESS_STATUS_CODE__c = 'I';

        return siCareplusOrderRequest;
    }

    @AuraEnabled
    public static List<SI_CAREPLUS_ORDER_COMPLETE__c> getSiCareplusOrderComplete(String carePlustOrderNo, String sPartNo, String workFlag, String orderType) {
        /** ERP 주문생성 결과 조회 (SI_CAREPLUS_ORDER_COMPLETE__c) */

        /** ERP 주문생성 결과 조회 */
        List<SI_CAREPLUS_ORDER_COMPLETE__c> orderCompleteMDataList = [SELECT Id, LINE_STATUS_CODE__c, LINE_ID__c FROM SI_CAREPLUS_ORDER_COMPLETE__c
        WHERE ORIG_SYS_DOCUMENT_REF__c = :carePlustOrderNo
        AND ITEM_NO__c = :sPartNo
        AND LINE_STATUS_CODE__c NOT IN ('SHIPPED', 'CANCELLED', 'RETRUNED', 'PENDING_WORKFLOW', 'Not Defined')
        AND (WORK_FLAG__c = null OR WORK_FLAG__c = :workFlag)
        AND ORDER_TYPE__c = :orderType
        ORDER BY INTERFACE_ID__c DESC LIMIT 1
        ];

        return orderCompleteMDataList;
    }

    @AuraEnabled
    public static ProductRequest setProductRequest(sObject lData, ProductRequest pr) {

        String carePlustOrderNo = getStringNotNull(lData.get('ORDER_NO__c'));

        pr.RecordTypeId = EX_ConsumableUtil.PR_CARE_SUPPLIES_RECORDTYPE_ID;
        pr.BILL_TO_CODE__c = getStringNotNull(lData.get('BILL_TO_CODE__c'));
        pr.Order_Date__c = getDatetimeWithNull(lData.get('ORDER_DATE__c'));

        // 주문 고객 Contact Id
        //pr.Order_CUST_Id__c = contactId;
        // 소모품 주문 여부
        pr.Consumables_Order_YN__c = true;
        // 소모품 주문 구분 /  일반 주문 : General, 품절 주문 : Sold Out
        pr.Consumables_Order_Class_Code__c = 'General';
        // [소모품 업무 유형] 주문 : Order, 주문취소 : Cancel, 반품 : Return, 교환 : Exchange, PO(요청) : PO
        pr.Consumables_Business_Type_Code__c = 'Order';
        // [주문 채널] 대표 사이트 : B, ThinQ : S, CIC소모품택배 : V, 베스트샵 : BestShop
        pr.Order_CHNL_TYPE_Code__c = EX_ConsumableUtil.CONSUMABLE_BESTSHOP;
        //주문번호
        pr.Order_Number__c = carePlustOrderNo; //P로 시작해야함(BestShop)
        pr.SHIP_TO_CODE__c = getStringNotNull(lData.get('SHIP_TO_CODE__c'));

        // 수취인 명
        pr.CONSIGNEE_Name__c = getStringNotNull(lData.get('RECEIVER_NAME__c'));
        // 수취인 전화번호1
        pr.CONSIGNEE_TPNO_1__c = getStringNotNull(lData.get('RECEIVER_PHONE_NO__c'));
        // 수취인 주소
        pr.CONSIGNEE_Address__c = getStringNotNull(lData.get('BASIC_ADDRESS__c'));
        // 수취인 상세 주소
        pr.CONSIGNEE_Address_DETAIL__c = getStringNotNull(lData.get('DETAIL_ADDRESS__c'));
        //배송메시지내용
        pr.Delivery_Message_CONTENT__c = getStringNotNull(lData.get('ORDER_DESCRIPTION__c'));
        // 수취인 우편번호
        pr.CONSIGNEE_PostalCode__c = getStringNotNull(lData.get('POSTAL_CODE__c'));

        /* 직영점, 전문점 구분값 H:하이프라자, A:전문점 */
        pr.CAREPLUS_Order_Requester_Class_Code__c = getStringNotNull(lData.get('ATTRIBUTE8__c'));

        //부서코드
        pr.Department_Code__c = EX_ConsumableUtil.PH0300;
        //부서ID
        /*for (SM_DEPT__c sd : [SELECT Id FROM SM_DEPT__c WHERE DEPT_CODE__c = :EX_ConsumableUtil.PH0300]) {
            pr.Department_Id__c = sd.Id;
        }*/
        // 소모품 주문 실제 사용 여부
        pr.Consumables_Order_USE_YN__c = true;

        // 결제 금액
        pr.PAYMENT_Amount__c = getIntegerNotNull(lData.get('ORDER_AMT__c'));
        // 판매 금액
        pr.SALE_Amount__c = getIntegerNotNull(lData.get('ORDER_AMT__c'));
        // 현금 결재 금액
        pr.CASH_PAYMENT_Amount__c = getIntegerNotNull(lData.get('ORDER_AMT__c'));
        //출고부서코드
        //pr.SHIPPED_Department_Code__c = EX_ConsumableUtil.PH0300; //PRLI에서만 관리

        //pr.SourceLocationId = [SELECT Id FROM Location WHERE DEPT_CODE__c = :EX_ConsumableUtil.PH0300 AND fm_RecordType__c = 'Center'].Id;

        return pr;
    }

    @AuraEnabled
    public static ProductRequestLineItem setProductRequestLineItem(sObject lData, ProductRequest pr, ProductRequestLineItem prli, List<Product2> p2List, List<ProductItem> piForPrli, Boolean existPrli) {
        /* 주문수량 */
        Integer orderQty = 0;
        orderQty = getIntegerNotNull(lData.get('ORDER_QTY__c'));
        /* 사업부코드 */
        String sDivCode = getStringNotNull(lData.get('DIV_CODE__c'));
        /* PART_NO */
        String sPartNo = getStringNotNull(lData.get('PART_NO__c'));
        //주문항번
        Decimal orderSeq = getDecimalNotNull(lData.get('ATTRIBUTE4__c'));
        if(orderSeq == 0){
            orderSeq = 1;
        }


        if(!existPrli){ //기존 ProductRequest 데이터 없으면
            prli.Order_SEQ__c = 1; // 주문 항번

            /*List<ProductItem> listProductItems = new List<ProductItem>();
            listProductItems = [
                    SELECT Id, Product2Id
                    FROM ProductItem
                    WHERE fm_Parts_Number__c = :sPartNo
                    AND fm_DIV_CODE__c = :sDivCode
                    AND Location.RecordType.DeveloperName = 'Location' AND Location.Name = '99A999'
            ];*/
            List<ProductItem> listProductItems = piForPrli;
            String productId;
            String productItemId;
            if(!listProductItems.isEmpty()){
                for(ProductItem pi : listProductItems){
                    productId = pi.Product2Id;
                    productItemId = pi.Id;
                }
                // 소모품 주문 품목의 파트 Id
                prli.Product2Id = productId;
                prli.ProductItem__c = productItemId;
                prli.MODEL__c = productId;
            }else{ //ProductItem 없으면
                /*List<Product2> listProduct = new List<Product2>();
                listProduct = [
                    SELECT Id
                    FROM Product2
                    WHERE fm_Part_No__c = :sPartNo
                ];*/
                List<Product2> listProduct = p2List;
                if(!listProduct.isEmpty()){
                    for(Product2 p2 : listProduct){
                        productId = p2.Id;
                    }
                    prli.Product2Id = productId;
                    prli.MODEL__c = productId;
                }
            }
            // 소모품 주문 Id
            //prli.ParentId = pr.Id;
        }

        prli.RecordTypeId = EX_ConsumableUtil.PRLI_CARE_SUPPLIES_RECORDTYPE_ID;

        if (pr.CaseId != null) {
            prli.CaseId = pr.CaseId;
        }
        prli.AccountId = pr.AccountId;

        prli.CONSIGNEE_Address__c = pr.CONSIGNEE_Address__c;	//수취인주소
        prli.CONSIGNEE_Address_DETAIL__c = pr.CONSIGNEE_Address_DETAIL__c;	//수취인상세주소
        prli.CONSIGNEE_Name__c = pr.CONSIGNEE_Name__c;	//수취인명
        prli.CONSIGNEE_PostalCode__c = pr.CONSIGNEE_PostalCode__c;	//수취인우편번호
        prli.CONSIGNEE_TPNO_1__c = pr.CONSIGNEE_TPNO_1__c;	//수취인전화번호1
        prli.CONSIGNEE_TPNO_2__c = pr.CONSIGNEE_TPNO_2__c;	//수취인전화번호2

        //prli.CONSUMER_Price__c = getDecimalNotNull(lData.get('ORDER_PRICE__c'));
        //prli.PAYMENT_Amount__c = getDecimalNotNull(lData.get('ORDER_PRICE__c'));
        //prli.SALE_Amount__c = getDecimalNotNull(lData.get('ORDER_PRICE__c')); //판매금액
        //prli.CASH_PAYMENT_Amount__c = getDecimalNotNull(lData.get('ORDER_PRICE__c')); //CAREPLUS는 현금결제금액


        //prli.PAYMENT_DTM__c = getDatetimeWithNull(lData.get('ORDER_DATE__c'));
        //prli.PAYMENT_YN__c = true;

        prli.SourceLocationId = pr.SourceLocationId;

        prli.Delivery_Message_CONTENT__c = getStringNotNull(lData.get('ORDER_DESCRIPTION__c'));

        prli.Department_Code__c = pr.Department_Code__c;

        // 소모품 주문 번호
        prli.Order_Number__c = pr.Order_Number__c;
        prli.Order_SEQ__c = orderSeq;
        // 소모품 주문 여부
        prli.Consumables_Order_YN__c = true;
        // 소모품 주문 구분
        prli.Consumables_Order_Class_Code__c = 'General';
        // 소모품 업무 유형
        prli.Consumables_Business_Type_Code__c = 'Order';
        // 소모품 주문 채널
        prli.Order_CHNL_TYPE_Code__c = EX_ConsumableUtil.CONSUMABLE_BESTSHOP;
        // 소모품 주문 상태 (WORK_FLAG에 따라서 Setting 해줘야함)
        String orderStatus = setOrderStatus(getStringNotNull(lData.get('WORK_FLAG__c')));

        String cancelFlag = getStringNotNull(lData.get('CANCEL_FLAG__c'));
        if(cancelFlag.equals('Y')){
            prli.CANCEL_Date__c = getDateWithNull(lData.get('CANCEL_DATE__c')); //주문취소일시
            prli.CANCEL_Quantity__c = getDecimalNotNull(lData.get('CANCEL_QTY__c')); //취소수량
        }
        prli.Consumables_Order_Status__c = orderStatus;
        // 소모품 주문 고객 Contact Id
        if(pr.Order_CUST_Id__c != null){
            prli.Order_CUST_Id__c = pr.Order_CUST_Id__c;
        }
        // 소모품 주문 품목의 사업부 코드
        prli.ENDP_Code__c = sDivCode;
        //모델코드
        prli.MODEL_Code__c = getStringNotNull(lData.get('MODEL_CODE__c'));
        // 소모품 주문 품목의 파트 넘버
        prli.PART_NO__c = sPartNo;
        // 소모품 주문 품목의 요청 수량
        prli.QuantityRequested = orderQty;
        //판매수량 = 주문수량
        prli.SALE_Quantity__c = orderQty;
        //주문단가
        prli.UnitPrice__c = getDecimalNotNull(lData.get('ORDER_PRICE__c'));
        //출고부서코드
        if(getStringNotNull(lData.get('WORK_FLAG__c')).equals('R')){
            prli.SHIPPED_Department_Code__c = sDivCode;
        }else{
            prli.SHIPPED_Department_Code__c = EX_ConsumableUtil.PH0300;
        }

        /*if(prli.BASIS_Order_Item_Id__c == null || prli.BASIS_Order_Item_Id__c.equals('')){
            prli.BASIS_Order_Item_Id__c = null;
        }
        if(prli.BASIS_Order_Item_Id__r == null){
            prli.BASIS_Order_Item_Id__r = null;
        }*/

        /** 채번 */
        /*List<ProductRequestLineItem> lineItemList = new List<ProductRequestLineItem>();
        lineItemList.add(prli);

        Map<String, Integer> subNumberMap = EX_ConsumableUtil.getSubNumberMap(lineItemList);

        if (lineItemList[0].RecordType.DeveloperName != 'RSRV_SALE') {
            prli.SUB_Order_Number__c = EX_ConsumableUtil.getSubNumber(subNumberMap, lineItemList[0]);
        }*/
        prli.SUB_Order_Number__c = pr.Order_Number__c + '-001-01'; //케어용품 주문건은 1개품목 만 주문되어서, '주문번호-001-01' 고정.

        return prli;
    }

    @AuraEnabled
    public static String setOrderStatus(String workFlag) {
        String orderStatus = '';
        if(workFlag.equals('Y') || workFlag.equals('S')){
            orderStatus = EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_006; //상품준비중
        }else if(workFlag.equals('R')){
            orderStatus = EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_002; //결제완료
        }else if(workFlag.equals('H') || workFlag.equals('I') || workFlag.equals('O') || workFlag.equals('D')) {
            orderStatus = EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_001; //결제요청
        }else if(workFlag.equals('W')){
            orderStatus = EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_100; //반품요청
        }else if(workFlag.equals('E')){
            //오류
        }
        return orderStatus;
    }

    @AuraEnabled
    public static Date getDateWithNull(Object obj) {
        Date dt = null;
        if(obj != null){
            dt = Date.valueOf(obj);
        }
        return dt;
    }

    @AuraEnabled
    public static Datetime getDatetimeWithNull(Object obj) {
        Datetime dt = null;
        if(obj != null){
            dt = Datetime.valueOf(obj);
        }
        return dt;
    }
    
    @AuraEnabled
    public static String getStringNotNull(Object obj) {
        String str = '';
        if(obj != null){
            str = String.valueOf(obj);
        }
        return str;
    }

    @AuraEnabled
    public static Integer getIntegerNotNull(Object obj) {
        Integer i = 0;
        if(obj != null){
            i = Integer.valueOf(obj);
        }
        return i;
    }

    @AuraEnabled
    public static Double getDoubleNotNull(Object obj) {
        Double d = 0;
        if(obj != null){
            d = Double.valueOf(obj);
        }
        return d;
    }

    @AuraEnabled
    public static Decimal getDecimalNotNull(Object obj) {
        Decimal d = 0;
        if(obj != null){
            d = Decimal.valueOf(Double.valueOf(obj));
        }
        return d;
    }

}