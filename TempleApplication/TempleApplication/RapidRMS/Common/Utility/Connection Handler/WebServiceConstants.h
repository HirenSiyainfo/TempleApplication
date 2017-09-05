//
//  WebServiceConstants.h
//  RapidRMS
//
//  Created by Siya Infotech on 02/12/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//


//// IMPORTANT /////
/**
 USE_LOCAL_SERVICE - Define this macro to use local server for testing. Comment it to use live url.
 */
//#define USE_LOCAL_SERVICE

/**
 Following block is meant to safeguard accidental includsion of USE_LOCAL_SERVICE in release build. Following block makes sure that release builds use live url.
 */


// RAPID URL SCHEMES
#define RAPID_URL_SCHEME_LIVE       1
#define RAPID_URL_SCHEME_STAGING    2
#define RAPID_URL_SCHEME_LOCAL      3

//----------------------------------------------------\\
// SELECT ANY ONE OF BELOW

// 1) LIVE
 #define RAPID_URL_SCHEME RAPID_URL_SCHEME_LIVE

// 2) STAGING
// #define RAPID_URL_SCHEME RAPID_URL_SCHEME_STAGING

// 3) LOCAL
// #define RAPID_URL_SCHEME RAPID_URL_SCHEME_LOCAL


// NOTA IS NOT ALLOWED
#ifndef RAPID_URL_SCHEME
    #define RAPID_URL_SCHEME RAPID_URL_SCHEME_LOCAL
#endif
//----------------------------------------------------//


// Safe Guard
#ifndef DEBUG
    // Local URL scheme not allowed while making archive
    #if RAPID_URL_SCHEME == RAPID_URL_SCHEME_LOCAL
        // RAPID_URL_SCHEME == RAPID_URL_SCHEME_LOCAL is not allowed for Release builds.
        #undef RAPID_URL_SCHEME
        #define RAPID_URL_SCHEME RAPID_URL_SCHEME_LIVE

    // Staging is allowed for archives
    #elif RAPID_URL_SCHEME == RAPID_URL_SCHEME_STAGING
        #warning "WARNING: RAPID_URL_SCHEME_STAGING defined.\n Use RAPID_URL_SCHEME_LIVE for iTunes builds."
    #endif

#endif




//// IMPORTANT /////
#if RAPID_URL_SCHEME == RAPID_URL_SCHEME_LIVE
    #define RAPID_SERVER_NAME           @"www.rapidrms.com"
    #define RAPID_SERVER_PORT           @""
    #define RAPID_SERVICE_PREFIX        @"/"
    #define RAPID_URL_SCHEME_LABEL_TEXT @""

#elif RAPID_URL_SCHEME == RAPID_URL_SCHEME_STAGING
    #define RAPID_SERVER_NAME           @"rapidrmseast-rapidrmsmodulewise.azurewebsites.net"
    //#define RAPID_SERVER_NAME           @"rapidrmseast-report.azurewebsites.net"

    #define RAPID_SERVER_PORT           @""
    #define RAPID_SERVICE_PREFIX        @"/"
    #define RAPID_URL_SCHEME_LABEL_TEXT @"STAGING - " RAPID_SERVER_NAME

#elif RAPID_URL_SCHEME == RAPID_URL_SCHEME_LOCAL
    #define RAPID_SERVER_NAME           @"192.168.0.100"
    #define RAPID_SERVER_PORT           @""
    #define RAPID_SERVICE_PREFIX        @"/Rapidrms/"
    #define RAPID_URL_SCHEME_LABEL_TEXT @"LOCAL - " RAPID_SERVER_NAME

#endif


// Enable following macro for HTTPS. Comment it for HTTP
#define ENABLE_SECURE_SERVICE
#ifdef ENABLE_SECURE_SERVICE
    #define RAPID_SERVICE_PROTOCOL @"https://"
#else
    #define RAPID_SERVICE_PROTOCOL @"http://"
#endif



#define RMS_SERVICE_URL RAPID_SERVICE_PROTOCOL RAPID_SERVER_NAME RAPID_SERVER_PORT RAPID_SERVICE_PREFIX

#define RAPID_SERVICE_PATH          @"WcfService/Service.svc/"
#define RAPID_INVOICE_SERVICE_PATH  @"WcfService/InvoiceService.svc/"
#define RAPID_PAYMENT_SERVICE_PATH  @"WcfService/Payment.svc/"

#define KURL RMS_SERVICE_URL RAPID_SERVICE_PATH

#define KURL_INVOICE RMS_SERVICE_URL RAPID_INVOICE_SERVICE_PATH

#define KURL_PAYMENT RMS_SERVICE_URL RAPID_PAYMENT_SERVICE_PATH


// Get Receipt Master
#define WSM_GET_RECEIPT_MASTER @"GetReceiptMaster12082016"  //GetReceiptMaster

// For Phase1
#define WSM_PHASE_1 @"GetItemList"
#define WSM_PHASE_1_RESPONSEKEY @"GetItemListResult"

// For Phase2
#define WSM_PHASE_2 @"GetItemDetailList"
#define WSM_PHASE_2_RESPONSEKEY @"GetItemDetailListResult"

// For Phase3
#define WSM_PHASE_3 @"GetItemVariationList"
#define WSM_PHASE_3_RESPONSEKEY @"GetItemVariationListResult"

// For Phase4
#define WSM_PHASE_4 @"GetItemSupplierHackneyData"
#define WSM_PHASE_4_RESPONSEKEY @"GetItemSupplierHackneyDataResult"

// For ItemList
#define WSM_ITEM_LIST @"ItemRetailRestlist09302015"
#define WSM_ITEM_LIST_RESPONSEKEY @"ItemRetailRestlist09302015Result"
// For UpdateItemList
#define WSM_ITEM_UPDATE_LIST @"UpdatedItemRetailRestlist"
#define WSM_ITEM_UPDATE_LIST_RESPONSEKEY @"UpdatedItemRetailRestlistResult"

// For UpdatePumpCartList
#define WSM_ITEM_PETRO_UPDATE_LIST @"UpdatedPumpRetailRestlist"

//// ForMaster List
//#define WSM_MASTER_LIST @"Masterlist12042014"
//#define WSM_MASTER_LIST_RESPONSEKEY @"Masterlist12042014Result"

// ForMaster List New
#define WSM_MASTER_LIST @"Masterlist19032014"
#define WSM_MASTER_LIST_RESPONSEKEY @"Masterlist19032014Result"


// ForMaster Update List
#define WSM_MASTER_UPDATE_LIST @"UpdatedMasterlist12042014"
#define WSM_MASTER_UPDATE_LIST_RESPONSEKEY @"UpdatedMasterlist12042014Result"

//#define WSM_INVOICE_INSERT_LIST @"AddInvoiceRest12032014"
//#define WSM_INVOICE_INSERT_LIST_RESPONSEKEY @"AddInvoiceRest12032014Result"

#ifdef DEBUG
#define WSM_INVOICE_INSERT_LIST @"AddInvoiceRest30012017"  //@"AddInvoiceRest01232015" //@"AddInvoiceRest01232015Test" // @"AddInvoiceRest042612016" // @"AddInvoiceRest10012015"
#else
#define WSM_INVOICE_INSERT_LIST @"AddInvoiceRest30012017"  //@"AddInvoiceRest01232015"
#endif

#define WSM_INVOICE_INSERT_LIST_RESPONSEKEY @"AddInvoiceRest10012015Result"  //@"AddInvoiceRest01232015Result"   //@"AddInvoiceRest01232015Result"

#define WSM_INVOICE_DETAIL_LIST @"InvoiceItemRetailRestDetail"
#define WSM_INVOICE_DETAIL_LIST_RESPONSEKEY @"InvoiceItemRetailRestDetailResult"

#define WSM_ADD_HOLD_INVOICE_LIST @"AddHoldInvoiceRestDetail07212015" //@"AddHoldInvoiceRestDetail12182014"
#define WSM_ADD_HOLD_INVOICE_LIST_RESPONSEKEY @"AddHoldInvoiceRestDetail07212015Result" //@"AddHoldInvoiceRestDetail12182014Result"

#define WSM_RECALL_INVOICE_LIST @"RecallInvRestRetailListDetail07212015" // @"RecallInvRestRetailListDetail"
#define WSM_RECALL_INVOICE_LIST_RESPONSEKEY  @"RecallInvRestRetailListDetail07212015Result" //@"RecallInvRestRetailListDetailResult"

#define WSM_INVOICE_LIST @"InvoiceDetailPaging"
#define WSM_INVOICE_LIST_RESPONSEKEY @"InvoiceDetailPagingResult"

//#define WSM_INSERT_VOID_INVOICE @"InsertVoidInvoice"
#define WSM_INSERT_VOID_INVOICE @"InsertVoidInvoice04052017"

#define WSM_INVOICE_LIST_DATEWISE @"InvoiceDetailDatewisePaging"
#define WSM_INVOICE_LIST_DATEWISE_RESPONSEKEY @"InvoiceDetailDatewisePagingResult"

#define WSM_Z_REPORT @"ZReportDetail_28092016"
#define WSM_Z_REPORT_RESPONSEKEY @"ZReportDetail_12122014Result"

#define WSM_CHECK_TICKET_VALIDITY @"CheckTicketValidity"


//********* AboutViewController *********//
#define WSM_GET_NOTIFICATION_DETAIL @"GetNotificationDetail"

//********* ActiveAppsVC *********//
#define WSM_DEVICE_SETUP @"DeviceSetup"

//********* AddCustomerVC *********//
#define WSM_INSERT_CUSTOMER @"InsertCustomer"
#define WSM_UPDATE_CUSTOMER @"UpdateCustomer"

//********* AddDepartmentVC *********//
#define WSM_INSERT_DEPARTMENT @"InsertDepartment"
#define WSM_UPDATE_DEPARTMENT @"UpdateDepartment"
#define WSM_GET_ITEM_IMAGE_LIST_BY_NAME @"GetItemImageListByName"

//********* AddGroupItemModifierVC *********//
#define WSM_INSERT_MODIFIER_LIST @"InsertModifierList"
#define WSM_UPDATE_MODIFIER_LIST @"UpdateModifierList"
#define WSM_DELETE_MODIFIER_LIST @"DeleteModifierList"

//********* AddPaymentMasterVC *********//
#define WSM_INSERT_PAYMENT @"InsertPayment"
#define WSM_UPDATE_PAYMENT @"UpdatePayment"
#define WSM_DELETE_PAYMENT @"DeletePayment"

//********* AddGroupModifierVC *********//
#define WSM_INSERT_MODIFIER_GROUP @"InsertModifierGroup"
#define WSM_UPDATE_MODIFIER_GROUP @"UpdateModifierGroup"
#define WSM_DELETE_MODIFIER_GROUP @"DeleteModifierGroup"

//********* AddSalesRepresentativeVC *********//
#define WSM_INSERT_SUPPLIER @"InsertSupplier"

//********* AddSubDepartmentVC *********//
#define WSM_INSERT_SUB_DEPARTMENT @"InsertSubDepartment"
#define WSM_UPDATE_SUB_DEPARTMENT @"UpdateSubDepartment"
#define WSM_DELETE_SUB_DEPARTMENT @"DeleteSubDepartment"
#define WSM_DELETE_DEPARTMENT @"DeleteDepartment"

//********* AddVenderVC *********//
#define WSM_INSERT_SUPPLIER_COMPAPNY @"InsertSupplierCompany"

//********* BrdigePayPaymentGateway *********//
#define WSM_CREDIT_CARD_DECLINE_PROCESS @"CreditCardDeclineProcess"
#define WSM_BRIDGEPAY_MANUAL_CREDIT_CARD_PROCESS @"BridgepayManualCreditCardProcess_25Nov2015"
#define WSM_BRIDGEPAY_AUTO_CREDIT_CARD_PROCESS @"BridgepayAutoCreditCardProcess31102015"//@"BridgepayAutoCreditCardProcess"
#define WSM_RAPID_SERVER_TIP_ADJUSTMENT_PROCESS @"BridgepayAutoCreditCardProcessWithPNRef"

#define WSM_SUCESS_CREDITCARD_TRANSACTION @"SuccessCreditCardTransactions"

#define WSM_BRIDGE_VOID_INVOICE_PROCESS @"BridgepayVoidInvoiceProcess"
#define WSM_HOUSE_CHARGE_VOID_INVOICE_PROCESS @"HouseChargeVoidInvoiceProcess"

//********* CardProcessingVC *********//
#define WSM_CREDIT_CARD_REFUND_PROCESS @"CreditCardRefundProcess"
#define WSM_CREDIT_CARD_LOG @"CreditCardLog"

//********* CashinOutViewController *********//
#define WSM_ALL_EMPLOYEE_SHIFT_END @"AllEmployeeShiftEnd"
#define WSM_ADD_CASH_IN_OUT @"AddCashInOut"
#define WSM_EMPLOYEE_SHIFT_REPORT @"EmployeeShiftReport"

//********* CCbatchReportVC *********//
#define WSM_CC_BATCH_DATA @"CCbatchData"

//********* ClockInDetailsView *********//
#define WSM_CLOCK_IN_OUT @"ClockInOut"
#define WSM_CLOCK_IN_OUT_DETAIL @"ClockInOutDetail06052017"
#define WSM_CLOCK_IN_OUT_RESET @"ClockInOutReset"
#define WSM_CLOCK_IN_OUT_DATE_WISE @"ClockInOutDatewise06052017"
#define WSM_UPDATE_CLOCK_IN_OUT_DETAIL @"UpdateClockInOutTime"
#define WSM_VOID_UNVOID_CLOCK_IN_OUT_DETAIL @"VoidUnvoidClockInOutTime"

//********* CloseListViewController *********//
#define WSM_GET_CLOSE_ORDER_DETAIL_NEW @"GetCloseOrderDetailNew"
#define WSM_GET_OPEN_PURCHASE_OREDR_DATA_NEW @"GetOpenPurchaseOrderDataNew"
#define WSM_PO_ITEM_INFO @"POItemInfo10312014"

//********* CloseOrderViewController *********//
#define WSM_INVENTORY_CLOSE_LIST @"InventoryCloseList"
#define WSM_DELETE_INVENTORY_IN @"DeleteInventoryIn"
#define WSM_DELETE_INVENTORY_OUT @"DeleteInventoryOut"
#define WSM_INVENTORY_IN_OUT_DETAIL @"InventoryInOutDetail"

//********* CustomerViewController *********//
#define WSM_CUSTOMER_INFO @"CustomerInfo"
#define WSM_DELETE_CUSTOMER @"DeleteCustomer"
#define WSM_DETAIL_FOR_CUSTOMER @"DetailsForCustomer"
#define WSM_UPDATE_CREDIT_LIMIT @"UpdateCreditLimit"
#define WSM_CUSTOMER_CREDIT_LIMIT @"CustomerCreditLimit"



//********* DashBoardSettingVC *********//
#define WSM_LOGIN_AUTHENTICATION @"LoginAuthentication"
#define WSM_INSERT_BRACH_CONFIGURATION_SETTING @"InsertBranchConfigurationSetting"

//********* DeliveryListView *********//
#define WSM_GET_DELIVERY_ORDER_DATA_NEW @"GetDeliveryOrderDataNew"
#define WSM_GET_PENDING_DELIVERY_DATA_NEW @"getpendingdeliverydata" //getpendingdeliverydataNew
#define WSM_DELETE_OPEN_PO_NEW @"DeleteOpenPoNew"
#define WSM_UPDATE_STATUS_TO_CLOSE_PO_NEW @"UpdateStatusToClosePONew"

//********* DropAmountVC *********//
#define WSM_DROP_AMOUNT_ADD @"DropAmountAdd"
#define WSM_NO_SALE_INSERT @"NoSaleInsert"

//********* GenerateOrderView *********//
#define WSM_GENERATE_PURCHASE_ORDER_DEATIL_NEW @"GeneratePurchaseOrderDetailNew"
#define WSM_INSERT_PO_DETAIL_NEW @"InsertPoDetailNew"
#define WSM_UPDATE_PO_DETAIL_NEW @"UpdatePoDetailNew" //UpdatePoDetailNew
#define WSM_UPDATE_OPEN_PO_DETAIL_NEW @"UpdateOpenPoDetailNew"  // UpdateOpenPoDetailNew
#define WSM_PO_ITEM_INFO_NEW @"POItemInfo10312014"
#define WSM_GET_PURCHASE_BACK_ORDER_LIST @"GetPurchaseBackOrderList"

//********* Iphone Purchase Order New Service *********//
#define WSM_GENERATE_PURCHASE_ORDER_DEATIL_NEW_IPHONE @"GeneratePurchaseOrderDetail28102016"
#define WSM_INSERT_OPEN_PO_DETAIL_NEW_IPHONE @"InsertOpenPoDetail28102016"
#define WSM_GET_OPEN_PURCHASE_OREDR_DATA_NEW_IPHONE @"GetOpenPurchaseOrderData28102016"
#define WSM_GET_PURCHASE_ORDER_LISTING_DATA_IPHONE @"GetPurchaseOrderListingData28102016" //GetPurchaseOrderListingData
#define WSM_UPDATE_RECIEVE_PO_DETAIL_IPHONE @"UpdateRecievePoDetail28102016"
#define WSM_INSERT_RECIEVE_PO_DETAIL_IPHONE @"insertReceivePODetail28102016"
#define WSM_GET_PENDING_DELIVERY_DATA_NEW_IPHONE @"getpendingdeliverydata28102016" //getpendingdeliverydataNew

#define WSM_ADD_PURCHASE_BACK_ORDER_IPHONE @"AddPurchaseBackOrder28102016" //AddPurchaseBackOrder

#define WSM_INSERT_PO_DETAIL_NEW @"InsertPoDetailNew"
#define WSM_UPDATE_PO_DETAIL_NEW_IPHONE @"UpdatePoDetail28102016" //UpdatePoDetailNew
#define WSM_UPDATE_OPEN_PO_DETAIL_NEW_IPHONE @"UpdateOpenPoDetail28102016"  // UpdateOpenPoDetailNew
#define WSM_PO_ITEM_INFO_NEW @"POItemInfo10312014"
#define WSM_GET_PURCHASE_BACK_ORDER_LIST_IPHONE @"GetPurchaseBackOrderList28102016"


//********* HBackorderListVC *********//
#define WSM_GET_HACKNEY_BACK_ORDER_PO_ITEM @"GetHackneybackorderPOItem"

//********* HConfigurationVC *********//
#define WSM_VENDOR_CONFIGURATION @"vendorConfiguration"
#define WSM_GET_ITEM_SUPLIER_HACKNEY_DATA @"GetItemSupplierHackneyData"

//********* HistoryManualEntryVC *********//
#define WSM_RECONCILE_MANUAL_ENTRY_HISTORY_BYDATE @"ReconcileManualEntryHistoryBydate"
#define WSM_MANUAL_ENTRY_ITEM_DETAIL @"ManualEntryItemDetail"

//********* HItemProductVC *********//
#define WSM_LIST_HACKNEY_PO @"ListHackneyPO"
#define WSM_ADD_HACKNEY_PO_ITEM @"AddHackneyPOItem"

//********* HOpenOrderVC *********//
#define WSM_GET_HACKNEY_PO_ITEM @"GetHackneyPOItem"
#define WSM_DELETE_HACKNEY_PO @"DeleteHackneyPO"

//********* HPOItemListVC *********//
#define WSM_SENT_HACKNEY_PO @"SentHackneyPO"
#define WSM_DELETE_HACKNEY_PO_ITEM @"DeleteHackneyPOItem"

//********* HProductInfoVC *********//
#define WSM_GET_HACKNEY_PO_ITEM_HISTORY_LIST @"GetHackneyPOItem_HistoryList"

//********* HPurchaseOrderVC *********//
#define WSM_BACK_ORDER_HACKNEY_PO_ITEM @"BackOrderHackneyPOItem"

//********* HReceiveOrderItemInfo *********//
#define WSM_UPDATE_HACKNEY_PO_ITEM @"UpdateHackneyPOItem"

//********* HReceiveOrderItemListVC *********//
#define WSM_CLOSE_HACKNEY_PO @"CloseHackneyPO"

//********* ICHistorySessionListVC *********//
#define WSM_RECONCILE_SESSION_HISTORY @"ReconcileSessionHistory"

//********* ICJoinCountVC *********//
#define WSM_GET_OPEN_INVENTORY_COUNT_SESSION @"GetOpenInventoryCountSession"
#define WSM_DELETE_INVENTORY_COUNT_SESSION @"DeleteInventoryCountSession"
#define WSM_ADD_INVENTORY_COUNT_USER_SESSION @"AddInventoryCountUserSession"

//********* ICNewVC *********//
#define WSM_ADD_INVENTORY_COUNT_SESSION @"AddInventoryCountSession"

//********* ICQtyEditVC *********//
#define WSM_UPDATE_CASE_PACK_QTY @"UpdateCasePackQty"

//********* ICRecallSessionListVC *********//
#define WSM_INVENTORY_COUNT_USER_SESSION_LIST @"InventoryCountUserSessionsList"
#define WSM_DELETE_INVENTORY_USER_SESSION @"DeleteInventoryUserSession"
#define WSM_RECALL_USER_SESSION @"RecallUserSession"

//********* InventoryHome *********//
#define WSM_GET_TAGS @"GetTags"

//********* InventoryManagement *********//
#define WSM_ITEM_DELETED @"ItemDeleted"
#define WSM_INSERT_BARCODE_TO_ITEM_CODES @"InsertBarcodesToItemCodes05102015"
#define WSM_INSERT_IOS_ITEMS @"InsertIOSItems"
#define WSM_ITEM_TOTAL_INFO_IOS @"InventoryManagement"

//********* InventoryOutScannerView *********//
#define WSM_ADD_INVENTORY_OUT @"AddInventoryOut"
#define WSM_UPDATE_INVENTORY_OUT @"UpdateInventoryOut"

//********* InvoiceDetail *********//
#define WSM_VOID_TARNS_DETAILS @"VoidTransDetails"
#define WSM_INVOICE_DETAIL_BARCODE @"InvoiceDetailBarcode28042017"  //InvoiceDetailBarcode
#define WSM_TIP_ADJUSTMENT @"TipsAdjustment"
#define WSM_ADD_CUSTOMER_TO_INVOICE @"UpdateInvoiceCustomer"

#define WSM_INVOICE_OFFLINE_DATA @"InvoiceOfflineData"
#define WSM_ADD_INVOICE_TICKET_DETAILS @"AddInvTicketDetail"

//********* ItemCountListVC *********//
#define WSM_HOLD_USER_SESSION @"HoldUserSession"
#define WSM_DELETE_ITEM_INVENTORY_COUNT_DATA @"DeleteIemInventoryCountData"
#define WSM_ADD_ITEM_INVENTORY_COUNT_DATA @"AddItemInventoryCountData"
#define WSM_UPDATE_ITEM_INVENTORY_COUNT_DATA @"UpdateItemInventoryCountData"
#define WSM_CLOSE_INVENTORY_USER_SESSION @"CloseInventoryUserSession"

//********* ItemInfoEditVC *********//
#define WSM_INV_ITEM_UPDATE @"InvItemUpdate12202014"
#define WSM_INV_ITEM_UPDATE_PARCIAL @"InvItemUpdate10062015"
#define WSM_INV_ITEM_UPDATE_PARCIAL_RESULT @"InvItemUpdate10062015Result"

#define WSM_INV_ITEM_INSERT @"ItemInsert12202014"
#define WSM_UPDATE_TAG_LIST @"UpdateTagList"
#define WSM_ITEM_HISTORY_LIST @"ItemHistoryList09292014"
#define WSM_ITEM_REMOVE_FROM_MMD @"DeleteDiscountItem"
#define WSM_INVOICE_ITEM_HISTORY_LIST @"ItemHistoryList27092016"

//********* ItemReconcileListVC *********//
#define WSM_COMPLETED_RECONCILE_COUNT_DATA @"CompletedReconcileCountData"
#define WSM_RECONCILE_COUNT_DATA @"ReconcileCountData"
#define WSM_CLOSE_INV_COUNT_SESSION @"CloseInvCountSession"

//********* ManualEntryRecevieItemList *********//
#define WSM_HOLD_MANUAL_ENTRY @"HoldManualEntry"
#define WSM_RECONCILE_MANUAL_ENTRY @"ReconcileManualEntry21122015"//@"ReconcileManualEntry"
#define WSM_DELETE_MANUAL_ENTRY_ITEM @"DeleteManualEntryItem"
#define WSM_BARCODE_SEARCH_LOG @"SearchLog"


//********* ManualItemReceiveVC *********//
#define WSM_MANUAL_ENTRY_MAIN_ITEM_UPDATE @"ManualEntryMainItemUpdate"

//********* ModuleActiveAppsVC *********//
#define WSM_DEVICE_SETUP_NEW @"DeviceSetup01062015"
#define WSM_REPLACE_REGISTER @"ReplaceWithRegister"
#define WSM_RELEASE_REGISTER @"ReleaseRegister"

//********* NewManualEntryVC *********//
#define WSM_ADD_MANUAL_ENTRY @"AddManualEntry"

//********* NewOrderScannerView *********//
#define WSM_ADD_INVENTORY_IN @"AddInventoryIn"
#define WSM_UPDATE_INVENTORY_IN @"UpdateInventoryIn"

//********* NotificationViewController *********//
#define WSM_UPDATE_NOTIFICATION_DETAIL @"UpdateNotificationDetail"

//********* OpenListFilterViewController *********//
#define WSM_GET_PURCHASE_ORDER_LISTING_DATA @"GetPurchaseOrderListingData" //GetPurchaseOrderListingData
#define WSM_DELETE_OPEN_PO @"DeleteOpenPo"
#define WSM_UPDATE_RECIEVE_PO_DETAIL_ITEM @"UpdateRecievePoItemDetail28102016"
#define WSM_UPDATE_RECIEVE_PO_DETAIL_NEW @"UpdateRecievePoDetailNew"
#define WSM_INSERT_RECIEVE_PO_DETAIL_NEW @"insertReceivePODetailNew"
#define WSM_UPDATE_RECIEVE_PO_DETAIL @"UpdateRecievePoDetail"
#define WSM_INSERT_RECIEVE_PO_DETAIL @"insertReceivePODetail"

//********* OpenListViewController *********//
#define WSM_ADD_PURCHASE_BACK_ORDER @"AddPurchaseBackOrder" //AddPurchaseBackOrder

#define WSM_ADD_DELETE_RECEIVE_ITEM @"DeleteRecievePoItem" //DELETERECEIVEITEM

//********* OpenOrderViewController *********//
#define WSM_INVENTORY_OPEN_LIST @"InventoryOpenList"

// ******* PassInquiry *******//
#define WSM_GET_TICKET_ALL_DATA @"GetTicketAllData"


//********* POSLoginView *********//
#define WSM_RECALL_INVOICE_LIST_SERVICE @"RecallInvoiceList07212015"  ///@"RecallInvoiceList"
#define WSM_RECALL_INVOICE_LIST_SERVICERESULT @"RecallInvoiceList07212015Result"  ///@"RecallInvoiceListResult"

#define WSM_UPDATE_ITEM_BY_FAVOURITE @"UpdateItemByfavourite"  ///@"RecallInvoiceListResult"
#define WSM_UPDATE_ITEM_BY_FAVOURITERESULT @"UpdateItemByfavouriteResult"  ///@"RecallInvoiceListResult"

#define WSM_RECALL_INVOICE_DELETE @"RecallInvDelete"
#define WSM_CANCEL_INVOICE_TRANSCATION @"CancelInvoiceTransaction"

#define WSM_USER_SIGN_IN_PROCESS @"UserSignInProcess"
#define WSM_USER_PASSCODE_LOGIN @"UserPasscodeLogin"
#define WSM_Z_OPENING_DETAIL @"ZOpeningDetail"
#define WSM_ADD_VOID_INVOICE_TRANS @"AddVoidInvoiceTrans"

//********* PurchaseOrderFilterListDetail *********//
#define WSM_INSERT_OPEN_PO_DETAIL_NEW @"InsertOpenPoDetailNew" //InsertOpenPoDetailNew

//********* RcrController *********//
#define WSM_INVOICE_PUSH_NOTIFICATION_DATA @"InvoicePushNotificationData"
#define WSM_Z_CLOSING_DETAIL @"ZClosingDetail"

//********* RecallManualEntryVC *********//
#define WSM_HOLD_MANUAL_ENTERY_HISTORY @"HoldManualEntryHistory"
#define WSM_DELETE_MANUAL_ENTERY @"DeleteManualEntry"

//********* ReportViewController *********//
#define WSM_POS_USER_RIGHT @"POSUserRight"
#define WSM_X_REPORT_DETAIL @"XReportDetail_28092016"
#define WSM_X_REPORT_DETAIL_GAS @"XReportDetail_GAS"
#define WSM_EMPLOYEE_SHIFT_OPEN_CHECK @"EmployeeShiftOpenCheck"
#define WSM_ZZ_MANAGER_LIST_DATA @"ZZManagerListData"
#define WSM_Z_MANAGER_LIST_DATA @"ZManagerListData"
#define WSM_ZZ_MANAGER_LIST_DETAIL_RPT @"ZZManagerListDetailRpt28092016"
#define WSM_Z_MANAGER_LIST_DETAIL_RPT @"ZManagerListDetailRpt28092016"
#define WSM_ZZ_REPORT @"ZZReport28092016"

//********* RcrPosGasVC *********//
#define WSM_BRIDGEPAY_GAS_CREDIT_CARD_PROCESS @"BridgepayGasCreditCardProcess"

//********* RmsDbController *********//
#define WSM_DEVICE_CONFIGRATION @"DeviceConfigration03192015"
#define WSM_GET_CARD_TYPE_DETAIL @"GetCardTypeDetail"
#define WSM_USER_DETAILS @"UserDetails"
#define WSM_LIVE_UPDATE_ACKNOWLEDGEMENT @"LiveUpdateAcknowledgement"

//********* SettingView *********//
#define WSM_DEVICE_ADS_INFO @"DiviceAdsInfo"
#define WSM_PAYMENT_DETAIL @"PaymentDetail"

//********* ShiftOpenCloseVC *********//
#define WSM_SHIFT_OPEN_CURRENT_DETAIL @"ShiftOpenCurrentDetail02022017"
#define WSM_SHIFT_HISTORY_LIST @"ShifHistoryList1042016"
#define WSM_SHIFT_HISTORY_DETAIL @"ShiftHistoryDetail28092016"
#define WSM_SHIFT_CLOSE_DETAIL @"ShiftCloseDetail28092016"


//********* SupplierInventoryView *********//
#define WSM_ITEM_SEARCH_BY_SUPPLIER @"ItemSearchBySupplier"

//********* TenderViewController *********//
#define WSM_INSERT_MISSED_INVOICE_DETAIL @"InsertMissedInvoiceDetail"

//********* ViewController *********//
#define WSM_DEPARTMENT @"Department"

//********* XCCbatchReportVC *********//
#define WSM_GET_CARD_SETTLEMENT_DETAIL @"GetCardSettlementDetail"
#define WSM_CC_BATCH_UN_SETTLEMENT_DATA @"CCbatchUnSettlementData"
#define WSM_CC_BATCH_UN_SETTLEMENT_PAX_DATA @"CCbatchUnSettlementPaxData"
#define WSM_INSERT_CARD_SETTLEMENT_DATA @"InsertCardSettlement"
#define WSM_CC_TIPS_ADJUSTMENT @"CCTipsAdjustment"
#define WSM_BRIDGEPAY_GET_CARD_TRNX_PROCESS @"BridgepayGetCardTrxProcess"
#define WSM_BRIDGEPAY_SETTLEMENT_PROCESS @"BridgepaySettlementProcess"

//********* GiftCardPosVC *********//
#define WSM_PROCESS_RAPID_GIFTCARD @"ProcessRapidGiftCard"
#define WSM_CHECK_BALANCE_RAPID_GIFTCARD @"CheckRapidGiftCardBalance"
#define WSM_CHECK_RAPID_GIFTCARD @"CheckRapidGiftCard"
#define WSM_SAVE_RAPID_GIFTCARD @"SaveGiftCard"
#define WSM_LOAD_RAPID_GIFTCARD @"LoadRapidGiftCard"
#define WSM_GENERATE_NUMBER_RAPID_GIFTCARD @"GenrateGiftCardNo"

//********* MMDiscountVC *********//
#define WSM_MMD_ITEM_INSERT @"InsertDiscount"
#define WSM_MMD_ITEM_INSERT_RESULT @"InsertDiscountResult"
#define WSM_MMD_ITEM_UPDATE @"UpdateDiscount"
#define WSM_MMD_ITEM_UPDATE_RESULT @"UpdateDiscountResult"
#define WSM_MMD_ITEM_DELETE @"DeleteDiscount"
#define WSM_MMD_ITEM_DELETE_RESULT @"DeleteDiscountResult"
#define WSM_MMD_ITEM_STATUS @"UpdateDiscountStatus"
#define WSM_MMD_ITEM_STATUS_RESULT @"UpdateDiscountStatusResult"

//********* AddTaxMasterVC *********//
#define WSM_INSERT_TAX @"InsertTax"
#define WSM_UPDATE_TAX @"UpdateTax"
#define WSM_DELETE_TAX @"DeleteTax"

//********* ModuleActiveDeactiveSideInfoVC *********//
#define WSM_PERMENANT_RELEASE_REGISTER @"PermenantReleaseRegister"

//********* RapidCreditBatchDetailVC *********//
#define WSM_CREDIT_CARD_DATA_BY_ZID @"CreditCardDataByZId"

//********* XCCbatchReportVC *********//
#define WSM_INSERT_PAX @"InsertPax"

//********* CCBatchVC *********//

#define WSM_CC_TIPS_ADJUSTMENT @"CCTipsAdjustment"
#define WSM_INSERT_CARD_SETTLEMENT_JSON @"InsertCardSettlementJson"
#define WSM_GET_CAPTURE_AMOUNT @"GetCaptureAmt"

//********* ManagerReportVC *********//

#define WSM_Z_CENTRALIZE_LIST @"ZCentralizeList"

//********* ReportHandlerVC *********//

#define WSM_Z_CENTERALIZE_INFO @"ZCentralizeInfo"

