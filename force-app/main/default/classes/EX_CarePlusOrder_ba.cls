/**
 * Created by A80598 on 2023-05-16.
 */

 public with sharing class EX_CarePlusOrder_ba implements Database.Batchable<sObject>, Database.Stateful {
    public static String F_ST_DEPT_CODE = 'PH0300';
    public static Integer batchSize = 100;

    //23 11 15 hyuoghn.chun 성공건들 로그작업
    String successCareplusOrderId = 'Success SI_CAREPLUS_ORDER__c ID : ';    

    public EX_CarePlusOrder_ba(Integer bSize){
        if(bSize != null){
            batchSize = bSize;
        }
    }

    public Database.QueryLocator start(Database.BatchableContext param1) {
        /**
         * Step3. 케어플러스 주문 대상 정보 조회
         */
        String strQuery = '';
        strQuery += ' SELECT ' + SObjectUtil.getFieldForQuery('SI_CAREPLUS_ORDER__c');
        strQuery += ' FROM SI_CAREPLUS_ORDER__c ';
        strQuery += ' WHERE TRANS_TYPE__c = \'O\' ';
        strQuery += ' AND WORK_FLAG__c IN ( \'N\', \'R\', \'H\', \'I\', \'O\', \'D\',\'\') ';
        //23 12 06 테스트 대비로 커스텀라벨이용해서 쿼리조회(운영엔 아래조건 주석처리로 배포중)
        if(System.Label.EX_carePlusOrderNum != 'none'){
            strQuery += 'AND ORDER_NO__C = \''+System.Label.EX_carePlusOrderNum+'\' ';
        }
        //strQuery += ' AND ID = \'a4b6D0000003QR8QAM\' ';
        // strQuery += ' AND ORDER_NO__C = \'P10000403061\' ';
        // strQuery += ' AND Order_NO__c IN ( \'P10000403062\', \'P10000403063\', \'P10000403064\', \'P10000403065\', \'P10000403066\', \'P10000403067\', \'P10000403068\', \'P10000403069\', \'P10000403070\', \'P10000403071\', \'P10000403072\', \'P10000403073\', \'P10000403074\', \'P10000403075\', \'P10000403076\', \'P10000403077\', \'P10000403078\', \'P10000403079\', \'P10000403080\', \'P10000403081\', \'P10000403082\', \'P10000403083\', \'P10000403084\', \'P10000403085\', \'P10000403086\', \'P10000403087\', \'P10000403088\', \'P10000403089\', \'P10000403090\' ) ';
        strQuery += ' ORDER BY LAST_UPDATE_DATE__c ASC ';

        return Database.getQueryLocator(strQuery);
    }

    public void execute(Database.BatchableContext param1, List<sObject> siCarePlusOrderList) {

        //23 11 15 hyungho.chun 실패용 로그작업
        Map<String,String> errorMap = new Map<String,String>();
        String recordIdGroup = '';
        Savepoint sp = Database.setSavepoint();
        if (!siCarePlusOrderList.isEmpty()) {
            for (sObject lData : siCarePlusOrderList) {
                recordIdGroup += 'Id : ' + getStringNotNull(lData.get('Id')) + ', ORDER_NO : '+ getStringNotNull(lData.get('ORDER_NO__c')) + ' ';
            }
        }
        try {
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
                    if (!partNo.equals('')) {
                        sPartNoList.add(partNo); //파트넘버 리스트
                    }
                    if (!billToCode.equals('')) {
                        billToCodeList.add(billToCode); //billToCode 리스트
                    }
                    if (!orderNo.equals('')) {
                        orderNoList.add(orderNo); //orderNo 리스트
                    }
                    if (!sDivCode.equals('')) {
                        sDivCodeList.add(sDivCode);
                    }
                    ifIdList.add(ifId);
                }

                Id departmentId = [SELECT Id FROM SM_DEPT__c WHERE DEPT_CODE__c = :EX_ConsumableUtil.PH0300]?.Id;
                Id warehouseLocationId = EX_ConsumableUtil.getCarePlusWareHouseId(); // 케어플러스 적치장소 Location Id

                /** 케어용품, 단종여부 체크 */
                List<product2> mPartDataList = new List<product2>();
                if (!sPartNoList.isEmpty()) {
                    mPartDataList = [SELECT Id, DISABLED_DT__c, Name, DIV_CODE__c FROM product2 WHERE Name IN :sPartNoList AND CAREPLUS_YN__c = 'Y'];
                    system.debug('케어용품 단종여부 체크 TOTAL : ' + sPartNoList.size() + ', result : ' + mPartDataList);
                }

                //23 08 14 hyungho.chun account의 careplus YN 체크 추가
                /** BillToCode 체크 */
                List<Account> billtoCodeDataList = new List<Account>();
                if (!billToCodeList.isEmpty()) {
                    billtoCodeDataList = [SELECT Id, Name, AR_CODE__c, RECEIVER_TEL_NO__c, FULL_ADDRESS__c, PostalCode__c, CAREPLUS_YN__c FROM ACCOUNT WHERE AR_CODE__c IN :billToCodeList ]; //AR_CODE__c 로 체크
                    system.debug('BillToCode 체크 TOTAL : ' + billToCodeList.size() + ', result : ' + billtoCodeDataList);
                }

                //23 10 12 hyungho.chun 각종 주소 번호 정보들은 account에서 받아오려고 맵
                Map<String, Account> arCodeAccMap = new Map<String, Account>();

                for(Account acc : billtoCodeDataList){
                    //23 10 12 hyungho.chun 
                    arCodeAccMap.put(acc.AR_CODE__c,acc);
                }
                
                //23 10 12 hyungho.chun 앞으로 쓸 Contact [select id,name,MobilePhone,CreatedDate,AccountId from Contact where name = '엘지베스트샵' and MobilePhone ='02-1544-7777']
                List<Contact> conList = [SELECT id FROM Contact WHERE name = '엘지베스트샵' AND MobilePhone ='02-1544-7777'];

                /** Contact 체크 */
                //23 10 12 hyungho.chun contact을 더이상 생성하지않음
                //
                // List<Contact> contactsList = new List<Contact>();
                // if (!billtoCodeDataList.isEmpty()) {
                //     List<String> accountIdList = new List<String>();
                //     for (Account ac : billtoCodeDataList) {
                //         accountIdList.add(ac.Id);
                //     }
                //     if (!accountIdList.isEmpty()) {
                //         contactsList = [SELECT Id, AccountId, Name, MobilePhone, ADDRESS_NEW__c, POSTAL_CODE__c FROM CONTACT WHERE AccountId IN :accountIdList];
                //         system.debug('Contact 체크 TOTAL : ' + accountIdList.size() + ', result : ' + contactsList);

                //         List<Contact> insertContactList = new List<Contact>();
                //         for(ACCOUNT ac : billtoCodeDataList){
                //             Boolean need = true;
                //             if(!contactsList.isEmpty()){
                //                 for(Contact c : contactsList){
                //                     if(ac.Id == c.AccountId){
                //                         need = false;
                //                     }
                //                 }
                //                 if(need){
                //                     Contact objCont = new Contact();
                //                     objCont.LastName = ac.Name;
                //                     objCont.MobilePhone = ac.RECEIVER_TEL_NO__c;
                //                     objCont.ADDRESS_NEW__c = ac.FULL_ADDRESS__c;
                //                     objCont.POSTAL_CODE__c = ac.PostalCode__c;
                //                     objCont.AccountId = ac.Id;
                //                     insertContactList.add(objCont);
                //                 }
                //             }else{
                //                 Contact objCont = new Contact();
                //                 objCont.LastName = ac.Name;
                //                 objCont.MobilePhone = ac.RECEIVER_TEL_NO__c;
                //                 objCont.ADDRESS_NEW__c = ac.FULL_ADDRESS__c;
                //                 objCont.POSTAL_CODE__c = ac.PostalCode__c;
                //                 objCont.AccountId = ac.Id;
                //                 insertContactList.add(objCont);
                //             }
                //         }//for ac
                //         if(!insertContactList.isEmpty()){
                //             try{
                //                 //23 09 23 hyungho.chun 
                //                 TriggerHandler.bypass('Contact_trHandler');
                //                 insert insertContactList;
                //                 TriggerHandler.clearBypass('Contact_trHandler');
                //             }catch(Exception e){
                //                 system.debug('line : ' + e.getLineNumber() + ', msg:' + e.getMessage());
                //             }
                //             for(Contact ic : insertContactList){
                //                 contactsList.add(ic);
                //             }
                //         }
                //     }
                // }
                String strQuery = '';

                /** ProductRequest 체크 */
                List<ProductRequest> productRequestList = new List<ProductRequest>();
                System.debug('orderNoList :: ' +orderNoList);
                if (!orderNoList.isEmpty()) {
                    strQuery = '';
                    strQuery += ' SELECT ' + SObjectUtil.getFieldForQuery('ProductRequest');
                    strQuery += ' FROM ProductRequest ';
                    strQuery += ' WHERE Order_Number__c IN (';
                    Integer i = 0;
                    for (String orderNo : orderNoList) {
                        if (i == 0) {
                            strQuery += '\'' + orderNo + '\'';
                        } else {
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
                if (!orderNoList.isEmpty() && !sPartNoList.isEmpty()) {
                    strQuery = '';
                    strQuery += ' SELECT ' + SObjectUtil.getFieldForQuery('ProductRequestLineItem');
                    strQuery += ' FROM ProductRequestLineItem ';
                    strQuery += ' WHERE Order_Number__c IN (';
                    Integer i = 0;
                    for (String orderNo : orderNoList) {
                        if (i == 0) {
                            strQuery += '\'' + orderNo + '\'';
                        } else {
                            strQuery += ',\'' + orderNo + '\'';
                        }
                        i++;
                    }
                    strQuery += ') ';
                    strQuery += ' AND Order_CHNL_TYPE_Code__c = \'BestShop\' ';
                    strQuery += ' AND PART_NO__c IN (';
                    Integer j = 0;
                    for (String sPartNo : sPartNoList) {
                        if (j == 0) {
                            strQuery += '\'' + sPartNo + '\'';
                        } else {
                            strQuery += ',\'' + sPartNo + '\'';
                        }
                        j++;
                    }
                    strQuery += ') ';
                    strQuery += ' AND RecordTypeId = \'' + EX_ConsumableUtil.PRLI_CARE_SUPPLIES_RECORDTYPE_ID + '\' ';
                    productRequestLineItemList = Database.query(strQuery);
                    System.debug('ProductRequestLineItem 체크');
                }

                /** 상품 조회 */
                List<Product2> productList = [
                    SELECT Id, Name, DIV_CODE__c
                    FROM Product2
                    WHERE Name In :sPartNoList
                    AND CAREPLUS_YN__c = 'Y'
                ];

                /** 가용재고 조회 */
                System.debug('가용재고 조회');
                List<ProductItem> ProductItemList = [
                        SELECT Id,
                                Product2Id,
                                fm_Available_Quantity__c,
                                DIV_CODE__c,
                                fm_Parts_Number__c
                        FROM ProductItem
                        WHERE fm_Available_Quantity__c >= 0
                        AND fm_DEPT_CODE__c = :F_ST_DEPT_CODE
                        AND DIV_CODE__c IN :sDivCodeList
                        AND fm_Parts_Number__c IN :sPartNoList
                        AND Location.RecordType.DeveloperName = 'Location'
                        AND Location.Name = :System.Label.EX_Location
                ];

                //재고정보가 없으면 생성
                Set<String> productIdSet = new Set<String>();
                if(!productList.isEmpty()){
                    for(Product2 p2 : productList){
                        if(!ProductItemList.isEmpty()){
                            Boolean isExist = false;
                            for(ProductItem pi : ProductItemList){
                                if(p2.Name == pi.fm_Parts_Number__c && p2.DIV_CODE__c == pi.DIV_CODE__c){
                                    isExist = true;
                                }
                            }
                            if(!isExist){
                                productIdSet.add(p2.Id);
                            }
                        }else{
                            productIdSet.add(p2.Id);
                        }
                    }
                    if(!productIdSet.isEmpty()){
                        EX_ConsumableUtil.createNotExistProductItem(productIdSet, F_ST_DEPT_CODE);
                    }
                }

                /** 케어플러스 ERP 결과 조회 */
                List<SI_CAREPLUS_ORDER_COMPLETE__c> orderCompleteYPOList = [
                        SELECT Id,
                                LINE_STATUS_CODE__c,
                                LINE_ID__c,
                                ORIG_SYS_DOCUMENT_REF__c,
                                ITEM_NO__c,
                                WORK_FLAG__c
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
                if (!getRequestMaxList.isEmpty()) {
                    requestMaxInterfaceId = getIntegerNotNull(getRequestMaxList[0].SO_INTERFACE_ID__c);
                }

                /** 케어플러스 max backif */
                List<SI_CAREPLUS_BACKIF__c> getBackIfMaxList = [SELECT INTERFACE_ID__c FROM SI_CAREPLUS_BACKIF__c ORDER BY INTERFACE_ID__c DESC LIMIT 1];
                Integer backIfMaxInterfaceId = 0;
                if (!getBackIfMaxList.isEmpty()) {
                    backIfMaxInterfaceId = getIntegerNotNull(getBackIfMaxList[0].INTERFACE_ID__c);
                }

                /** 케어플러스 subMax backif */
                List<SI_CAREPLUS_BACKIF__c> getBackIfSubMaxList = [
                        SELECT BACK_SUB_SEQ__c,
                                INTERFACE_ID__c,
                                ORDER_NO__c
                        FROM SI_CAREPLUS_BACKIF__c
                        WHERE INTERFACE_ID__c IN :ifIdList
                        AND TRANS_TYPE__c = 'O'
                        AND ORDER_NO__c IN :orderNoList
                        ORDER BY BACK_SUB_SEQ__c DESC
                        LIMIT 1
                ];

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
                List<SR_ONLINE_AUTO_SALE_EXC__c> insertLogList = new List<SR_ONLINE_AUTO_SALE_EXC__c>();

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
                    if (nowWorkFlag.equals('')) {
                        nowWorkFlag = 'N';
                    }
                    /* 요청유형 */
                    String reqType = 'A';
                    /* MODEL_CODE */
                    String sModelCode = getStringNotNull(lData.get('MODEL_CODE__c'));
                    /* ATTRIBUTE1 */
                    String sAttribute1 = '';

                    /* 주문수량 */
                    Integer orderQty = getIntegerNotNull(lData.get('ORDER_QTY__c'));
                    // Integer shipQty = 0;
                    Integer shipQty = orderQty; // 24 03 11 hyungho.chun 더이상 shipQty 바꿔주는 로직없이 전부다 orderQty로 던져준다 (shipped나 error건들 0으로 던저주는게 newBest에서 문제가 됐었음)
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
                    //23 08 14 hyungho.chun
                    /* careplusYNCheck */
                    Boolean carePlusYNacc = true;
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
                    if (!getBackIfSubMaxList.isEmpty()) { for (SI_CAREPLUS_BACKIF__c scb : getBackIfSubMaxList) { if (scb.INTERFACE_ID__c == getDecimalNotNull(lData.get('INTERFACE_ID__c')) && scb.ORDER_NO__c == carePlustOrderNo) { backIfSubMaxInterfaceId = getIntegerNotNull(getBackIfSubMaxList[0].BACK_SUB_SEQ__c); } } }

                    /** 케어용품 체크 */
                    List<Product2> mPartData = new List<Product2>();
                    //List<ProductItem> mPartData = [SELECT Id, Product2.DISABLED_DT__c, fm_Parts_Number__c FROM ProductItem WHERE fm_Parts_Number__c = :sPartNo AND product2.CAREPLUS_YN__c = 'Y'];
                    for (Product2 pd : mPartDataList) {
                        // if (sPartNo.equals(pd.Name)) {
                        if (sPartNo.equals(pd.Name) && sDivCode.equals(pd.DIV_CODE__c)) {    //24 03 21 hyungho.chun 같은 파트번호 다른 사업부가 존재함으로 사업부도 같은거만 주문넣어야함
                            mPartData.add(pd);
                        }
                    }

                    /** BillToCode 체크 */
                    List<Account> billtoCodeData = new List<Account>();
                    //List<Account> billtoCodeData = [SELECT Id, AR_CODE__c FROM ACCOUNT WHERE AR_CODE__c = :billToCode]; //AR_CODE__c 로 체크

                    for (Account ac : billtoCodeDataList) {
                        if (billToCode.equals(ac.AR_CODE__c)) {
                            billtoCodeData.add(ac);
                        }
                        if(ac.CAREPLUS_YN__c =='N'){
                            carePlusYNacc = false;
                        }
                    }

                    //23 10 12 hyungho.chun contact은 id만박아주고 나머지 정보는 account에서
                    // String accountId = '';
                    // String accountName = '';
                    // String accountAddr = '';
                    // String accountPostal = '';
                    // String accountTel = '';
                    // String contactId = '';

                    //23 10 12 hyungho.chun
                    //billtoCodeDataList = [SELECT Id, Name, AR_CODE__c, RECEIVER_TEL_NO__c, FULL_ADDRESS__c, PostalCode__c, CAREPLUS_YN__c FROM ACCOUNT WHERE AR_CODE__c IN :billToCodeList ]; //AR_CODE__c 로 체크
                    String accountId = null;
                    String accountName = null;
                    String accountAddr = null;
                    String accountPostal = null;
                    String accountTel = null;
                    
                    if(arCodeAccMap.containsKey(billToCode)){// 24 01 31 hyungho.chun arcode 매칭일떄만 넣어줌
                        accountId = arCodeAccMap.get(billToCode).Id;
                        accountName = arCodeAccMap.get(billToCode).Name;
                        accountAddr = arCodeAccMap.get(billToCode).FULL_ADDRESS__c;
                        accountPostal = arCodeAccMap.get(billToCode).PostalCode__c;
                        accountTel = arCodeAccMap.get(billToCode).RECEIVER_TEL_NO__c;
                    }


                    String contactId = conList[0].Id;

                    SR_ONLINE_AUTO_SALE_EXC__c soase = new SR_ONLINE_AUTO_SALE_EXC__c();
                    soase.ORDER_CHANNEL__c = EX_ConsumableUtil.CONSUMABLE_BESTSHOP;
                    soase.ORDER_NO__c = carePlustOrderNo;

                    if (!billtoCodeData.isEmpty() && arCodeAccMap.containsKey(billToCode)) { //24 01 31 arCodeAccMap.containsKey(billToCode)추가 ( ar code매칭건 없으면 실패)
                        bBilltoCheckPass = true;

                        //23 10 12 hyungho.chun contact은 id만박아주고 나머지 정보는 account에서
                        // accountId = billtoCodeData[0].Id;
                        // accountName = billtoCodeData[0].Name;
                        // List<Contact> contacts = new List<Contact>();
                        // //List<Contact> contacts = [SELECT Id, Name, MobilePhone, ADDRESS_NEW__c, POSTAL_CODE__c FROM CONTACT WHERE AccountId = :accountId];
                        // for (Contact ct : contactsList) {
                        //     if (accountId.equals(ct.AccountId)) {
                        //         contacts.add(ct);
                        //     }
                        // }
                        // if (!contacts.isEmpty()) {
                        //     contactId = contacts[0].Id;
                        //     accountAddr = contacts[0].ADDRESS_NEW__c;
                        //     accountPostal = contacts[0].POSTAL_CODE__c;
                        //     accountTel = contacts[0].MobilePhone;
                        // }
                    } else { bBilltoCheckPass = false; }

                    /** 단종여부체크 */
                    if ('N'.equals(nowWorkFlag)) {
                        if (!mPartData.isEmpty()) {
                            if (mPartData[0].DISABLED_DT__c != null && !''.equals(mPartData[0].DISABLED_DT__c)) { bDisabled = true; }
                        }
                    }

                    List<ProductItem> piforPrli = new List<ProductItem>();
                    if (!ProductItemList.isEmpty()) {
                        for (ProductItem pi : ProductItemList) { if (pi.DIV_CODE__c.equals(sDivCode) && pi.fm_Parts_Number__c.equals(sPartNo)) { piforPrli.add(pi); } }
                    }

                    //케어용품, BillToCode, 단종, customerNo 체크
                    if (!mPartData.isEmpty() && bBilltoCheckPass && carePlusYNacc && !bDisabled && !customerNoIsEmpty) {
                        System.debug('케어용품, BillToCode, 단종 확인 완료');

                        /** ProductRequest, ProductRequestLineItem Upsert */
                        List<ProductRequest> prList = new List<ProductRequest>();
                        if (!productRequestList.isEmpty()) {
                            system.debug('productRequestList size chk : ' + productRequestList.size());
                            for (ProductRequest pr : productRequestList) {
                                if (carePlustOrderNo.equals(pr.Order_Number__c)) {
                                    prList.add(pr);
                                }
                            }
                        }

                        //List<ProductRequestLineItem> prliList = new List<ProductRequestLineItem>();
                        //참고 소스 : EX_SuppliesController - doSaveConsumableOrder
                        if (prList.isEmpty()) { //Insert
                            /** ProductRequest */
                            ProductRequest pr = new ProductRequest();
                            if (accountId != null && !accountId.equals('')) {
                                system.debug('accountId : ' + accountId);
                                pr.AccountId = accountId;
                                pr.Order_CUST_Address__c = accountAddr;    //고객주소
                                //pr.Order_CUST_Address_DETAIL__c = accountAddr;	//고객상세주소
                                pr.Order_CUST_Name__c = accountName;    //주문고객명
                                pr.Order_CUST_PostalCode__c = accountPostal;    //고객우편번호
                                pr.Order_CUST_TPNO_1__c = accountTel;    //고객전화번호1
                                //pr.Order_CUST_TPNO_2__c = '';	//고객전화번호2
                                if (contactId != null && !contactId.equals('')) {
                                    pr.Order_CUST_Id__c = contactId;
                                }else{
                                    // Contact Id
                                    //consumableOrder.Order_CUST_Id__c = null;
                                    //2023-05-15
                                    Map<String, Object> mapIbInfo = new Map<String, Object>();
                                    mapIbInfo.put('inboundNo',accountTel); //전화번호
                                    mapIbInfo.put('ContactName',accountName); //고객이름
                                    mapIbInfo.put('InboundChannel','Unmanned'); //고정값
                                    mapIbInfo.put('UsePersonalInfo',null); //개인정보활용동의여부
                                    try{
                                        Map<String, Object> contactMap = SC_CommonUtil.getContact(mapIbInfo);
                                        if(contactMap.get('contactId') != null){ pr.Order_CUST_Id__c = String.valueOf(contactMap.get('contactId')); }
                                    }catch(Exception e){ system.debug('line : ' + e.getLineNumber() + ', msg:' + e.getMessage()); }
                                }
                            }
                            if (departmentId != null) {
                                pr.Department_Id__c = departmentId;
                            }
                            if (warehouseLocationId != null) {
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
                        } else {
                            system.debug('update하는부분!!');
                            system.debug('prList: '+prList);
                            //Update
                            //20230704
                            for (ProductRequest pr : prList) { //무조건 1건
                                nowPR = pr;
                            }
                            /** ProductRequestLineItem */
                            List<ProductRequestLineItem> existPrliList = new List<ProductRequestLineItem>();
                            if (!productRequestLineItemList.isEmpty()) { //1건 (1:1)
                                for (ProductRequestLineItem prli : productRequestLineItemList) {
                                    if (carePlustOrderNo.equals(prli.Order_Number__c) && sPartNo.equals(prli.PART_NO__c)) {
                                        existPrliList.add(prli);
                                    }
                                }
                            }
                            system.debug('existPrliList: '+existPrliList);
                            for (ProductRequestLineItem prli : existPrliList) { //1건 (1:1)
                                nowPRLI = prli;
                            }

                           for (ProductRequest pr : prList) {
                               if (!accountId.equals('')) {
                                   pr.AccountId = accountId;
                                   pr.Order_CUST_Address__c = accountAddr;    //고객주소
                                   //pr.Order_CUST_Address_DETAIL__c = accountAddr;	//고객상세주소
                                   pr.Order_CUST_Name__c = accountName;    //주문고객명
                                   pr.Order_CUST_PostalCode__c = accountPostal;    //고객우편번호
                                   pr.Order_CUST_TPNO_1__c = accountTel;    //고객전화번호1
                                   //pr.Order_CUST_TPNO_2__c = '';	//고객전화번호2
                                   if (contactId != null && !contactId.equals('')) {
                                       pr.Order_CUST_Id__c = contactId;
                                   }
                               }
                               if (departmentId != null) {
                                   pr.Department_Id__c = departmentId;
                               }
                               if (warehouseLocationId != null) {
                                   pr.SourceLocationId = warehouseLocationId;
                               }
                               /** ProductRequest */
                               pr = setProductRequest(lData, pr);
                               listUpsertPR.add(pr);
                               nowPR = pr;
                               /** ProductRequestLineItem */
                            //    List<ProductRequestLineItem> existPrliList = new List<ProductRequestLineItem>();
                            //    if (!productRequestLineItemList.isEmpty()) {
                            //        for (ProductRequestLineItem prli : productRequestLineItemList) {
                            //            if (carePlustOrderNo.equals(prli.Order_Number__c) && sPartNo.equals(prli.PART_NO__c)) {
                            //                existPrliList.add(prli);
                            //            }
                            //        }
                            //    }
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
                            for (SI_CAREPLUS_ORDER_COMPLETE__c scoc : orderCompleteYPOList) {
                                if (scoc.ORIG_SYS_DOCUMENT_REF__c == carePlustOrderNo && scoc.ITEM_NO__c == sPartNo && scoc.WORK_FLAG__c == 'N') {
                                    System.debug('Add orderCompleteMDataList OrderNo : ' + carePlustOrderNo + ', sPartNo : ' + sPartNo);
                                    orderCompleteMDataList.add(scoc);
                                }
                            }

                            if (orderCompleteMDataList.isEmpty()) { //ERP 주문생성 결과 조회 없음
                                system.debug('ERP 주문생성 결과 조회 없음');
                                if ('I'.equals(nowWorkFlag)) { workFlag = 'I';
                                } else if ('H'.equals(nowWorkFlag)) { bCreditHold = true; workFlag = 'H';
                                } else if ('O'.equals(nowWorkFlag)) { bCreditHold = true; workFlag = 'O';
                                } else if ('D'.equals(nowWorkFlag)) { bCreditHold = true; workFlag = 'D'; }
                            } else { //ERP 주문생성 결과 조회 있음
                                system.debug('ERP 주문생성 결과 조회 있음');
                                SI_CAREPLUS_ORDER_COMPLETE__c orderCompleteMData = (SI_CAREPLUS_ORDER_COMPLETE__c) orderCompleteMDataList[0];
                                String lineStatusCode = getStringNotNull(orderCompleteMData.get('LINE_STATUS_CODE__c'));
                                if ('AWAITING_SHIPPING'.equals(lineStatusCode)) { bCreditHold = false; sAttribute10 = getStringNotNull(orderCompleteMData.get('LINE_ID__c'));
                                } else if ('CREDIT_HOLD_RELEASED'.equals(lineStatusCode)) { bCreditHold = false; sAttribute10 = getStringNotNull(orderCompleteMData.get('LINE_ID__c'));
                                } else if ('CREDIT_HOLD'.equals(lineStatusCode)) { bCreditHold = true; workFlag = 'H'; result = 'SUCCESS';
                                } else if ('OVERDUE_HOLD'.equals(lineStatusCode)) { bCreditHold = true; workFlag = 'O'; result = 'SUCCESS';
                                } else if ('CREDIT&OVER_DUE'.equals(lineStatusCode)) { bCreditHold = true; workFlag = 'D'; result = 'SUCCESS';
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

                            List<ProductItem> piList = new List<ProductItem>();
                            if (!ProductItemList.isEmpty()) {
                                for (ProductItem pi : ProductItemList) {
                                    //fm_Available_Quantity__c, DIV_CODE__c, fm_Parts_Number__c
                                    if (pi.DIV_CODE__c.equals(sDivCode) && pi.fm_Parts_Number__c.equals(sPartNo) && pi.fm_Available_Quantity__c >= orderQty) {
                                        piList.add(pi);
                                    }
                                }
                            }

                            //20230704
                            if ('R'.equals(nowWorkFlag)) {
                                system.debug('nowWorkFlag R 건');
                                system.debug('attribute2 : ' + attribute2);
                                system.debug('orderQty : ' + orderQty);
                                system.debug('nowPRLI.ENDP_RSV_Quantity__c : ' + nowPRLI.ENDP_RSV_Quantity__c);
                                if (attribute2 != null && !''.equals(attribute2)) { // RESERV_NO 예약번호가 있는경우
                                    if (orderQty == nowPRLI.ENDP_RSV_Quantity__c) { //입고완료 : 요청수량 == 사업부입고수량
                                        //workFlag = 'C';
                                        workFlag = 'Y';
                                        //cancelQty = orderQty;
                                        //cancelFlag = 'Y';
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
                                            // rsrvCancelMap.put('ProductRequestLineItem', nowPRLI);
                                            // rsrvCancelMap.put('code', 'AE');
                                            // rsrvCancelMapList.add(rsrvCancelMap);
                                        }//정리수량 검사 끝
                                        //workFlag = 'C';
                                        workFlag = 'Y';
                                        //cancelQty = orderQty;
                                        //cancelFlag = 'Y';
                                    } else { // 입고안됨
                                        workFlag = '';
                                        // shipQty = 0; // 24 03 11 hyungho.chun 더이상 shipQty 바꿔주는 로직없이 전부다 orderQty로 던져준다 (shipped나 error건들 0으로 던저주는게 newBest에서 문제가 됐었음)
                                        if (nowPRLI.Adjust_Quantity__c != null && nowPRLI.Adjust_Quantity__c == orderQty) { //정리수량
                                            //사용자 취소
                                            //workFlag = 'C';
                                            workFlag = 'Y';
                                            //cancelQty = orderQty;
                                            //cancelFlag = 'Y';
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
                                system.debug('nowWorkFlag : ' + nowWorkFlag);
                                system.debug('workFlag : ' + workFlag);
                                reqType = 'S'; // 요청유형
                                if (!'R'.equals(nowWorkFlag)) {
                                    //사업부 조회
                                    String resrvNo = '';
                                    String orderNo = '';
                                    Integer orderSeq = 1;
                                    workFlag = 'R';
                                    // shipQty = 0; // 24 03 11 hyungho.chun 더이상 shipQty 바꿔주는 로직없이 전부다 orderQty로 던져준다 (shipped나 error건들 0으로 던저주는게 newBest에서 문제가 됐었음)

                                    //Map<String, Object> rtnMap = new Map<String, Object>();
                                    Map<String, Object> mapItem = new Map<String, Object>();
                                    if (!prList.isEmpty()) {
                                        mapItem.put('oriPrId', nowPR.Id); //원주문 ProductRequestId
                                        mapItem.put('oriPrliId', nowPRLI.Id); //원주문 ProductRequestLineItemId
                                        mapItem.put('oriOrderNo', nowPRLI.Order_Number__c); //원주문번호
                                        mapItem.put('oriOrderSeq', nowPRLI.Order_SEQ__c); //원주문Seq
                                    } else {
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
                                        result = 'SUCCESS';
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
                        if (mPartData.isEmpty()) { sAttribute1 = sAttribute1 + 'PART_NO : ' + sPartNo + ' 케어용품아님,'; result = 'SUCCESS'; soase.ERROR_DATE__c = system.today(); }
                        /* BILL TO CODE 체크 결과 */
                        if (!bBilltoCheckPass) { sAttribute1 = sAttribute1 + ' BILLTOCODE : ' + billToCode + ' 미존재,'; result = 'SUCCESS'; soase.ERROR_DATE__c = system.today(); }
                        /* BILL TO CODE 체크 결과 */
                        if (!carePlusYNacc) { sAttribute1 = sAttribute1 + ' CarePlus_YN : ' + 'N' + ' 케어플러스거래처아님,'; result = 'SUCCESS'; soase.ERROR_DATE__c = system.today(); }
                        /* 단종여부 체크 결과 */
                        if (bDisabled) { sAttribute1 = sAttribute1 + 'PART_NO : ' + sPartNo + ' 단종'; result = 'SUCCESS'; soase.ERROR_DATE__c = system.today(); }
                        /* CUSTOMER_NO 체크 결과 */
                        if (customerNoIsEmpty) { sAttribute1 = sAttribute1 + 'CUSTOMER_NO 미존재'; result = 'SUCCESS'; }
                        /* 여신 체크 결과 */
                        if (bCreditHold) { workFlag = 'H'; result = 'SUCCESS'; }
                        if (mPartData.isEmpty() || !bBilltoCheckPass || !carePlusYNacc || bDisabled || customerNoIsEmpty) { workFlag = 'E'; }
                    } //케어용품, BillToCode, 단종, customerNo 체크 끝
                    if ('R'.equals(nowWorkFlag) && ''.equals(workFlag)) { workFlag = nowWorkFlag; }
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
                            for (ProductRequest pr_u : listInsertPR) {
                                if (pr_u.Order_Number__c == getStringNotNull(lData.get('ORDER_NO__c'))) {
                                    pr_u.BACK_IF_SEND_YN__c = true;
                                    pr_u.BILL_TO_CODE__c = billToCode;
                                    /** 상태:결제완료 시 Update*/
                                    //결제여부
                                    pr_u.PAYMENT_YN__c = true;
                                    //결제전송일시
                                    // pr_u.PAYMENT_COMPLETED_DTM__c = getDatetimeWithNull(lData.get('ORDER_DATE__c'));
                                    //23 09 20 hyungho.chun 9시간 차이빼주기
                                    // pr_u.PAYMENT_COMPLETED_DTM__c = getDatetimeWithNull(lData.get('ORDER_DATE__c')).addHours(-9);
                                    pr_u.PAYMENT_COMPLETED_DTM__c = getDatetimeWithNull(lData.get('ORDER_DATE__c')); //24 03 11 hyungho.chun 이제 히로쿠에서 9시간 차감해준후에 보내주기때문에 따로 로직제거
                                    //결제요청일시
                                    //23 09 20 hyungho.chun 9시간 차이빼주기
                                    // pr_u.PAYMENT_REQUEST_DATE__c = getDatetimeWithNull(lData.get('ORDER_DATE__c'));
                                    // pr_u.PAYMENT_REQUEST_DATE__c = getDatetimeWithNull(lData.get('ORDER_DATE__c')).addHours(-9);
                                    pr_u.PAYMENT_REQUEST_DATE__c = getDatetimeWithNull(lData.get('ORDER_DATE__c')); //24 03 11 hyungho.chun 이제 히로쿠에서 9시간 차감해준후에 보내주기때문에 따로 로직제거
                                    //승인일자 date
                                    pr_u.APPR_DT__c = Date.today();
                                    //결제유형
                                    pr_u.PAYMENT_TYPE__c = 'B2B';
                                }
                            }
                            for (ProductRequest pr_u : listUpsertPR) {
                                if (pr_u.Order_Number__c == getStringNotNull(lData.get('ORDER_NO__c'))) {
                                    pr_u.BACK_IF_SEND_YN__c = true;
                                    pr_u.BILL_TO_CODE__c = billToCode;
                                    /** 상태:결제완료 시 Update*/
                                    //결제여부
                                    pr_u.PAYMENT_YN__c = true;
                                    //결제전송일시
                                    // pr_u.PAYMENT_COMPLETED_DTM__c = getDatetimeWithNull(lData.get('ORDER_DATE__c')).addHours(-9);
                                    pr_u.PAYMENT_COMPLETED_DTM__c = getDatetimeWithNull(lData.get('ORDER_DATE__c'));  //24 03 11 hyungho.chun 이제 히로쿠에서 9시간 차감해준후에 보내주기때문에 따로 로직제거
                                    //결제요청일시
                                    // pr_u.PAYMENT_REQUEST_DATE__c = getDatetimeWithNull(lData.get('ORDER_DATE__c')).addHours(-9);
                                    pr_u.PAYMENT_REQUEST_DATE__c = getDatetimeWithNull(lData.get('ORDER_DATE__c')); //24 03 11 hyungho.chun 이제 히로쿠에서 9시간 차감해준후에 보내주기때문에 따로 로직제거
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
                            System.debug('Cancel Flag :::: ' + cancelFlag);
                            DateTime deliveryDate = getDeliveryDate(); // 정상배송일

                            if (cancelFlag != null && cancelFlag.equals('Y')) {
                                for (ProductRequestLineItem prli_u : listInsertPRLI) {
                                    if (prli_u.Order_Number__c == getStringNotNull(lData.get('ORDER_NO__c'))) {
                                        prli_u.SHIP_QTY__c = shipQty;
                                        prli_u.Consumables_Order_Status__c = orderStatus;
                                        prli_u.CANCEL_Quantity__c = cancelQty;
                                        prli_u.CANCEL_Reason__c = '사용자 주문취소';
                                        prli_u.CANCEL_Date__c = Date.today();
                                        prli_u.CANCEL_User__c = 'SYSTEM';
                                        prli_u.CONSUMABLES_ERROR__c = sAttribute1;
                                    }
                                }
                                for (ProductRequestLineItem prli_u : listUpsertPRLI) {
                                    if (prli_u.Order_Number__c == getStringNotNull(lData.get('ORDER_NO__c'))) {
                                        prli_u.SHIP_QTY__c = shipQty;
                                        prli_u.Consumables_Order_Status__c = orderStatus;
                                        prli_u.CANCEL_Quantity__c = cancelQty;
                                        prli_u.CANCEL_Reason__c = '사용자 주문취소';
                                        prli_u.CANCEL_Date__c = Date.today();
                                        prli_u.CANCEL_User__c = 'SYSTEM';
                                        prli_u.CONSUMABLES_ERROR__c = sAttribute1;
                                    }
                                }
                            } else {
                                for (ProductRequestLineItem prli_u : listInsertPRLI) {
                                    if (prli_u.Order_Number__c == getStringNotNull(lData.get('ORDER_NO__c'))) {
                                        prli_u.SHIP_QTY__c = shipQty;
                                        prli_u.Consumables_Order_Status__c = orderStatus;
                                        prli_u.CONSUMABLES_ERROR__c = sAttribute1;
                                        prli_u.fm_deliveryTerm__c = deliveryDate;
                                    }
                                }
                                for (ProductRequestLineItem prli_u : listUpsertPRLI) {
                                    if (prli_u.Order_Number__c == getStringNotNull(lData.get('ORDER_NO__c'))) {
                                        prli_u.SHIP_QTY__c = shipQty;
                                        prli_u.Consumables_Order_Status__c = orderStatus;
                                        if( orderStatus == EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_006){
                                            prli_u.Appointment_Status__c =  '입고완료';
                                        } 
                                        prli_u.CONSUMABLES_ERROR__c = sAttribute1;
                                        prli_u.fm_deliveryTerm__c = deliveryDate;
                                    }
                                }
                            }
                            result = 'SUCCESS';

                            Double shipAmt = 0;
                            if ('Y'.equals(workFlag)) {
                                shipQty = orderQty; //출고수량
                                shipAmt = orderAmt; //판매금액
                            } else {
                                // shipQty = 0; //출고수량 // 24 03 11 hyungho.chun 더이상 shipQty 바꿔주는 로직없이 전부다 orderQty로 던져준다 (shipped나 error건들 0으로 던저주는게 newBest에서 문제가 됐었음)
                                shipAmt = 0; //판매금액
                            }

                            /** BACK_IF 생성 */
                            String back_if_status = '';
                            String back_if_error_desc = '';
                            String trans_type = '';
                            if ('E'.equals(workFlag)) { back_if_status = 'ERROR'; back_if_error_desc = sAttribute1; sAttribute1 = ''; }
                            else if ('R'.equals(workFlag)) { back_if_status = 'BACKORDER_HOLD'; }
                            else if ('Y'.equals(workFlag)) { back_if_status = 'AWAITING_SHIPPING';
                            } else if ('C'.equals(workFlag)) { back_if_status = 'SMILE_CANCELLED'; trans_type = 'C';

                                /**
                                 * CAREPLUS 3차 SMILE_CANCELLED 일때도 ERP에 취소 요청을 보낸다.
                                 */
                                /** ERP 주문생성 결과 조회 */
                                //List<SI_CAREPLUS_ORDER_COMPLETE__c> orderCompleteMDataList = getSiCareplusOrderComplete(carePlustOrderNo, sPartNo, 'Y', 'PO');
                                List<SI_CAREPLUS_ORDER_COMPLETE__c> orderCompleteMDataList = new List<SI_CAREPLUS_ORDER_COMPLETE__c>();
                                for (SI_CAREPLUS_ORDER_COMPLETE__c scoc : orderCompleteYPOList) {
                                    if (scoc.ORIG_SYS_DOCUMENT_REF__c == carePlustOrderNo && scoc.ITEM_NO__c == sPartNo && scoc.WORK_FLAG__c == 'Y') {
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
                    insertLogList.add(soase);
                } //for(SI_CAREPLUS_ORDER__c) 끝
                if (!rsrvCancelMapList.isEmpty()) { EX_RsrvUtil.CANCEL_RESRV_MULTI(rsrvCancelMapList); }
                if (!listInsertPR.isEmpty()) {
                    insert listInsertPR;
                    system.debug('INSERT ProductRequest TOTAL : ' + listInsertPR.size());

                    if (!listInsertPRLI.isEmpty()) {
                        for (ProductRequestLineItem prli : listInsertPRLI) {
                            for (ProductRequest pr : listInsertPR) {
                                if (prli.Order_Number__c == pr.Order_Number__c) {
                                    prli.parentId = pr.Id;
                                    break;
                                }
                            }
                        }
                        insert listInsertPRLI;
                        system.debug('INSERT ProductRequest TOTAL : ' + listInsertPRLI.size());
                    }
                }
                if (!listUpsertPR.isEmpty()) {
                    upsert listUpsertPR;
                    system.debug('UPSERT ProductRequest TOTAL : ' + listUpsertPR.size());
                }
                if (!listUpsertPRLI.isEmpty()) {
                    upsert listUpsertPRLI;
                    system.debug('UPSERT ProductRequestLineItem TOTAL : ' + listUpsertPRLI.size());
                }

                List<String> rsrvOrderNoList = new List<String>();
                if (!mapList.isEmpty()) {
                    for (Map<String, Object> mapItem : mapList) {
                        //이미 생성이 되있는 주문건은 PRID, PRLIID가 세팅되어있음
                        if (!listInsertPRLI.isEmpty()) {
                            for (ProductRequestLineItem prli : listInsertPRLI) {
                                if (prli.Order_Number__c == getStringNotNull(mapItem.get('oriOrderNo')) && prli.Order_SEQ__c == getDecimalNotNull(mapItem.get('oriOrderSeq'))) {
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

                if (!listUpdateComplete.isEmpty()) {
                    update listUpdateComplete;
                    system.debug('UPDATE SI_CAREPLUS_ORDER_COMPLETE TOTAL : ' + listUpdateComplete.size());
                }
                if (!execApplyPRLI.isEmpty()) {
                    /** 할당수량 증가 재고 공통모듈 호출 */
                    EX_RsrvUtil.execApplyProductItemMulti('AA', execApplyPRLI);
                    system.debug('execApplyPRLI TOTAL : ' + execApplyPRLI.size());
                }
                if (!listInsertSiBackIf.isEmpty()) {
                    Insert listInsertSiBackIf;
                    system.debug('INSERT SI_CAREPLUS_BACKIF TOTAL : ' + listInsertSiBackIf.size());
                }
                if (!listInsertSiRequest.isEmpty()) {
                    Insert listInsertSiRequest;
                    system.debug('INSERT SI_CAREPLUS_ORDER_REQUEST TOTAL : ' + listInsertSiRequest.size());
                }
                if (!listUpdateSiOrder.isEmpty()) {
                    List<ProductRequest> rsrvPrList = new List<ProductRequest>();
                    rsrvPrList = [SELECT Id, Order_Number__c, RSRV_Number__c FROM ProductRequest WHERE Order_Number__c IN :rsrvOrderNoList];
                    for (SI_CAREPLUS_ORDER__c sio : listUpdateSiOrder) {
                        for (ProductRequest rsrvPr : rsrvPrList) {
                            if (sio.ORDER_NO__c == rsrvPr.Order_Number__c) {
                                sio.ATTRIBUTE2__c = rsrvPr.RSRV_Number__c;
                            }
                        }
                    }
                    update listUpdateSiOrder;
                    system.debug('UPDATE SI_CAREPLUS_ORDER TOTAL : ' + listUpdateSiOrder.size());
                }

                if(!insertLogList.isEmpty()){
                    insert insertLogList;
                }

                //23 11 22 hyungho.chun 성공건들 id모음
                // for (sObject lData : siCarePlusOrderList) {
                    successCareplusOrderId += recordIdGroup;
                // }                
                
            }
            //23 11 15 hyungho.chun 어차피 쿼리에 안잡히면 여기올일이없어서 삭제처리
            // else{//23 09 18 hyungho.chun carePlus 주문대상 없을 때도 로그 남기게 수정
            //     SR_ONLINE_AUTO_SALE_EXC__c soase = new SR_ONLINE_AUTO_SALE_EXC__c();
            //     soase.ORDER_CHANNEL__c = EX_ConsumableUtil.CONSUMABLE_BESTSHOP;
            //     soase.Input_date__c = System.now();
            //     soase.ERROR_MESSAGE__c = '새로운 케어용품 주문이 없습니다.';
            //     insert soase;

            // }
        // }catch (JSONException je){
        //     System.debug('*** je.getMessage: ' + je.getMessage());
        //     System.debug('*** je.getLine -> ' + je.getLineNumber());
        //     Database.rollback(sp);
        // } catch (NullPointerException ne){
        //     System.debug('*** ne.getMessage: ' + ne.getMessage());
        //     System.debug('*** ne.getLine -> ' + ne.getLineNumber());
        //     Database.rollback(sp);
        } catch (Exception e) {
            System.debug('*** e.getMessage: ' + e.getMessage());
            System.debug('*** e.getLine -> ' + e.getLineNumber());
            Database.rollback(sp);

            String tempMsg = '[Error] line: ' + e.getLineNumber() + ', message: ' + e.getMessage();
            errorMap.put('className','EX_CarePlusOrder_ba.execute');
            errorMap.put('isSuccess','N'); //24 02 25 hyungho.chun 성공 실패 여부 추가 (이메일 및 실패시 메세지 전송용)
            errorMap.put('tempErrorMsg', errorMap.containsKey('tempErrorMsg') ? errorMap.get('tempErrorMsg') + tempMsg : tempMsg);
            errorMap.put('requestMsg', recordIdGroup);
            
            System.debug('Before Calling saveSaleExc // errorMap :: '+errorMap);
            EX_ConsumableUtil.saveSaleExc(errorMap);
        }
    }

    public void finish(Database.BatchableContext param1) {
        //23 11 15 hyungho.chun try 통과한 케이스 모음 로그
        Map<String,String> successMap = new Map<String,String>();
        successMap.put('className','EX_CarePlusOrder_ba.finish');
        successMap.put('isSuccess','Y'); //24 02 25 hyungho.chun 성공 실패 여부 추가 (이메일 및 실패시 메세지 전송용)
        successMap.put('tempErrorMsg', 'EX_CarePlusOrder_ba 성공한 케이스 recordId 모음');
        successMap.put('requestMsg', successCareplusOrderId);
        System.debug('Before Calling saveSaleExc // successMap :: '+successMap);
        EX_ConsumableUtil.saveSaleExc(successMap);

        Database.executeBatch(new EX_CarePlusOrderCancel_ba(batchSize), batchSize);
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
        siCareplusOrderRequest.ORIG_SYS_LINE_REF__c = getStringNotNull(getIntegerNotNull(lData.get('REQUEST_SEQ__c'))); /** BEST 주문 시퀀스 */
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
        siCareplusOrderRequest.ATTRIBUTE1__c = getStringNotNull(getIntegerNotNull(lData.get('ORDER_PRICE__c'))); //단가
        siCareplusOrderRequest.ATTRIBUTE2__c = getStringNotNull(lData.get('DIV_CODE__c')); //사업부코드
        siCareplusOrderRequest.TRANSFER_FLAG__c = 'N';
        siCareplusOrderRequest.AUTHORIZED_SERVICE_CENTER_CODE__c = F_ST_DEPT_CODE;
        //서인석 책임 요청 PROCESS_STATUS_CODE__c = 'I'
        siCareplusOrderRequest.PROCESS_STATUS_CODE__c = 'I';


        //24 02 15 hyungho.chun 혹시 REQUEST_DATE__c 값을 만약 넣는다면 꼭 YYYY-MM-DD HH24:MI:SS 형식으로 넣어야한다
        //sfdc에는 String이나 히로쿠에서 gerp로 송신때 Date형식으로 변환해주기때문에 미리 변환가능하게 형식만들어놔야함        

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
        // pr.Order_Date__c = getDatetimeWithNull(lData.get('ORDER_DATE__c'));
        // pr.Order_Date__c = getDatetimeWithNull(lData.get('ORDER_DATE__c')).addHours(-9);
        pr.Order_Date__c = getDatetimeWithNull(lData.get('ORDER_DATE__c')); //24 03 11 hyungho.chun 이제 히로쿠에서 9시간 차감해준후에 보내주기때문에 따로 로직제거

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

        //2023.07.18 gw.lee
        //케이플러스 금액관련 부분은 lineitem 추가
        prli.CONSUMER_Price__c = getDecimalNotNull(lData.get('ORDER_PRICE__c'));
        prli.PAYMENT_Amount__c = getDecimalNotNull(lData.get('ORDER_PRICE__c'));
        prli.SALE_Amount__c = getDecimalNotNull(lData.get('ORDER_PRICE__c')); //판매금액
        //seung yoon heo 2023.08.08 현금결재 > 가장계좌로 변경
        // prli.CASH_PAYMENT_Amount__c = getDecimalNotNull(lData.get('ORDER_AMT__c')); //CAREPLUS는 현금결제금액
        prli.VIRTUAL_ACCT_PAYMENT_Amount__c = getDecimalNotNull(lData.get('ORDER_AMT__c')); //CAREPLUS는 현금결제금액


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
        //23 12 06 hyungho.chun 상품준비중인 경우는 입고완료 -> 나머지는 예약모듈에서 상태값 잘 넣어줌
        if( orderStatus == EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_006){
            prli.Appointment_Status__c =  '입고완료';
        } 
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
        prli.BASIS_Parts_Number__c = sPartNo;
        // 소모품 주문 품목의 요청 수량
        prli.QuantityRequested = orderQty;
        //판매수량 = 주문수량
        prli.SALE_Quantity__c = orderQty;
        //주문단가
        prli.UnitPrice__c = getDecimalNotNull(lData.get('ORDER_PRICE__c'));
        prli.SALE_Amount__c = getIntegerNotNull(lData.get('ORDER_AMT__c'));
        prli.PAYMENT_Amount__c = getIntegerNotNull(lData.get('ORDER_AMT__c'));
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
        System.debug('prli :::: ' + prli);
        return prli;
    }

    @AuraEnabled
    public static String setOrderStatus(String workFlag) {
        System.debug('setOrderStatus ::::::::::::::: before ' + workFlag);
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
            workFlag = 'E';//오류
        }
        System.debug('setOrderStatus :::: after ' + orderStatus);
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

    //sj.yang 2023.08.14
    public static Datetime getDeliveryDate() {

        Datetime deliveryDate = System.now(); // 정상배송완료일
        Integer stateYear = deliveryDate.year(); // 현재년도
        Integer countWDay = 0; // 평일 카운트
        Date stateDate = Date.newInstance(deliveryDate.year(), deliveryDate.month(), deliveryDate.day()+1); // 기준날짜
        Integer dTHour = deliveryDate.hour(); // 현재시간
        System.debug('현재시간 : ' + dTHour);
        
        if(dTHour < 19) { // 19시 이후 기준날짜 + 1
            stateDate = Date.newInstance(deliveryDate.year(), deliveryDate.month(), deliveryDate.day());
            System.debug('기준날짜 바뀜 : ' + stateDate);
        }
        
        
        List<SM_HOLIDAY_MASTER__c> HOLIDAYItems =  [SELECT 	Id, DIV_CODE__c, HOLI_END_DT__c, HOLI_START_DT__c, HOLI_TYPE__c, HOLY_REASON__c
        FROM SM_HOLIDAY_MASTER__c
        WHERE HOLI_TYPE__c IN('A', 'B', 'D', 'Z')
        AND HOLI_APPLY_TY__c = 'C'
        AND CALENDAR_YEAR(HOLI_START_DT__c) IN(:stateYear, :stateYear+1)
        AND HOLI_START_DT__c >= TODAY
        ORDER BY HOLI_START_DT__c ASC];
        
        
        for(SM_HOLIDAY_MASTER__c sm : HOLIDAYItems) {
            if(countWDay == 2) {               
                break;
            } else if(countWDay == 0) {
                if(Date.newInstance(stateDate.year(), stateDate.month(), stateDate.day()+1) == sm.HOLI_START_DT__c) {
                    stateDate = Date.newInstance(stateDate.year(), stateDate.month(), stateDate.day()+1);                    
                } else if(Date.newInstance(stateDate.year(), stateDate.month(), stateDate.day()+2) == sm.HOLI_START_DT__c) {
                    stateDate = Date.newInstance(stateDate.year(), stateDate.month(), stateDate.day()+2);
                    countWDay++;                    
                } else {
                    stateDate = Date.newInstance(stateDate.year(), stateDate.month(), stateDate.day()+2);
                    break;                    
                }
            } else if(countWDay == 1) {
                if(Date.newInstance(stateDate.year(), stateDate.month(), stateDate.day()+1) == sm.HOLI_START_DT__c) {
                    stateDate = Date.newInstance(stateDate.year(), stateDate.month(), stateDate.day()+1);                    
                } else {
                    stateDate = Date.newInstance(stateDate.year(), stateDate.month(), stateDate.day()+1);
                    countWDay++;           
                }
            }      
        }        
        deliveryDate = Datetime.newInstance(stateDate.year(), stateDate.month(), stateDate.day(), 23, 59, 59);
        System.debug('정상배송완료일 : ' + deliveryDate);
        return deliveryDate;
    }

}