/**
 * Created by I2MAX.JAEYEONLEE on 2023-01-04.
 */

public without sharing class EX_DocPreviewController {

    @AuraEnabled
    public static  Map<String, String> getTemplate(Map<String, Object> paramMap){
        // System.debug('속도측정 -------------------------------------------------- EX_DocPreviewController.getTemplate (start):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
        
        Map<String, String> returnMap = new Map<String, String>();
        Map<String, Id> imgMap = new Map<String,Id>();
        TemplateMgmt__c tmpltMgmt = new TemplateMgmt__c();
        TemplateMgmt__c tmpltMgmtInvoice = new TemplateMgmt__c();
        Id conId = null;
        //23 09 02 hyungho.chun
        String contactAddress ='';
        contactAddress += String.valueOf(paramMap.get('contactAddress'));
        System.debug('contactAddress : '+contactAddress);
        
        List<EX_SuppliesController.ItemTable> standardOrderDataList = null;
        List<EX_SuppliesController.ItemTable> soldOutOrderDataList = null;
        String value = null;
        String RCVRName = '';
        String RCVREmail = '';
        String RCVRPhone = '';
        String RCVRAddr = '';
        String Note = '';
        String stdConsumableOrderId = null;
        String soldOutConsumableOrderId = null;
        String appointmentStatus = '';

        System.debug('paramMap : '+paramMap);
        System.debug(paramMap.get('isManagement') );
        System.debug('paramMap.get(\'discountType\') > '+paramMap.get('discountType'));
        System.debug('paramMap.get(\'Note\')  :' + paramMap.get('Note') );

        //ProductRequest 레벨의 할인은 사용하지 않음
        //String discountType = (String)paramMap.get('discountType');
        Note = (String)paramMap.get('Note');


        //소모품주문관리 (견적/명세서 정보)
        // System.debug('속도측정 -------------------------------------------------- EX_DocPreviewController.isManagement-' + (Boolean)paramMap.get('isManagement') + ':' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
        
        if((Boolean)paramMap.get('isManagement') == true){
            String orderNumber = (String)paramMap.get('orderNumber');
            System.debug('orderNumber : '+orderNumber);

            List<ProductRequestLineItem> requestLineItems = [SELECT ParentId,Parent.CONSIGNEE_Name__c,Parent.CONSIGNEE_Address__c,Parent.CONSIGNEE_Address_DETAIL__c,Parent.CONSIGNEE_TPNO_1__c, Parent.Order_CUST_Address__c, Parent.Order_CUST_Address_DETAIL__c, Parent.Order_CUST_TPNO_1__c, Parent.Order_CUST_TPNO_2__c,
                                                                    Parent.CONSIGNEE_TPNO_2__c,CONSUMER_Price__c,ASC_Price__c, Product2.ASC_PRICE__c, fm_ProductName__c,PART_DESC_KOR__c,SALE_Quantity__c, CANCEL_Quantity__c,PART_NO__c,
                                                                    Product2.PART_DESC_KOR__c, Product2.fm_PartDescription__c, Product2.PART_DESC__c, fm_Consumables_PART_DESC_KOR__c,
                                                                    SALE_Amount__c, Last_Discount_Amount__c, PAYMENT_Amount__c , SALE_Discount_Type_Code__c, Appointment_Status__c
                                                                    //23 07 11 DKBMC 전형호 취소, 반품 및 교환 제품 쿼리제외      
                                                                    ,Product2Id,ProductRequestLineItemNumber,Id,Consumables_Order_Status__c
                                                                FROM ProductRequestLineItem WHERE Order_Number__c =: orderNumber
                                                                // AND RecordType.Name ='소모품'
                                                                // 23 07 11 DKBMC 전형호 취소, 반품 및 교환 제품 쿼리제외
                                                                AND Consumables_Order_Status__c != null
                                                                AND Consumables_Order_Status__c !=: EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_003 
                                                                AND Consumables_Order_Status__c !=: EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_004 
                                                                AND Consumables_Order_Status__c !=: EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_005
                                                                AND Consumables_Order_Detail__c = null
                                                                AND Consumables_Business_Type_Code__c != null
                                                                AND Consumables_Business_Type_Code__c = 'Order'
                                                                AND (SALE_Quantity__c != 0 OR CANCEL_Quantity__c != 0)
                                                            
                                                                ORDER BY Product2Id,ProductRequestLineItemNumber DESC
                                                                ];
            // System.debug('속도측정 -------------------------------------------------- EX_DocPreviewController.requestLineItems(바로):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
            
            standardOrderDataList = new List<EX_SuppliesController.ItemTable>();
            System.debug('this prli is null ???? >>>>> : ' + requestLineItems);
            List<ProductRequestLineItem> requestLineItemsFiltered = new List<ProductRequestLineItem>();
            Set<String> productSet = new Set<String>();
            
            // System.debug('속도측정 -------------------------------------------------- EX_DocPreviewController.requestLineItems.size() - ' + requestLineItems.size() + ':' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
            
            for(ProductRequestLineItem item : requestLineItems){
                if(!productSet.contains(item.Product2Id)){
                    requestLineItemsFiltered.add(item);
                }
                productSet.add(item.Product2Id);
            }
            
            // System.debug('속도측정 -------------------------------------------------- EX_DocPreviewController.requestLineItemsFiltered.size() - ' + requestLineItemsFiltered.size() + ':' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));

            for(ProductRequestLineItem item : requestLineItemsFiltered){
                EX_SuppliesController.ItemTable table = new EX_SuppliesController.ItemTable();
                table.ProductCode = item.PART_NO__c != null ? item.PART_NO__c : '' ;
                table.ProductName = item.fm_Consumables_PART_DESC_KOR__c;
                //임직원 할인의 경우 임직원가를 표시, 그 외는 소비자가를 표시
                //if(discountType!=null && discountType=='임직원'){
                if(item.SALE_Discount_Type_Code__c!=null && !item.SALE_Discount_Type_Code__c.equals('')&&item.SALE_Discount_Type_Code__c=='E'){
                    System.debug('item.ASC_Price__c ::: '+item.Product2.ASC_PRICE__c);
                    table.ASCPrice = item.Product2.ASC_PRICE__c != null ? item.Product2.ASC_PRICE__c : 0;}

                    table.Price = item.Product2.ASC_PRICE__c != null ? item.Product2.ASC_PRICE__c : 1;

                //table.Price = item.CONSUMER_Price__c != null ? item.CONSUMER_Price__c : 0 ;
                table.QTY = item.SALE_Quantity__c != null ? (item.SALE_Quantity__c != 0 ? item.SALE_Quantity__c : item.CANCEL_Quantity__c) : 1 ;
                table.Note = Note !=null ? Note : '';

                //23.05.17 견적서의 금액 표시를 (수량 * 단가)  => (판매금액 - 할인금액)으로 표시
                table.SaleAmount = item.SALE_Amount__c != null ? item.SALE_Amount__c : 1; //판매금액
                table.LastDiscountAmount = item.Last_Discount_Amount__c != null ? item.Last_Discount_Amount__c : 1; //할인금액

                // PHJ
                System.debug('item.Appointment_Status__c =? ' + item.Appointment_Status__c);
                appointmentStatus = item.Appointment_Status__c; // 예약 상태

                standardOrderDataList.add(table);
            }

            System.debug('standardOrderDataList : ' +standardOrderDataList);
            RCVRName = requestLineItems[0].Parent.CONSIGNEE_Name__c != null ? requestLineItems[0].Parent.CONSIGNEE_Name__c : '';
            //23 09 04 hyungho.chun 화면에서 받는값 사용
            RCVRName = (String) paramMap.get('RCVRName');
            System.debug('RCVRName : ' + RCVRName);
            RCVREmail = (String) paramMap.get('RCVREmail');
            System.debug('RCVREmail : ' + RCVREmail);

            // PHJ 240124
            String RCVRAddr1 = requestLineItems[0].Parent.Order_CUST_Address__c != null ? requestLineItems[0].Parent.Order_CUST_Address__c : '';
            String RCRVAddr2 = requestLineItems[0].Parent.Order_CUST_Address_DETAIL__c != null ? requestLineItems[0].Parent.Order_CUST_Address_DETAIL__c : '';
            RCVRAddr = RCVRAddr1 + RCRVAddr2;
            RCVRPhone =  requestLineItems[0].Parent.Order_CUST_TPNO_1__c != null ? requestLineItems[0].Parent.Order_CUST_TPNO_1__c : requestLineItems[0].Parent.Order_CUST_TPNO_2__c == null ?  requestLineItems[0].Parent.Order_CUST_TPNO_1__c : '';
            // RCVRPhone =  requestLineItems[0].Parent.CONSIGNEE_TPNO_1__c != null ? requestLineItems[0].Parent.CONSIGNEE_TPNO_1__c : requestLineItems[0].Parent.CONSIGNEE_TPNO_2__c == null ?  requestLineItems[0].Parent.CONSIGNEE_TPNO_1__c : '';
            // String RCVRAddr1 = requestLineItems[0].Parent.CONSIGNEE_Address__c != null ? requestLineItems[0].Parent.CONSIGNEE_Address__c : '';
            // String RCRVAddr2 = requestLineItems[0].Parent.CONSIGNEE_Address_DETAIL__c != null ? requestLineItems[0].Parent.CONSIGNEE_Address_DETAIL__c : '';
            // RCVRAddr = RCVRAddr1 + RCRVAddr2;

            // RCVRAddr = requestLineItems[0].Parent.CONSIGNEE_Address__c + '' + requestLineItems[0].Parent.CONSIGNEE_Address_DETAIL__c;
            stdConsumableOrderId = requestLineItems[0].ParentId;
            value = (String)paramMap.get('value');
            // soldOutConsumableOrderId = (String)paramMap.get('soldOutConsumableOrderId');

            
        }
        //소모품 택배주문 견적서
        else{
            System.debug('소모품 택배주문 견적서 START >> '  );
            stdConsumableOrderId = (String)paramMap.get('stdConsumableOrderId');
            System.debug('stdConsumableOrderId :: ' + stdConsumableOrderId);
            soldOutConsumableOrderId = (String)paramMap.get('soldOutConsumableOrderId');
            System.debug('soldOutConsumableOrderId :: ' + soldOutConsumableOrderId);
            System.debug('contactId > ' + paramMap.get('contactId'));
            conId =  (Id) paramMap.get('contactId');

            Contact conInfo = [SELECT Phone,fm_ADDRESS_NEW__c,MobilePhone,Name FROM Contact WHERE Id = :conId ];

            String orderNumber = (String)paramMap.get('orderNumber');
            System.debug('조회 시작 ');
            List<ProductRequestLineItem> requestLineItems2 = new List<ProductRequestLineItem>();
            List<ProductRequestLineItem> soldOutrequestLineItems2 = new List<ProductRequestLineItem>();
            
            // System.debug('속도측정 -------------------------------------------------- EX_DocPreviewController.조회시작:' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
            
            if(stdConsumableOrderId!=null && !stdConsumableOrderId.equals('')){
                System.debug('일반주문 쿼리');
                    requestLineItems2 = [SELECT ParentId,Parent.CONSIGNEE_Name__c,Parent.CONSIGNEE_Address__c,Parent.CONSIGNEE_Address_DETAIL__c,Parent.CONSIGNEE_TPNO_1__c, Parent.Order_CUST_Address__c, Parent.Order_CUST_Address_DETAIL__c, Parent.Order_CUST_TPNO_1__c, Parent.Order_CUST_TPNO_2__c,
                        Parent.CONSIGNEE_TPNO_2__c,CONSUMER_Price__c,ASC_Price__c, fm_ProductName__c,PART_DESC_KOR__c,SALE_Quantity__c,PART_NO__c,
                        Product2.PART_DESC_KOR__c, Product2.fm_PartDescription__c, Product2.PART_DESC__c, fm_Consumables_PART_DESC_KOR__c,
                        SALE_Amount__c, Last_Discount_Amount__c, PAYMENT_Amount__c , SALE_Discount_Type_Code__c, Consumables_Order_Class_Code__c, Appointment_Status__c
                FROM ProductRequestLineItem WHERE Order_Number__c =: orderNumber AND ParentId = :stdConsumableOrderId  ];
            } else {
                System.debug('품절 쿼리');
                        requestLineItems2 = [SELECT ParentId,Parent.CONSIGNEE_Name__c,Parent.CONSIGNEE_Address__c,Parent.CONSIGNEE_Address_DETAIL__c,Parent.CONSIGNEE_TPNO_1__c, Parent.Order_CUST_Address__c, Parent.Order_CUST_Address_DETAIL__c, Parent.Order_CUST_TPNO_1__c, Parent.Order_CUST_TPNO_2__c,
                        Parent.CONSIGNEE_TPNO_2__c,CONSUMER_Price__c,ASC_Price__c, fm_ProductName__c,PART_DESC_KOR__c,SALE_Quantity__c,PART_NO__c,
                        Product2.PART_DESC_KOR__c, Product2.fm_PartDescription__c, Product2.PART_DESC__c, fm_Consumables_PART_DESC_KOR__c,
                        SALE_Amount__c, Last_Discount_Amount__c, PAYMENT_Amount__c , SALE_Discount_Type_Code__c, Consumables_Order_Class_Code__c, Appointment_Status__c
                        FROM ProductRequestLineItem WHERE ParentId = :soldOutConsumableOrderId  ];
            }
            if(paramMap.get('IsPrint') == true){
                        soldOutrequestLineItems2 = [SELECT ParentId,Parent.CONSIGNEE_Name__c,Parent.CONSIGNEE_Address__c,Parent.CONSIGNEE_Address_DETAIL__c,Parent.CONSIGNEE_TPNO_1__c,
                        Parent.CONSIGNEE_TPNO_2__c,CONSUMER_Price__c,ASC_Price__c, fm_ProductName__c,PART_DESC_KOR__c,SALE_Quantity__c,PART_NO__c,
                        Product2.PART_DESC_KOR__c, Product2.fm_PartDescription__c, Product2.PART_DESC__c, fm_Consumables_PART_DESC_KOR__c,
                        SALE_Amount__c, Last_Discount_Amount__c, PAYMENT_Amount__c , SALE_Discount_Type_Code__c, Consumables_Order_Class_Code__c, Appointment_Status__c
                        FROM ProductRequestLineItem WHERE ParentId = :soldOutConsumableOrderId  ];
            }
            // List<ProductRequestLineItem> requestLineItems2 = [SELECT ParentId,Parent.CONSIGNEE_Name__c,Parent.CONSIGNEE_Address__c,Parent.CONSIGNEE_Address_DETAIL__c,Parent.CONSIGNEE_TPNO_1__c,
            //                                                         Parent.CONSIGNEE_TPNO_2__c,CONSUMER_Price__c,ASC_Price__c, fm_ProductName__c,PART_DESC_KOR__c,SALE_Quantity__c,PART_NO__c,
            //                                                         Product2.PART_DESC_KOR__c, Product2.fm_PartDescription__c, Product2.PART_DESC__c, fm_Consumables_PART_DESC_KOR__c,
            //                                                         SALE_Amount__c, Last_Discount_Amount__c, PAYMENT_Amount__c , SALE_Discount_Type_Code__c
            //                                                         FROM ProductRequestLineItem WHERE Order_Number__c =: orderNumber
            // AND ParentId =: (Id)paramMap.get('parentId')
            // ];
            System.debug('orderNumber:: ' + orderNumber);
            System.debug('paramMap.get(\'stdConsumableOrderId\') :: ' + paramMap.get('stdConsumableOrderId'));

            //System.debug(' paramMap.get(standardOrderData)[0].ParentId 조회 :  ' + paramMap.get('standardOrderData')[0].ParentId);
            System.debug('requestLineItems2 ::  ' + requestLineItems2);
            standardOrderDataList = new List<EX_SuppliesController.ItemTable>();
            soldOutOrderDataList = new List<EX_SuppliesController.ItemTable>();
            
            // System.debug('속도측정 -------------------------------------------------- EX_DocPreviewController.requestLineItems2.size() -' + requestLineItems2.size() + ' (end):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
            
            for(ProductRequestLineItem item : requestLineItems2){
                EX_SuppliesController.ItemTable table = new EX_SuppliesController.ItemTable();
                table.ProductCode = item.PART_NO__c != null ? item.PART_NO__c : '' ;
                table.ProductName = item.fm_Consumables_PART_DESC_KOR__c;
                
                if(item.SALE_Discount_Type_Code__c!=null && !item.SALE_Discount_Type_Code__c.equals('')&&item.SALE_Discount_Type_Code__c=='E'){
                    System.debug('item.ASC_Price__c ::: '+item.ASC_Price__c);
                    table.ASCPrice = item.ASC_Price__c != null ? item.ASC_Price__c : 0;
                    table.Price = item.ASC_Price__c != null ? item.ASC_Price__c : 0;
                } else {
                    table.Price = item.CONSUMER_Price__c != null ? item.CONSUMER_Price__c : 0 ;
                }
                table.QTY = item.SALE_Quantity__c != null ? item.SALE_Quantity__c : 0 ;
                
                //23.08.28 PHJ
                // table.Note = Note !=null ? Note : '';
                table.Note = item.Consumables_Order_Class_Code__c;
                // table.sDescription = item.Consumables_Order_Class_Code__c;

                //23.05.17 견적서의 금액 표시를 (수량 * 단가)  => (판매금액 - 할인금액)으로 표시
                table.SaleAmount = item.SALE_Amount__c != null ? item.SALE_Amount__c : 0; //판매금액
                table.LastDiscountAmount = item.Last_Discount_Amount__c != null ? item.Last_Discount_Amount__c : 0; //할인금액
                //standardOrderDataList.add(table);

                // PHJ
                System.debug('item.Appointment_Status__c =? ' + item.Appointment_Status__c);
                appointmentStatus = item.Appointment_Status__c; // 예약 상태
                
                //23.08.31 PHJ
                if(stdConsumableOrderId!=null && !stdConsumableOrderId.equals('')){
                    standardOrderDataList.add(table);
                }
            }

            // 23.08.14 gw.lee
            // 의미없는 로직 왜 있는지 모르겠음
            if(paramMap.get('IsPrint') == true){
                for(ProductRequestLineItem item : soldOutrequestLineItems2){
                    EX_SuppliesController.ItemTable table = new EX_SuppliesController.ItemTable();
                    table.ProductCode = item.PART_NO__c != null ? item.PART_NO__c : '' ;
                    table.ProductName = item.fm_Consumables_PART_DESC_KOR__c;
                    if(item.SALE_Discount_Type_Code__c!=null && !item.SALE_Discount_Type_Code__c.equals('')&&item.SALE_Discount_Type_Code__c=='E'){
                        System.debug('item.ASC_Price__c ::: '+item.ASC_Price__c);
                        table.ASCPrice = item.ASC_Price__c != null ? item.ASC_Price__c : 0;
                        table.Price = item.ASC_Price__c != null ? item.ASC_Price__c : 0;
                    } else {    
                        table.Price = item.CONSUMER_Price__c != null ? item.CONSUMER_Price__c : 0 ;
                    }
                    table.QTY = item.SALE_Quantity__c != null ? item.SALE_Quantity__c : 0 ;
                    
                    //23.08.28 PHJ
                    // table.Note = Note !=null ? Note : '';
                    table.Note = item.Consumables_Order_Class_Code__c;
                    // table.sDescription = item.Consumables_Order_Class_Code__c;

                    //23.05.17 견적서의 금액 표시를 (수량 * 단가)  => (판매금액 - 할인금액)으로 표시
                    table.SaleAmount = item.SALE_Amount__c != null ? item.SALE_Amount__c : 0; //판매금액
                    table.LastDiscountAmount = item.Last_Discount_Amount__c != null ? item.Last_Discount_Amount__c : 0; //할인금액
                    
                    // PHJ
                    System.debug('item.Appointment_Status__c =? ' + item.Appointment_Status__c);
                    appointmentStatus = item.Appointment_Status__c; // 예약 상태
                    
                    //23.08.31 PHJ
                    soldOutOrderDataList.add(table);
                }
            }

            System.debug('standardOrderDataList : ' +standardOrderDataList);
            System.debug('soldOutOrderDataList : ' +soldOutOrderDataList);
            // paramMap.get('standardOrderData') 조회항목 :
            // ASCPrice, DIVCODE, Id , OrderNumber , ParentId, Price , ProductCode, ProductName
            // QTY , sLocationId, sProductId , sProductItemId , SalesAmount
            // PaymentAmount_CASH , PaymentAmount_CARD, PaymentAmount , DiscountAmount,DIV_CODE__c

            // standardOrderDataList = (List<EX_SuppliesController.ItemTable>) JSON.deserialize((String) paramMap.get('standardOrderData'), List<EX_SuppliesController.ItemTable>.class);
            // System.debug('소모품 택배 주문 견석서 생성시 Table을 만드는 stadardOrderDataList : ' + standardOrderDataList);
            // soldOutOrderDataList = (List<EX_SuppliesController.ItemTable>) JSON.deserialize((String) paramMap.get('soldOutOrderData'), List<EX_SuppliesController.ItemTable>.class);
            // List<ProductRequestLineItem> requestLineItems = new List<ProductRequestLineItem>();

            // if(standardOrderDataList.isEmpty()){
            //     requestLineItems = [SELECT CONSIGNEE_TPNO_1__c, CONSIGNEE_TPNO_2__c,CONSIGNEE_Address__c
            //     FROM ProductRequestLineItem WHERE ParentId =: soldOutOrderDataList[0].ParentId];
            // }
            // else{
            //     requestLineItems = [SELECT CONSIGNEE_TPNO_1__c, CONSIGNEE_TPNO_2__c,CONSIGNEE_Address__c
            //     FROM ProductRequestLineItem WHERE ParentId =: standardOrderDataList[0].ParentId];
            // }

            value = (String)paramMap.get('value');
            RCVRName = (String) paramMap.get('RCVRName');
            RCVREmail = (String) paramMap.get('RCVREmail');
            
            // PHJ 240124
            String RCVRAddr1 = requestLineItems2[0].Parent.Order_CUST_Address__c == null ? requestLineItems2[0].Parent.Order_CUST_Address__c : '';
            String RCRVAddr2 = requestLineItems2[0].Parent.Order_CUST_Address_DETAIL__c == null ? requestLineItems2[0].Parent.Order_CUST_Address_DETAIL__c : '';
            RCVRAddr = RCVRAddr1 + RCRVAddr2;
            RCVRPhone =  requestLineItems2[0].Parent.Order_CUST_TPNO_1__c == null ? requestLineItems2[0].Parent.Order_CUST_TPNO_2__c : requestLineItems2[0].Parent.Order_CUST_TPNO_1__c == null ?  requestLineItems2[0].Parent.Order_CUST_TPNO_1__c : '';
            // String RCVRAddr1 = requestLineItems2[0].Parent.CONSIGNEE_Address__c == null ? requestLineItems2[0].Parent.CONSIGNEE_Address__c : '';
            // String RCRVAddr2 = requestLineItems2[0].Parent.CONSIGNEE_Address_DETAIL__c == null ? requestLineItems2[0].Parent.CONSIGNEE_Address_DETAIL__c : '';
            // RCVRAddr = RCVRAddr1 + RCRVAddr2;
            // RCVRPhone =  requestLineItems2[0].Parent.CONSIGNEE_TPNO_1__c == null ? requestLineItems2[0].Parent.CONSIGNEE_TPNO_2__c : requestLineItems2[0].Parent.CONSIGNEE_TPNO_1__c == null ?  requestLineItems2[0].Parent.CONSIGNEE_TPNO_1__c : '';

            // RCVRPhone =  requestLineItems2[0].Parent.CONSIGNEE_TPNO_1__c !=null ? requestLineItems2[0].Parent.CONSIGNEE_TPNO_1__c : requestLineItems2[0].Parent.CONSIGNEE_TPNO_2__c;
            // RCVRAddr = requestLineItems2[0].Parent.CONSIGNEE_Address__c ==null ? '' : requestLineItems2[0].Parent.CONSIGNEE_Address__c;
            // RCVRPhone =  requestLineItems[0].CONSIGNEE_TPNO_1__c !=null ? requestLineItems[0].CONSIGNEE_TPNO_1__c : requestLineItems[0].CONSIGNEE_TPNO_2__c;
            // RCVRAddr = requestLineItems[0].CONSIGNEE_Address__c ==null ? '' : requestLineItems[0].CONSIGNEE_Address__c;
            // Note = (String) paramMap.get('Note');
            // stdConsumableOrderId = (String)paramMap.get('stdConsumableOrderId');
            // soldOutConsumableOrderId = (String)paramMap.get('soldOutConsumableOrderId');
            System.debug('stdConsumableOrderId :: ' + stdConsumableOrderId);  //ProductReqeust ID
            System.debug('soldOutConsumableOrderId :: ' + soldOutConsumableOrderId);
        }

        String docCode ='소모품견적서';
        List<TemplateMgmt__c> tmpltMgmtList = [ SELECT Name
                                                    , TemplateCode__c
                                                    , Title__c
                                                    , Content_c__c
                                                FROM TemplateMgmt__c
                                                WHERE TemplateCode__c =: docCode ];
        
        // System.debug('속도측정 -------------------------------------------------- EX_DocPreviewController.query tmpltMgmtList.size() -' + tmpltMgmtList.size() + ' (end):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
        
        if(tmpltMgmtList.size()>0)
            tmpltMgmt = tmpltMgmtList[0];

            docCode ='소모품명세서';
            tmpltMgmtList = [SELECT Name
                    , TemplateCode__c
                    , Title__c
                    , Content_c__c
            FROM TemplateMgmt__c
            WHERE TemplateCode__c = : docCode
            ];
            if(tmpltMgmtList.size()>0)
                tmpltMgmtInvoice = tmpltMgmtList[0];

            String cntnt = tmpltMgmt.Content_c__c;
            String cntntInvoice = '';

            cntntInvoice = tmpltMgmtInvoice.Content_c__c;
            Integer count = 0;
            Decimal totalSum = 0;
            Decimal totalCount = 0;


            DateTime todaysDate = System.today();
            String todaysDateStr = todaysDate.format('yyyy-MM-dd');
            String todayMonth = todaysDate.format('MM');
            String todayDay = todaysDate.format('dd');
        
            // System.debug('속도측정 -------------------------------------------------- EX_DocPreviewController.standardOrderDataList != null -' + (standardOrderDataList != null) + ' (end):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
        
            System.debug('standardOrderDataList dastalist > ' + standardOrderDataList);
            System.debug('soldOutOrderDataListsoldOutOrderDataList dastalist > ' + soldOutOrderDataList);
            if(standardOrderDataList != null){
                for (EX_SuppliesController.ItemTable dataList : standardOrderDataList) {
                System.debug('standardOrderDataList dastalist > ' + dataList);
                count++;
                cntnt = cntnt.replaceAll('<!--#Loop Start#-->', ' <tr><td>#SEQ#</td><td>#ProductCode#</td><td>#ProductName#</td><td>#QTY#</td>' +
                        '<td style="text-align: right;">#Price#&nbsp;</td><td style="text-align: right;">#EachTotalPrice#&nbsp;</td><td>#Memo#</td></tr> <!--#Loop Start#-->');

                cntnt = cntnt.replaceAll('#SEQ#', String.valueOf(count));
                cntnt = cntnt.replaceAll('#ProductCode#',dataList.ProductCode);
                cntnt = cntnt.replaceAll('#ProductName#',  dataList.ProductName );
                cntnt = cntnt.replaceAll('#QTY#',  String.valueOf(dataList.QTY) );
                // if(discountType!=null && discountType=='임직원'){
                if(dataList.discountType!=null && dataList.discountType=='E'){
                    System.debug(' dataList.ASCPrice.format()' +  dataList.ASCPrice.format());
                    // cntnt = cntnt.replaceAll('#Price#',   dataList.ASCPrice.format() );
                    cntnt = cntnt.replaceAll('#Price#',  dataList.ASCPrice.format() );
                    // cntnt = cntnt.replaceAll('#EachTotalPrice#',  String.valueOf((dataList.QTY * dataList.ASCPrice).format()));
                    cntnt = cntnt.replaceAll('#EachTotalPrice#',  String.valueOf((dataList.SaleAmount - dataList.LastDiscountAmount).format()));
                } else {
                    cntnt = cntnt.replaceAll('#Price#', ((dataList.SaleAmount -  dataList.LastDiscountAmount)/dataList.QTY).format());
                    System.debug( '(dataList.price).format() >>> ' + dataList.price.format());
                    // cntnt = cntnt.replaceAll('#EachTotalPrice#',  String.valueOf((dataList.QTY * dataList.price).format()));
                    if(dataList.SaleAmount!=null && dataList.LastDiscountAmount !=null){
                        cntnt = cntnt.replaceAll('#EachTotalPrice#',  String.valueOf((dataList.SaleAmount - dataList.LastDiscountAmount).format()));
                    }
                }
                // cntnt = cntnt.replaceAll('#EachTotalPrice#',  String.valueOf((dataList.QTY * dataList.price).format()));
                // cntnt = cntnt.replaceAll('#Price#',   dataList.price.format() );

                //23.08.28 PHJ
                // cntnt = cntnt.replaceAll('#Memo#',  '' );
                // cntnt = cntnt.replaceAll('#Memo#',  dataList.Note );
                System.debug('appointmentStatus =? ' + appointmentStatus);
                System.debug('paramMap.get(\'IsPrint\') =? ' + paramMap.get('IsPrint'));
                if(appointmentStatus == '입고완료' && paramMap.get('IsPrint') == true){
                    cntnt = cntnt.replaceAll('#Memo#',  '품절' );
                } else if (appointmentStatus == '입고완료' && paramMap.get('IsPrint') == false) {
                    cntnt = cntnt.replaceAll('#Memo#',  '' );
                } else if(appointmentStatus != '입고완료' && paramMap.get('IsPrint') == null) {
                    cntnt = cntnt.replaceAll('#Memo#',  '품절' );
                } else {
                    cntnt = cntnt.replaceAll('#Memo#',  '' );
                }

                cntntInvoice = cntntInvoice.replaceAll('<!--#Loop Start#-->', '<tr class="end"><td style="width:20px">#Month#</td><td style="width:20px">#Day#</td><td style="width:200px;">#ProductName#</td><td style="width:40px"></td><td style="width:60px">#QTY#</td><td style="width:120px">#Price#</td>' +
                        '<td style="width:80px">#EachTotalPrice#</td><td style="width:40px" colspan="2" class="end">#Memo#</td></tr> <!--#Loop Start#-->');
                cntntInvoice = cntntInvoice.replaceAll('#Month#', todayMonth);
                cntntInvoice = cntntInvoice.replaceAll('#Day#', todayDay);
                cntntInvoice = cntntInvoice.replaceAll('#ProductName#',  dataList.ProductName );
                cntntInvoice = cntntInvoice.replaceAll('#QTY#',  String.valueOf(dataList.QTY) );
                //cntntInvoice = cntntInvoice.replaceAll('#Price#',String.valueOf(dataList.price.format()) );
                if(dataList.discountType!=null && dataList.discountType=='E'){
                    System.debug(' dataList.ASCPrice.format()' +  dataList.ASCPrice.format());
                    // cntnt = cntnt.replaceAll('#Price#',   dataList.ASCPrice.format() );
                    cntntInvoice = cntntInvoice.replaceAll('#Price#',  dataList.ASCPrice.format() );
                    // cntntInvoice = cntntInvoice.replaceAll('#EachTotalPrice#',  String.valueOf((dataList.QTY * dataList.ASCPrice).format()));
                    cntntInvoice = cntntInvoice.replaceAll('#EachTotalPrice#',  String.valueOf((dataList.SaleAmount -  dataList.LastDiscountAmount).format()));
                    if(dataList.SaleAmount!=null && dataList.LastDiscountAmount!=null){
                        totalSum += dataList.SaleAmount -  dataList.LastDiscountAmount;
                    }
                } else {
                    cntntInvoice = cntntInvoice.replaceAll('#Price#',   ((dataList.SaleAmount -  dataList.LastDiscountAmount)/dataList.QTY).format() );
                    System.debug( '(dataList.price).format() >>> ' + dataList.price.format());
                    if(dataList.SaleAmount!=null && dataList.LastDiscountAmount!=null){
                        cntntInvoice = cntntInvoice.replaceAll('#EachTotalPrice#',  String.valueOf((dataList.SaleAmount -  dataList.LastDiscountAmount).format()));
                    }

                    // totalSum += dataList.QTY * dataList.price;
                    if(dataList.SaleAmount!=null && dataList.LastDiscountAmount!=null){
                        totalSum += dataList.SaleAmount -  dataList.LastDiscountAmount;
                    }
                }
                // cntntInvoice = cntntInvoice.replaceAll('#EachTotalPrice#',  String.valueOf((dataList.QTY * dataList.price).format()));
                cntntInvoice = cntntInvoice.replaceAll('#Memo#',  '' );


                // totalSum += dataList.QTY * dataList.price;
                totalCount += dataList.QTY;
                }
            }
            //23.09.05 PHJ
            else if(soldOutOrderDataList != null){
                for (EX_SuppliesController.ItemTable dataList : soldOutOrderDataList) {
                    System.debug('soldOutOrderDataList dastalist > ' + dataList);
                    count++;
                    cntnt = cntnt.replaceAll('<!--#Loop Start#-->', ' <tr><td>#SEQ#</td><td>#ProductCode#</td><td>#ProductName#</td><td>#QTY#</td>' +
                            '<td style="text-align: right;">#Price#&nbsp;</td><td style="text-align: right;">#EachTotalPrice#&nbsp;</td><td>#Memo#</td></tr> <!--#Loop Start#-->');
                    cntnt = cntnt.replaceAll('#SEQ#', String.valueOf(count));
                    cntnt = cntnt.replaceAll('#ProductCode#',dataList.ProductCode);
                    cntnt = cntnt.replaceAll('#ProductName#',  dataList.ProductName );
                    cntnt = cntnt.replaceAll('#QTY#',  String.valueOf(dataList.QTY) );
                    if(dataList.discountType!=null && dataList.discountType=='E'){
                        System.debug(' dataList.ASCPrice.format()' +  dataList.ASCPrice.format());
                        cntnt = cntnt.replaceAll('#Price#',  dataList.ASCPrice.format() );
                        cntnt = cntnt.replaceAll('#EachTotalPrice#',  String.valueOf((dataList.SaleAmount - dataList.LastDiscountAmount).format()));
                    } else {
                        cntnt = cntnt.replaceAll('#Price#', ((dataList.SaleAmount -  dataList.LastDiscountAmount)/dataList.QTY).format());
                        System.debug( '(dataList.price).format() >>> ' + dataList.price.format());
                        if(dataList.SaleAmount!=null && dataList.LastDiscountAmount !=null){
                            cntnt = cntnt.replaceAll('#EachTotalPrice#',  String.valueOf((dataList.SaleAmount - dataList.LastDiscountAmount).format()));
                        }
                    }

                    System.debug('appointmentStatus =? ' + appointmentStatus);
                    if(appointmentStatus == '입고완료'){
                        cntnt = cntnt.replaceAll('#Memo#',  '' );
                    } else {
                        cntnt = cntnt.replaceAll('#Memo#',  '품절' );
                    }

                    cntntInvoice = cntntInvoice.replaceAll('<!--#Loop Start#-->', '<tr class="end"><td style="width:20px">#Month#</td><td style="width:20px">#Day#</td><td style="width:200px;">#ProductName#</td><td style="width:40px"></td><td style="width:60px">#QTY#</td><td style="width:120px">#Price#</td>' +
                            '<td style="width:80px">#EachTotalPrice#</td><td style="width:40px" colspan="2" class="end">#Memo#</td></tr> <!--#Loop Start#-->');
                    cntntInvoice = cntntInvoice.replaceAll('#Month#', todayMonth);
                    cntntInvoice = cntntInvoice.replaceAll('#Day#', todayDay);
                    cntntInvoice = cntntInvoice.replaceAll('#ProductName#',  dataList.ProductName );
                    cntntInvoice = cntntInvoice.replaceAll('#QTY#',  String.valueOf(dataList.QTY) );
                    if(dataList.discountType!=null && dataList.discountType=='E'){
                        System.debug(' dataList.ASCPrice.format()' +  dataList.ASCPrice.format());
                        cntntInvoice = cntntInvoice.replaceAll('#Price#',  dataList.ASCPrice.format() );
                        cntntInvoice = cntntInvoice.replaceAll('#EachTotalPrice#',  String.valueOf((dataList.SaleAmount -  dataList.LastDiscountAmount).format()));
                        if(dataList.SaleAmount!=null && dataList.LastDiscountAmount!=null){
                            totalSum += dataList.SaleAmount -  dataList.LastDiscountAmount;
                        }
                    } else {
                        cntntInvoice = cntntInvoice.replaceAll('#Price#',   ((dataList.SaleAmount -  dataList.LastDiscountAmount)/dataList.QTY).format() );
                        System.debug( '(dataList.price).format() >>> ' + dataList.price.format());
                        if(dataList.SaleAmount!=null && dataList.LastDiscountAmount!=null){
                            cntntInvoice = cntntInvoice.replaceAll('#EachTotalPrice#',  String.valueOf((dataList.SaleAmount -  dataList.LastDiscountAmount).format()));
                        }

                        if(dataList.SaleAmount!=null && dataList.LastDiscountAmount!=null){
                            totalSum += dataList.SaleAmount -  dataList.LastDiscountAmount;
                        }
                    }
                    cntntInvoice = cntntInvoice.replaceAll('#Memo#',  '' );

                    totalCount += dataList.QTY;
                }
            }
        
            // System.debug('속도측정 -------------------------------------------------- EX_DocPreviewController.paramMap.get(\'IsPrint\') -' + paramMap.get('IsPrint') + ' (end):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
            if(paramMap.get('IsPrint') == true ) {
                for (EX_SuppliesController.ItemTable dataList : soldOutOrderDataList) {
                    count++;
                    cntnt = cntnt.replaceAll('<!--#Loop Start#-->', ' <tr><td>#SEQ#</td><td>#ProductCode#</td><td>#ProductName#</td><td>#QTY#</td>' +
                            '<td style="text-align: right;">#Price#&nbsp;</td><td style="text-align: right;">#EachTotalPrice#&nbsp;</td><td>#Memo#</td></tr> <!--#Loop Start#-->');
                    cntnt = cntnt.replaceAll('#SEQ#', String.valueOf(count));
                    cntnt = cntnt.replaceAll('#ProductCode#', dataList.ProductCode);
                    cntnt = cntnt.replaceAll('#ProductName#', dataList.ProductName);
                    cntnt = cntnt.replaceAll('#QTY#', String.valueOf(dataList.QTY));
                    // cntnt = cntnt.replaceAll('#Price#', String.valueOf(dataList.price.format()));
                    if(dataList.discountType!=null && dataList.discountType=='E'){
                        System.debug(' dataList.ASCPrice.format()' +  dataList.ASCPrice.format());
                        // cntnt = cntnt.replaceAll('#Price#',   (dataList.price-dataList.ASCPrice).format() );
                        cntnt = cntnt.replaceAll('#Price#',   dataList.ASCPrice.format() );
                        // cntnt = cntnt.replaceAll('#EachTotalPrice#',  String.valueOf((dataList.QTY * dataList.ASCPrice).format()));
                        cntnt = cntnt.replaceAll('#EachTotalPrice#',  String.valueOf((dataList.SaleAmount - dataList.LastDiscountAmount).format()));
                        // totalSum += dataList.QTY * dataList.ASCPrice;
                        totalSum += (dataList.SaleAmount - dataList.LastDiscountAmount);
                    } else {
                        cntnt = cntnt.replaceAll('#Price#',  ((dataList.SaleAmount -  dataList.LastDiscountAmount)/dataList.QTY).format() );
                        System.debug( '(dataList.price).format() >>> ' + dataList.price.format());
                        // cntnt = cntnt.replaceAll('#EachTotalPrice#',  String.valueOf((dataList.QTY * dataList.price).format()));
                        cntnt = cntnt.replaceAll('#EachTotalPrice#',  String.valueOf((dataList.SaleAmount - dataList.LastDiscountAmount).format()));
                        // totalSum += dataList.QTY * dataList.price;
                        totalSum += (dataList.SaleAmount - dataList.LastDiscountAmount);
                    }
                    // cntnt = cntnt.replaceAll('#EachTotalPrice#', String.valueOf((dataList.QTY * dataList.price).format()));

                    //23.08.28 PHJ
                    // cntnt = cntnt.replaceAll('#Memo#',  '' );
                    // cntnt = cntnt.replaceAll('#Memo#',  dataList.Note );
                    // PHJ
                    System.debug('appointmentStatus =? ' + appointmentStatus);
                    if(appointmentStatus == '입고완료'){
                        cntnt = cntnt.replaceAll('#Memo#',  '' );
                    } else {
                        cntnt = cntnt.replaceAll('#Memo#',  '품절' );
                    }

                    // totalSum += dataList.QTY * dataList.price;
                    totalCount += dataList.QTY;
                    cntntInvoice = cntntInvoice.replaceAll('<!--#Loop Start#-->', ' <tr class="end"><td style="width:20px">#Month#</td><td style="width:20px">#Day#</td><td style="width:200px";>#ProductName#</td><td style="width:40px"></td><td style="width:60px">#QTY#</td>' +
                            '<td style="width:120px">#Price#</td><td style="width:80px">#EachTotalPrice#</td><td class="end" style="width:40px" colspan="2">#Memo#</td></tr> <!--#Loop Start#-->');
                    cntntInvoice = cntntInvoice.replaceAll('#Month#', todayMonth);
                    cntntInvoice = cntntInvoice.replaceAll('#Day#', todayDay);
                    cntntInvoice = cntntInvoice.replaceAll('#ProductName#', dataList.ProductName);
                    cntntInvoice = cntntInvoice.replaceAll('#QTY#', String.valueOf(dataList.QTY));
                    cntntInvoice = cntntInvoice.replaceAll('#Price#', String.valueOf(((dataList.SaleAmount -  dataList.LastDiscountAmount)/dataList.QTY).format()));
                    //cntntInvoice = cntntInvoice.replaceAll('#EachTotalPrice#', String.valueOf((dataList.QTY * dataList.price).format()));
                    cntntInvoice = cntntInvoice.replaceAll('#EachTotalPrice#', String.valueOf((dataList.SaleAmount -  dataList.LastDiscountAmount).format()));
                    cntntInvoice = cntntInvoice.replaceAll('#Memo#', '');
                }
            }
        
            // System.debug('속도측정 -------------------------------------------------- EX_DocPreviewController.paramMap.get(\'IsPrint\') (end):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
        
            for(; count<9; count++){
                cntnt = cntnt.replaceAll('<!--#Loop Start#-->', ' <tr><td>#SEQ#</td><td>#ProductCode#</td><td>#ProductName#</td><td>#QTY#</td>' +
                        '<td style="text-align: right;">#Price#&nbsp;</td><td style="text-align: right;">#EachTotalPrice#&nbsp;</td><td>#Memo#</td></tr> <!--#Loop Start#-->');
                cntnt = cntnt.replaceAll('#SEQ#', '');
                cntnt = cntnt.replaceAll('#ProductCode#','');
                cntnt = cntnt.replaceAll('#ProductName#', '');
                cntnt = cntnt.replaceAll('#QTY#',  '');
                cntnt = cntnt.replaceAll('#Price#','' );
                cntnt = cntnt.replaceAll('#EachTotalPrice#',  '');
                cntnt = cntnt.replaceAll('#Memo#',  ' ' );

                cntntInvoice = cntntInvoice.replaceAll('<!--#Loop Start#-->', ' <tr><td style="width:20px">#Month#</td><td style="width:20px">#Day#</td><td style="width:200px";>#ProductName#</td><td style="width:40px"></td><td style="width:60px">#QTY#</td>' +
                        '<td style="width:120px">#Price#</td><td style="width:80px">#EachTotalPrice#</td><td  class="end" style="width:40px" colspan="2">#Memo#</td></tr> <!--#Loop Start#-->');
                cntntInvoice = cntntInvoice.replaceAll('#Month#', '');
                cntntInvoice = cntntInvoice.replaceAll('#Day#', '');
                cntntInvoice = cntntInvoice.replaceAll('#ProductName#',  '' );
                cntntInvoice = cntntInvoice.replaceAll('#QTY#',  '');
                cntntInvoice = cntntInvoice.replaceAll('#Price#','');
                cntntInvoice = cntntInvoice.replaceAll('#EachTotalPrice#',  '');
                cntntInvoice = cntntInvoice.replaceAll('#Memo#',  '' );
            }

            cntnt = cntnt.replaceAll('#TotalPrice#', String.valueOf(totalSum.format()));
            cntnt = cntnt.replaceAll('#TotalAmount#', String.valueOf(totalCount));
            cntntInvoice = cntntInvoice.replaceAll('#TotalPrice#', String.valueOf(totalSum.format()));
            cntnt = cntnt.replaceAll('#RCVRNAME#', RCVRName);
            cntntInvoice = cntntInvoice.replaceAll('#RCVRNAME#', RCVRName);
            cntntInvoice = cntntInvoice.replaceAll('#RCVRPHONE#', RCVRPhone);
            //23 09 02 hyungho.chun 주소 받는 방법 변경(화면에서 받아옴)
            System.debug('contactAddress : '+contactAddress);
            RCVRAddr = contactAddress;
            System.debug('RCVRAddr : '+RCVRAddr);
            cntntInvoice = cntntInvoice.replaceAll('#RCVRADDR#', RCVRAddr);

            System.debug('#RCVRNAME# > '+ RCVRNAME);
            System.debug('#RCVRADDR# > '+ RCVRAddr);
            System.debug('#RCVRPHONE# > '+ RCVRPHONE);
            if(count>1){
                cntntInvoice = cntntInvoice.replaceAll('#EachTotalPrice#',  '');
            }


            cntnt = cntnt.replaceAll('#Date#', todaysDateStr);
            cntntInvoice = cntntInvoice.replaceAll('#Date#', todaysDateStr);
            cntnt = cntnt.replaceAll('#Note#', Note);

            if(Note!= null && !Note.equals('')){
                cntntInvoice = cntntInvoice.replaceAll('#Note#', Note);
            }
            String  strOrgName = 'Prd';
            String  strMyHost = System.Url.getSalesforceBaseUrl().getHost();
            //Virsualforce Url에 --c 문자가 들어가는 문제로 Replace 처리함.
            strMyHost = strMyHost.replace('--c', '');
            Integer nStartIndex = strMyHost.indexOf('--') + 2;
            if(nStartIndex != 1){   // because if prod then -1 is returned, 
                Integer nEndIndex = strMyHost.indexOf('.');
                // strOrgName = strMyHost.mid(nStartIndex, nEndIndex - nStartIndex);
            }
            System.debug( 'strOrgName::::' + strOrgName);
            String strIfConfigName = 'ConsumableCommon' + '_'+ strOrgName;
            System.debug( 'strIfConfigName::::' + strIfConfigName);
            
            // Set<Id> recordId = new Set<Id>();
        
            for (ContentDocument aa : [Select Id, Title FROM ContentDocument WHERE ParentId in (SELECT Id from ContentWorkspace Where DeveloperName = :strIfConfigName)]) {
            //2023.09.04 seung yoon heo 관련 파일 가져오기 변경
            // for (ContentDocument aa : [SELECT id, title FROM ContentDocument WHERE title IN ('사업자등록증' , '통장 사본', 'LG전자 마크', 'LG 마크')]) {
                // recordId.add(aa.LatestPublishedVersionId);
                imgMap.put(aa.Title, aa.Id);
            }
        
            // System.debug('속도측정 -------------------------------------------------- EX_DocPreviewController.ContentDocument query (end):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));

            String markImg1 = '<div style="  width: 105px; height: 50px;  position: absolute; float: left;">';
            markImg1 +='<img src="/sfc/servlet.shepherd/document/download/'+imgMap.get('LG전자 마크')+'" style="position:absolute;width:170%;height:120%"/></div>';

            String markImg2 = '';
            // markImg2 +='<img src="/sfc/servlet.shepherd/document/download/'+imgMap.get('LG 마크')+' " style="width:4%;height:4%"/>';
            markImg2 +='<img src="/sfc/servlet.shepherd/document/download/'+imgMap.get('LG 마크')+' " style="width:40%;"/>';

            cntnt = cntnt.replaceAll('#MARK1#',markImg1);
            cntnt = cntnt.replaceAll('#MARK2#',markImg2);

            //23.09.12 PHJ
            String korP = convertNumberToHangul(String.valueOf(totalSum.format()).replace(',',''));
            System.debug('Price <<<<<'+korP);

            cntnt = cntnt.replaceAll('#PriceKor#', korP);
            // cntnt = cntnt.replaceAll('#PriceKor#', '');

        String stdOrderNumber ='';
        String soldOutOrderNumber='';
        if(stdConsumableOrderId!=null){
            stdOrderNumber = [SELECT Order_Number__c FROM ProductRequest WHERE Id=:stdConsumableOrderId].Order_Number__c;
        }
        if(paramMap.get('IsPrint') == true){
            soldOutOrderNumber = [SELECT Order_Number__c FROM ProductRequest WHERE Id=:soldOutConsumableOrderId].Order_Number__c;
        }
        
        // System.debug('속도측정 -------------------------------------------------- EX_DocPreviewController.soldOutOrderNumber-' + soldOutOrderNumber + ' (end):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
        
        List<String> optionList = new List<String>();
        if(value !=null){
            optionList =(List<String>)JSON.deserialize(value,List<String>.class);
        }

        Integer cnt;
        String orderNumber = stdOrderNumber != '' ? stdOrderNumber : soldOutOrderNumber;
        String productRequestId = (Boolean)paramMap.get('isManagement') ? (Id)paramMap.get('parentId') :
                String.isNotBlank(stdConsumableOrderId) ? stdConsumableOrderId : String.isNotBlank(soldOutConsumableOrderId) ? soldOutConsumableOrderId : null;
        if(String.isNotBlank(productRequestId)){
            cnt = Database.countQuery('SELECT COUNT() FROM SR_ONLINE_SALE_ESTIMATE__c WHERE Order_Number__c = :orderNumber');
        }
        
        // System.debug('속도측정 -------------------------------------------------- EX_DocPreviewController.cnt-' + cnt + ' (end):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));

        List<SR_ONLINE_SALE_ESTIMATE__c> quoteList = new List<SR_ONLINE_SALE_ESTIMATE__c>();
        SR_ONLINE_SALE_ESTIMATE__c quoteHistory = new SR_ONLINE_SALE_ESTIMATE__c();
        
        quoteHistory.QuoteNum__c = cnt != null ? ++cnt : 1;
        // if(quoteHistory.QuoteNum__c==null){
        //     quoteHistory.QuoteNum__c=0;
        // }
        // quoteHistory.QuoteNum__c = ++quoteHistory.QuoteNum__c;
        quoteHistory.Quote_YN__c = 'N';
        quoteHistory.Business_Registration_YN__c = 'N';
        quoteHistory.Invoice_YN__c = 'N';
        quoteHistory.BankBookCopy_YN__c = 'N';
        quoteHistory.Send_YN__c = 'N';

        if(optionList.contains('견적서') || value == null)
            quoteHistory.Quote_YN__c = 'Y';
        if(optionList.contains('명세서') || value == null)
            quoteHistory.Invoice_YN__c = 'Y';
        if(optionList.contains('사업자등록증'))
            quoteHistory.Business_Registration_YN__c = 'Y';
        if(optionList.contains('통장사본'))
            quoteHistory.BankBookCopy_YN__c = 'Y';

        quoteHistory.RCVR_Name__c = RCVRName;
        quoteHistory.RCVR_Email__c = RCVREmail;
        quoteHistory.Quote_Memo__c = Note;
        quoteHistory.Order_User__c = conId;
        quoteHistory.Quote__c=cntnt;
        quoteHistory.Business_Registration__c='<img src="/sfc/servlet.shepherd/document/download/'+imgMap.get('사업자등록증')+'" style="position:absolute;width:92%;height:95%"/></div>';
        quoteHistory.BankBookCopy__c='<img src="/sfc/servlet.shepherd/document/download/'+imgMap.get('통장 사본')+'" style="position:absolute;width:92%;height:90%"/></div>';
        quoteHistory.Invoice__c = cntntInvoice;
        
        if((Boolean)paramMap.get('isManagement')){
            quoteHistory.OrderNumber__c = (String) paramMap.get('orderNumber');
            quoteHistory.Order_Number__c =  (Id)paramMap.get('parentId');
        }else{
            quoteHistory.OrderNumber__c = stdOrderNumber != '' ? stdOrderNumber : soldOutOrderNumber;
            quoteHistory.Order_Number__c =String.isNotBlank(stdConsumableOrderId) ? stdConsumableOrderId : String.isNotBlank(soldOutConsumableOrderId) ? soldOutConsumableOrderId : null;
        }

        quoteList.add(quoteHistory);

        // System.debug('생성 리스트 : ' + stdOrderNumber + ' ' + soldOutOrderNumber);
        insert quoteList;
        
        // System.debug('속도측정 -------------------------------------------------- EX_DocPreviewController.insert quoteList (end):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
        
        //23.04.29 추가
        System.debug('quoteList[0].id'+quoteList[0].id);
        System.debug(' (Id)paramMap.get(\'parentId\') ' +  (Id)paramMap.get('parentId'));

        returnMap.put('orderNo',(Boolean)paramMap.get('isManagement') ? (Id)paramMap.get('parentId') :  String.isNotBlank(stdConsumableOrderId) ? stdConsumableOrderId : String.isNotBlank(soldOutConsumableOrderId) ? soldOutConsumableOrderId : null);
        returnMap.put('quoteId',quoteList[0].Id);
        System.debug('getTemplate 의 returnMap :: ' + returnMap);
        // System.debug('속도측정 -------------------------------------------------- EX_DocPreviewController.getTemplate (end):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
        return returnMap;
    }

    @AuraEnabled
    public static SR_ONLINE_SALE_ESTIMATE__c getQuoteHistory(String orderNumber, String quoteHistoryId){
        // System.debug('속도측정 -------------------------------------------------- EX_DocPreviewController.getQuoteHistory (start):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
        
        System.debug('order : ' +orderNumber);
        System.debug('quoteHistoryId :: ' + quoteHistoryId);
        List<SR_ONLINE_SALE_ESTIMATE__c> quote = new List<SR_ONLINE_SALE_ESTIMATE__c>();
        String strQuery = '';
        strQuery += ' SELECT Id, RCVR_Name__c,RCVR_Email__c,Quote_Memo__c, OrderNumber__c,Quote__c,Business_Registration__c,BankBookCopy__c,Invoice__c ';
        strQuery += ' FROM SR_ONLINE_SALE_ESTIMATE__c ';

        if( quoteHistoryId!=null && !quoteHistoryId.equals('')){
            strQuery +=  ' WHERE Id = \'' + quoteHistoryId + '\'';
        }
        strQuery += ' ORDER BY CreatedDate DESC LIMIT 1';

        System.debug('견적이력 slect했을대 PDF 보기 했을때 쿼리' + strQuery);
        quote = Database.query(strQuery);
        
        // System.debug('속도측정 -------------------------------------------------- EX_DocPreviewController.getQuoteHistory (end):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
        return quote[0];
    }

    @AuraEnabled
    public static List<String> saveQuote(Map<String, Object> paramMap){
        System.debug('Ex_DocPreviewController');
        System.debug('paramMap 내용 확인 : ' + paramMap);

        String recordId = (String)paramMap.get('recordId');
        // String RCVRName = (String)paramMap.get('RCVRName');
        // List<String> selectedRow =  (List<String>) paramMap.get('listSelectRows');
        // String RCVREmail = (String)paramMap.get('RCVREmail');

        //견적서 PDF 저장
        List<String> docId = new List<String>();

        PageReference vfPDF = new PageReference('/apex/EX_SuppliesPDF?Id=quote&contactId=' + recordId + '&orderNumber=' + (String)paramMap.get('orderNumber'));

        vfPDF = new PageReference('/apex/EX_SuppliesPDF?Id=quote&contactId=' + recordId + '&orderNumber=' + (String)paramMap.get('orderNumber')+'&FileExtension=pdf');
        // vfPDF = new PageReference('/apex/EX_SuppliesPDF?Id=quote&contactId=' + recordId + '&orderNumber=' + (String)paramMap.get('orderNumber'));

        Blob pdfCntnt = Test.isRunningTest() ? Blob.valueOf('test') : vfPDF.getContentAsPDF();
        
        ContentVersion cVersion = new ContentVersion();
        cVersion.ContentLocation = 'S';
        cVersion.PathOnClient = 'Supplies-' + System.now() + '.pdf';
        cVersion.Origin = 'H';
        cVersion.Title = 'Supplies-' + System.now();
        // cVersion.PathOnClient = 'pdf';                    
                
        cVersion.VersionData = pdfCntnt;
        TriggerHandler.bypass('ContentVersion_trHandler');
        TriggerHandler.bypass('ContentDocument_trHandler');
        Insert cVersion;
        TriggerHandler.clearBypass('ContentVersion_trHandler');
        TriggerHandler.clearBypass('ContentDocument_trHandler');
                
        Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cVersion.Id].ContentDocumentId;

        ContentDocumentLink cDocLink = new ContentDocumentLink();
        cDocLink.ContentDocumentId = conDocument;
        cDocLink.LinkedEntityId = recordId;
        cDocLink.ShareType = 'I';
        cDocLink.Visibility = 'AllUsers';
        Insert cDocLink;
        docId.add(cDocLink.ContentDocumentId);
        PageReference vfInvoicePDF = new PageReference('/apex/EX_SuppliesPDF?Id=invoice&contactId=' + recordId + '&orderNumber=' + (String)paramMap.get('orderNumber'));
        //명세서 PDF 저장 품절도 분리해야될수도있음

        vfInvoicePDF = new PageReference('/apex/EX_SuppliesPDF?Id=invoice&contactId=' + recordId + '&orderNumber=' + (String)paramMap.get('orderNumber'));

        Blob pdfInvoiceCntnt = Test.isRunningTest() ? Blob.valueOf('test') : vfInvoicePDF.getContentAsPDF();

        ContentVersion cInvoiceVersion = new ContentVersion();
        cInvoiceVersion.ContentLocation = 'S';
        cInvoiceVersion.PathOnClient = 'SuppliesInvoice-' + System.now() + '.pdf';
        cInvoiceVersion.Origin = 'H';
        cInvoiceVersion.Title = 'SuppliesInvoice-' + System.now();
        //cVersion.PathOnClient = 'pdf';

        cInvoiceVersion.VersionData = pdfInvoiceCntnt;
        TriggerHandler.bypass('ContentVersion_trHandler');
        TriggerHandler.bypass('ContentDocument_trHandler');
        Insert cInvoiceVersion;
        TriggerHandler.clearBypass('ContentVersion_trHandler');
        TriggerHandler.clearBypass('ContentDocument_trHandler');
        Id conInvoiceDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cInvoiceVersion.Id].ContentDocumentId;

        ContentDocumentLink cInvoiceDocLink = new ContentDocumentLink();
        cInvoiceDocLink.ContentDocumentId = conInvoiceDocument;
        cInvoiceDocLink.LinkedEntityId = recordId;
        cInvoiceDocLink.ShareType = 'I';
        cInvoiceDocLink.Visibility = 'AllUsers';
        Insert cInvoiceDocLink;
        docId.add(cInvoiceDocLink.ContentDocumentId);

        //getTemplate으로 생성된 견적서이 DocumentId를 업데이트
        String quoteId = (String)paramMap.get('quoteId');
        
        List<SR_ONLINE_SALE_ESTIMATE__c> quotes = new List<SR_ONLINE_SALE_ESTIMATE__c>([
                SELECT Id, DocumentID__c
                FROM   SR_ONLINE_SALE_ESTIMATE__c
                WHERE  Id = :quoteId
        ]);

        if(cDocLink.ContentDocumentId!=null){
            quotes[0].DocumentID__c = cDocLink.ContentDocumentId;
        }
        if(cInvoiceDocLink.ContentDocumentId!=null){
            quotes[0].InvoiceId__c = cInvoiceDocLink.ContentDocumentId;
        }
        if(!quotes.isEmpty()){
            update quotes;
        }

        System.debug('Ex_DocPreviewController 끝');
        return  docId;
    }

    @AuraEnabled
    public static Boolean cancelQuote( String orderNumber){
        // List<SR_ONLINE_SALE_ESTIMATE__c> quoteHistory = [SELECT RCVR_Name__c,OrderNumber__c FROM SR_ONLINE_SALE_ESTIMATE__c WHERE (OrderNumber__c=:orderNumber AND  OrderNumber__c !=NULL)];
        List<SR_ONLINE_SALE_ESTIMATE__c> quoteHistory = [ SELECT   RCVR_Name__c, OrderNumber__c
                                                            FROM     SR_ONLINE_SALE_ESTIMATE__c
                                                            WHERE    (OrderNumber__c =: orderNumber AND OrderNumber__c != NULL)
                                                            ORDER BY CreatedDate DESC
                                                            LIMIT    1 ];
        if(quoteHistory.size()>0){
            System.debug('삭제됨' +quoteHistory );
            delete quoteHistory;
            return true;
        }

        System.debug('삭제됨' +quoteHistory );
        return false;
    }

    @AuraEnabled
    public static Contact getContactInfo(String contactId){
        Contact contactInfo = [SELECT Name,Email FROM Contact WHERE Id =:contactId];

        if(contactInfo == null){
            return null;
        }

        return contactInfo;
    }

    //23.09.13 PHJ 
    public static String convertNumberToHangul(String korP) {
        String[] han1 = new String[] { '', '일', '이', '삼', '사', '오', '육', '칠', '팔', '구' };
        String[] han2 = new String[] { '', '십', '백', '천' };
        String[] han3 = new String[] { '', '만', '억', '조', '경' };
        String result = '';
        Integer len = korP.length();
        Integer nowInt = 0;
        Boolean hasHan3 = false;
        
        for (Integer i = len; i > 0; i--) {
            nowInt = Integer.valueOf(korP.substring(len - i, len - i + 1));
            Integer han2Pick = Math.mod(i - 1, 4);
            
            if (nowInt > 0) {
                result += han1[nowInt] + han2[han2Pick];
                if (han2Pick > 0) {
                    hasHan3 = false;
                }
            }
            
            if (!hasHan3 && han2Pick == 0) {
                result += han3[(i - 1) / 4];
                hasHan3 = true;
            }
        }
        
        String res = (String) result;
        return res;
    }
}