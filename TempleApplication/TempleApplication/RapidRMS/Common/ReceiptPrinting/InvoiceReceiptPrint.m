//
//  InvoiceReceiptPrint.m
//  RapidRMS
//
//  Created by Siya Infotech on 09/06/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "InvoiceReceiptPrint.h"
#import "RasterPrintJob.h"
#import "PaxConstants.h"
#import "RasterPrintJobBase.h"
#import "RmsDbController.h"
#import "Customer.h"

@implementation InvoiceReceiptPrint

- (void)validateData
{
    for(int i = 0;i<paymentDatailsArray.count;i++)
    {
        NSMutableDictionary *paymentDict = paymentDatailsArray[i];
        NSString *authCode = [paymentDict valueForKey:@"AuthCode"];
        NSString *cardType = [paymentDict valueForKey:@"CardType"];
        NSString *transactionNo = [paymentDict valueForKey:@"TransactionNo"];
        NSString *accNo = [paymentDict valueForKey:@"AccNo"];
        
        if (![authCode isKindOfClass:[NSString class]]) {
            authCode = [NSString stringWithFormat:@"authCode %@",[authCode class]];
        }
        if (![cardType isKindOfClass:[NSString class]]) {
            cardType = [NSString stringWithFormat:@"cardType %@",[cardType class]];
        }
        if (![transactionNo isKindOfClass:[NSString class]]) {
            transactionNo = [NSString stringWithFormat:@"transactionNo %@",[transactionNo class]];
        }
        if (![accNo isKindOfClass:[NSString class]]) {
            accNo = [NSString stringWithFormat:@"accNo %@",[accNo class]];
        }
        
        paymentDict[@"AuthCode"] = authCode;
        paymentDict[@"CardType"] = cardType;
        paymentDict[@"TransactionNo"] = transactionNo;
        paymentDict[@"AccNo"] = accNo;
    }
}
- (instancetype)initWithDemoPortName:(NSString *)portName printData:(NSMutableArray *)printData withDelegate:(id)delegate
{
    self = [super init];
    if (self) {
        portNameForPrinter = portName;
        receiptDataArray = printData;
    }
    [self TryPrinter:portName printData:printData withDelegate:delegate];
    return self;
}

- (instancetype)initWithPortName:(NSString *)portName portSetting:(NSString *)portSettings printData:(NSArray *)printData withPaymentDatail:(NSArray *)paymentDatail tipSetting:(NSNumber *)tipSetting tipsPercentArray:(NSArray *)tipsPercentArray receiptDate:(NSString *)reciptDate withMasterDetail:(NSArray *)masterDetail
{
    self = [super init];
    if (self) {
        portNameForPrinter = portName;
        portSettingsForPrinter = portSettings;
        strReceiptDate = reciptDate;
        receiptDataArray = printData;
        paymentDatailsArray = paymentDatail;
        tipSettings = tipSetting;
        arrTipsPercent = [tipsPercentArray mutableCopy];
        rmsDbController = [RmsDbController sharedRmsDbController];
        self.crmController = [RcrController sharedCrmController];
        masterArray = masterDetail;
        
        [self validateData];
        receiptDataKeys = @[
                            @"BranchName",
                            @"Address1",
                            @"Address2",
                            @"City",
                            @"State",
                            @"ZipCode",
                            @"UserName",
                            @"item",
                            @"itemName",
                            @"itemQty",
                            @"ItemDiscount",
                            @"ExtraCharge",
                            @"ItemBasicPrice",
                            @"itemTax",
                            @"TipsPercentage",
                            @"TipsAmount",
                            @"InvoiceVariationdetail",
                            @"VariationItemName",
                            @"Price",
                            @"itemQty",
                            @"CardHolderName",
                            @"AccNo",
                            @"AuthCode",
                            @"HelpMessage1",
                            @"HelpMessage2",
                            @"HelpMessage3",
                            @"SupportEmail",
                            ];
    }
    return self;
}

//// Receipt Section and Feild

- (void)configureInvoiceReceiptSection {
    
    //// section detail
    _sections = @[
                  @(ReceiptSectionReceiptHeader),
                  @(ReceiptSectionReceiptInfo),
                  @(ReceiptSectionItemDetail),
                  @(ReceiptSectionTotalSaleDetail),
                //  @(ReceiptSectionTipDetail),
                  @(ReceiptSectionCardDetail),
                  @(ReceiptSectionReceiptFooter),
                  @(ReceiptSectionBarcode),
                  
                  ];
    
    NSArray *receiptHeaderSectionFields = @[
                                           @(ReceiptFieldStoreName),
                                           @(ReceiptFieldAddressline1),
                                           @(ReceiptFieldAddressline2),
                                           ];
    
    NSArray *receiptInvoiceInfoSectionFields = @[
                                     @(ReceiptFieldReceiptName),
                                     @(ReceiptFieldInvoiceNo),
                                     @(ReceiptFieldCashierAndRegisterName),
                                     @(ReceiptFieldTransactionDate),
                                     @(ReceiptFieldPrintDate),
                                     ];
    
    NSArray *receiptItemDetailSectionFields = @[
                                    @(ReceiptFieldItemDetail),
                                    ];
    
    NSArray *receiptTotalSaleSectionFields = @[
                                @(ReceiptFieldTotalQTY),
                                @(ReceiptFieldSubTotal),
                                @(ReceiptFieldTax),
                                @(ReceiptFieldAmount),
                                @(ReceiptFieldTip),
                                @(ReceiptFieldTotal),

                                ];
    
 //   NSArray *receiptTipSectionFields = @[
                             //   @(ReceiptFieldTipArray),
                           //     ];
    
    
    NSArray *receiptCardDetailSectionFields = @[
                                  @(ReceiptFieldCashDetail),
//                                  @(ReceiptFieldChangeDue),
//                                  @(ReceiptFieldCheckTendered),
//                                  @(ReceiptFieldCraditTendered),
//                                  @(ReceiptFieldCardHolderName),
//                                  @(ReceiptFieldCardNumber),
//                                  @(ReceiptFieldAuthCode),
                                  @(ReceiptFieldSignuture),
                                 // @(ReceiptFieldAgreementText),
                                  @(ReceiptFieldDiscount),
                                  ];
    
    NSArray *receiptThanksMessageSectionFields = @[
                                  @(ReceiptFieldThanksMessage),
                          ];
    
    NSArray *receiptBarcodeSectionFields = @[
                                 @(ReceiptFieldBarcode),
                                 ];
    /// field detail
    _fields = @[
                receiptHeaderSectionFields,
                receiptInvoiceInfoSectionFields,
                receiptItemDetailSectionFields,
                receiptTotalSaleSectionFields,
             //   receiptTipSectionFields,
                receiptCardDetailSectionFields,
                receiptThanksMessageSectionFields,
                receiptBarcodeSectionFields,
                ];
}

//Demo print
-(void)TryPrinter:(NSString *)portName printData:(NSArray *)printData withDelegate:(id)delegate
{
    [self configurePrint:@"Standard" portName:portName withDelegate:delegate];
    [self defaultFormatForItemDetail];
    [printJob enableBold:YES];
    [printJob setTextAlignment:TA_CENTER];
    [printJob printLine:@"TEST PRINT"];
    [printJob enableBold:NO];
    [self testPrintData:printData];
}
-(void)testPrintData:(NSArray *)printData
{
    [self defaultFormatForTwoColumn];
    NSString *tempData = [[printData.firstObject valueForKey:@"ip"] stringByReplacingOccurrencesOfString:@"TCP" withString:@"IP"];
    NSString *tempData2 =[NSString stringWithFormat:@"%@",[printData.firstObject valueForKey:@"name"]];
    if ([tempData2 isEqualToString:@""]) {
        tempData2 = [tempData stringByReplacingOccurrencesOfString:@"IP" withString:@""];
        tempData2 = [tempData2 stringByReplacingOccurrencesOfString:@":" withString:@""];
    }
    [printJob printText1:tempData text2:[NSString stringWithFormat:@"NAME : %@", tempData2]];
    [printJob cutPaper:PC_PARTIAL_CUT_WITH_FEED];
    [printJob firePrint];
    printJob = nil;
}
#pragma mark - Generate Html

-(NSString *)generateHtmlForInvoiceNo:(NSString *)strInvoiceNo withChangeDue:(NSString *)changeDue
{
    
    NSString *html = @"";
    html = [[NSBundle mainBundle] pathForResource:@"emailReceipt_Temple" ofType:@"html"];
    html = [NSString stringWithContentsOfFile:html encoding:NSUTF8StringEncoding error:nil];
   
    NSString *fileURLString = [[[NSBundle mainBundle] URLForResource:@"SankatMochanLogo" withExtension:@"png"] absoluteString];
   
    html = [html stringByReplacingOccurrencesOfString:@"$$IMG_HTML$$" withString:[NSString stringWithFormat:@"src=\"%@\"",fileURLString]];
    
    if(![paymentDatailsArray isKindOfClass:[NSArray class]]){
        
        html = [html stringByReplacingOccurrencesOfString:@"Sales Receipt" withString:@"Void Receipt"];

    }
    
    // set Html Bill header
    html = [self htmlBillHeader:html forInvoiceNo:strInvoiceNo];
    
    // set Html itemDetail
    NSString *itemHtml = [self htmlBillTextForItem];
    html = [html stringByReplacingOccurrencesOfString:@"$$ITEM_HTML$$" withString:[NSString stringWithFormat:@"%@",itemHtml]];
    
    // set Html itemSubTotal Detail..........
    html = [self htmlBillTextSubtotal:html];
    
    // set Tips Data..........
    NSString *tipsHtml = [self generateHtmlForTips];
    html = [html stringByReplacingOccurrencesOfString:@"$$TIPS_DATA$$" withString:tipsHtml];
   
    // set Html itemFooter Detail..........5
    html = [self htmlBillFooter:html withChangeDue:changeDue];
//    if (rmsDbController.pumpManager) {
//        html = [self updatePumpCartDetail:html withPumpCartArray:pumpCartArray];
//    }
    
    /// Write Data On Document Directory.......
    NSData *data = [html dataUsingEncoding:NSUTF8StringEncoding];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths.firstObject;
    html = [documentsDirectory stringByAppendingPathComponent:@"CustomerDetail.html"];

    html = [self writeDataOnCacheDirectory:data withHtml:html];
    
    return html;
}
- (NSArray*)fetchFuelDetails:(NSString *)entityName withPumpIndex:(int)fuelIndex withMoc:(NsmoContext *)moc
{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fuelTypeIndex = %d",fuelIndex];
    fetchRequest.predicate = predicate;
    
    NSArray *arryTemp = [UpdateManager executeForContext:moc FetchRequest:fetchRequest];
    
    return arryTemp;
}

-(NSString *)htmlBillHeader:(NSString *)html forInvoiceNo:(NSString *)strInvoiceNo
{
    NSString *str1 = [NSString stringWithFormat:@"Thank you for shopping with %@",[[rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"BranchName"]];
    html = [html stringByReplacingOccurrencesOfString:@"$$Header1$$" withString:str1];
    NSString *str2 = [NSString stringWithFormat:@"Your Invoice # is %@",strInvoiceNo];
    html = [html stringByReplacingOccurrencesOfString:@"$$Header2$$" withString:str2];
    //style="min-height: 300px;"
    /* NSInteger currentPaymentImageIndex = 0;
     if([paymentDatailsArray isKindOfClass:[NSArray class]] && [paymentDatailsArray count] > 0){
     
     for(int i = 0;i<[paymentDatailsArray count];i++)
     {
     NSDictionary *paymentDict = [paymentDatailsArray objectAtIndex:i];
     if ([[paymentDict valueForKey:@"SignatureImage"] isKindOfClass:[UIImage class]]) {
     UIImage *customerImage = [paymentDict valueForKey:@"SignatureImage"];
     html = [html stringByReplacingOccurrencesOfString:@"$$SIGNATUREIMAGEURL$$" withString:[self getImagepathforHtml:customerImage forPaymentIndex:currentPaymentImageIndex]];
     currentPaymentImageIndex++;
     }
     else
     {
     html = [html stringByReplacingOccurrencesOfString:@"$$SIGNATUREIMAGEURL$$" withString:@""];
     }
     }
     }*/
    
   /* NSString *strDiscount = [self discountTotalForReceipt];
    
    float discount = [rmsDbController removeCurrencyFomatter:strDiscount];
    if (discount != 0 && discount > 0) {
        html = [html stringByReplacingOccurrencesOfString:@"$$DISCOUNT$$" withString:[NSString stringWithFormat:@"<tr><td style=\"width:60%%; color:#fff; background:#000; text-align:center;\"><strong>You saved: %@</strong></td></tr>",strDiscount]];
    }
    else
    {
        html = [html stringByReplacingOccurrencesOfString:@"$$DISCOUNT$$" withString:@""];
    }*/
    
    
    if ((rmsDbController.globalDict)[@"ReceiptMasterInfo"] && [(rmsDbController.globalDict)[@"ReceiptMasterInfo"] count] > 0) {
        html = [html stringByReplacingOccurrencesOfString:@"$$BRANCH_NAME$$" withString:[NSString stringWithFormat:@"%@",(rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"StoreName"]]];
    }
    else
    {
        html = [html stringByReplacingOccurrencesOfString:@"$$BRANCH_NAME$$" withString:[NSString stringWithFormat:@"%@",[self branchInfoValueForKeyIndex:ReceiptDataKeyBranchName]]];
    }
    
    if ((rmsDbController.globalDict)[@"ReceiptMasterInfo"] && [(rmsDbController.globalDict)[@"ReceiptMasterInfo"] count] > 0) {
        html = [html stringByReplacingOccurrencesOfString:@"$$ADDRESS$$" withString:[NSString stringWithFormat:@"%@",(rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"Address"]]];
    }
    else {
        html = [html stringByReplacingOccurrencesOfString:@"$$ADDRESS$$" withString:[NSString stringWithFormat:@"%@%@",[self branchInfoValueForKeyIndex:ReceiptDataKeyAddress1],[self branchInfoValueForKeyIndex:ReceiptDataKeyAddress2]]];
    }
    
    if ((rmsDbController.globalDict)[@"BranchInfo"] && [(rmsDbController.globalDict)[@"BranchInfo"] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *branchInfo = (rmsDbController.globalDict)[@"BranchInfo"];
        if (branchInfo != nil && ![branchInfo[@"ZipCode"] isKindOfClass:[NSNull class]]) {
            NSString *zipCode = [NSString stringWithFormat:@"%@", branchInfo[@"ZipCode"]];
            html =  [html stringByReplacingOccurrencesOfString:@"$$STATE_CITY_ZIPCODE$$" withString:[NSString stringWithFormat:@"%@",zipCode]];
        }
        else
        {
            html =  [html stringByReplacingOccurrencesOfString:@"$$STATE_CITY_ZIPCODE$$" withString:@""];
          }
    }
    else{
        html =  [html stringByReplacingOccurrencesOfString:@"$$STATE_CITY_ZIPCODE$$" withString:@""];
    }
    
    html =  [html stringByReplacingOccurrencesOfString:@"$$Tax_Id$$" withString:[NSString stringWithFormat:@"Tax Id:"]];
    
    
    if ((rmsDbController.globalDict)[@"ReceiptMasterInfo"] && [(rmsDbController.globalDict)[@"ReceiptMasterInfo"] count] > 0) {
        if ((rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"Email"] && [(rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"Email"] length] > 0) {
            NSString *phoneNo = [NSString stringWithFormat:@"%@", (rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"PhoneNo"]];
            html =  [html stringByReplacingOccurrencesOfString:@"$$Phone$$" withString:[NSString stringWithFormat:@"PhoneNo : %@",phoneNo]];
        }
        else
        {
            NSString *phoneNo = [NSString stringWithFormat:@"%@", (rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"PhoneNo"]];
            html =  [html stringByReplacingOccurrencesOfString:@"$$Phone$$" withString:[NSString stringWithFormat:@"%@",phoneNo]];
        }
    }
    else {
        html =  [html stringByReplacingOccurrencesOfString:@"$$STATE_CITY_ZIPCODE$$" withString:[NSString stringWithFormat:@"%@%@%@",[self branchInfoValueForKeyIndex:ReceiptDataKeyCity],[self branchInfoValueForKeyIndex:ReceiptDataKeyState],[self branchInfoValueForKeyIndex:ReceiptDataKeyZipCode]]];
    }
    
    html = [html stringByReplacingOccurrencesOfString:@"$$TRANSACTION_NO$$" withString:[NSString stringWithFormat:@"Invoice #: %@",strInvoiceNo]];
    
    NSString *strCashierName = @"";
    
    NSString *strRegister = @"";
    if (self.isInvoiceReceipt) {
        strRegister = [NSString stringWithFormat:@"%@",self.registerName];
        strCashierName = [NSString stringWithFormat:@"%@",self.cashierName];
    }
    else
    {
        strRegister = [NSString stringWithFormat:@"%@",(rmsDbController.globalDict)[@"RegisterName"]];
        strCashierName = [NSString stringWithFormat:@"%@",[self userInfoValueForKeyIndex:ReceiptDataKeyUserName]];
    }

    html = [html stringByReplacingOccurrencesOfString:@"$$USER_NAME$$" withString:strCashierName];

    html = [html stringByReplacingOccurrencesOfString:@"$$REGISTER_NAME$$" withString:[NSString stringWithFormat:@"%@",strRegister]];
    
//    if ((rmsDbController.globalDict)[@"ReceiptMasterInfo"] && [(rmsDbController.globalDict)[@"ReceiptMasterInfo"] count] > 0 && (rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"ThanksNote"] && [(rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"ThanksNote"] length] > 0) {
//        NSString *thanksMessage = [NSString stringWithFormat:@"%@", (rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"ThanksNote"]];
//        html = [html stringByReplacingOccurrencesOfString:@"$$HELPMESSAGE1$$" withString:[NSString stringWithFormat:@"%@",thanksMessage]];
//        html = [html stringByReplacingOccurrencesOfString:@"$$BRANCH_NAME$$" withString:@""];
//        html = [html stringByReplacingOccurrencesOfString:@"$$HELPMESSAGE2$$" withString:@""];
//        html = [html stringByReplacingOccurrencesOfString:@"$$HELPMESSAGE3$$" withString:@""];
//    }
//    else {
//        html = [html stringByReplacingOccurrencesOfString:@"$$HELPMESSAGE1$$" withString:[NSString stringWithFormat:@"%@",[self branchInfoValueForKeyIndex:ReceiptDataKeyHelpMessage1]]];
//        html = [html stringByReplacingOccurrencesOfString:@"$$BRANCH_NAME$$" withString:[NSString stringWithFormat:@"%@",[self branchInfoValueForKeyIndex:ReceiptDataKeyBranchName]]];
//        html = [html stringByReplacingOccurrencesOfString:@"$$HELPMESSAGE2$$" withString:[NSString stringWithFormat:@"%@",[self branchInfoValueForKeyIndex:ReceiptDataKeyHelpMessage2]]];
//        html = [html stringByReplacingOccurrencesOfString:@"$$HELPMESSAGE3$$" withString:[NSString stringWithFormat:@"%@",[self branchInfoValueForKeyIndex:ReceiptDataKeyHelpMessage3]]];
//    }
    
    
    
    html = [html stringByReplacingOccurrencesOfString:@"$$FedralId$$" withString:@"Federal ID#:- 20-846174"];

    if (strReceiptDate) {
        html = [html stringByReplacingOccurrencesOfString:@"$$TRNXDATE$$" withString:[NSString stringWithFormat:@"TrnxDate : %@",strReceiptDate]];
    }
    // NON-PROFIT ORGANIZATION TAX EXAMPT FEDERAL ID#:- 20-8461747 Acknowledge  your priceless tax deduction contribution with sincere thanks
    html = [html stringByReplacingOccurrencesOfString:@"$$Notes$$" withString:@"NOTE :"];

    html = [html stringByReplacingOccurrencesOfString:@"$$Tax_Id:$$" withString:@"Tax Id :"];

    
    
    if (masterArray != nil) {
        NSNumber *customerIdNumber = [[masterArray firstObject]valueForKey:@"CustId"];
        NSString *customerId = [NSString stringWithFormat: @"%@",customerIdNumber];
        if (![customerId isEqualToString:@""]) {
            NSManagedObjectContext *manageObjectContext = rmsDbController.managedObjectContext;
            
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            
            NSEntityDescription *entity = [NSEntityDescription
                                           entityForName:@"Customer" inManagedObjectContext:manageObjectContext];
            fetchRequest.entity = entity;
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"custId == %@", customerId];
            fetchRequest.predicate = predicate;
            
            // NSError *error;
            NSArray *resultSet = [UpdateManager executeForContext:manageObjectContext FetchRequest:fetchRequest];
            if (resultSet.count>0)
            {
                Customer *customer = (Customer *)[resultSet firstObject];
                html = [html stringByReplacingOccurrencesOfString:@"$$Customer_Name$$" withString:[NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"Name : %@ %@",customer.firstName,customer.lastName]]];
                html = [html stringByReplacingOccurrencesOfString:@"$$CustomerAddress$$" withString:[NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"Address : %@%@",customer.address1,customer.address1]]];
                html = [html stringByReplacingOccurrencesOfString:@"$$ZipCode$$" withString:[NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"Email : %@",customer.email]]];
                html = [html stringByReplacingOccurrencesOfString:@"$$Customer_Phone$$" withString:[NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"Phone : %@",customer.contactNo]]];
            }
            else
            {
                html = [html stringByReplacingOccurrencesOfString:@"$$Customer_Name$$" withString:@"Name : "];
                html = [html stringByReplacingOccurrencesOfString:@"$$CustomerAddress$$" withString:@"Address : "];
                html = [html stringByReplacingOccurrencesOfString:@"$$ZipCode$$" withString:@"Email : "];
                html = [html stringByReplacingOccurrencesOfString:@"$$Customer_Phone$$" withString:@"Phone : "];
            }
      }
        else
        {
            html = [html stringByReplacingOccurrencesOfString:@"$$Customer_Name$$" withString:@"Name : "];
            html = [html stringByReplacingOccurrencesOfString:@"$$CustomerAddress$$" withString:@"Address : "];
            html = [html stringByReplacingOccurrencesOfString:@"$$ZipCode$$" withString:@"Email : "];
            html = [html stringByReplacingOccurrencesOfString:@"$$Customer_Phone$$" withString:@"Phone : "];
        }

    }
    else
    {
        html = [html stringByReplacingOccurrencesOfString:@"$$Customer_Name$$" withString:@"Name : "];
        html = [html stringByReplacingOccurrencesOfString:@"$$CustomerAddress$$" withString:@"Address : "];
        html = [html stringByReplacingOccurrencesOfString:@"$$ZipCode$$" withString:@"Email : "];
        html = [html stringByReplacingOccurrencesOfString:@"$$Customer_Phone$$" withString:@"Phone : "];
    }

    
    if ([self isCheckPaymentIsAvailable] == TRUE) {
        html = [html stringByReplacingOccurrencesOfString:@"$$ChequeMessage$$" withString:@"Make All Check Paybale To"];
    }
    else
    {
        html = [html stringByReplacingOccurrencesOfString:@"$$ChequeMessage$$" withString:@""];
    }
    html = [html stringByReplacingOccurrencesOfString:@"$$NOTEMESAGE$$" withString:@"NON-PROFIT ORGANIZATION TAX EXAMPT FEDERAL ID#:- 20-8461747 Acknowledge  your priceless tax deduction contribution with sincere thanks"];

    
    
       NSDate * date = [NSDate date];
    //Create the dateformatter object
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    
    //Create the timeformatter object
    NSDateFormatter* timeFormatter = [[NSDateFormatter alloc] init];
    timeFormatter.dateFormat = @"hh:mm a";
    
    //Get the string date
    NSString *printDate = [dateFormatter stringFromDate:date];
    html = [html stringByReplacingOccurrencesOfString:@"$$CURRENTDATE$$" withString:printDate];
    
    return html;
}

-(BOOL)isCheckPaymentIsAvailable{
    
    BOOL isCheckPaymentIsAvailable = FALSE;
    
    NSPredicate *predicatecheque= [NSPredicate predicateWithFormat:@"PaymentType = %@",@"Check"];
    NSArray *chequeArray = [paymentDatailsArray filteredArrayUsingPredicate:predicatecheque];
    if (chequeArray.count > 0) {
        isCheckPaymentIsAvailable = TRUE;
    }
    return isCheckPaymentIsAvailable;
}

- (id)branchInfoValueForKeyIndex:(ReceiptDataKey)index
{
    return [self valueFromDictionary:[self branchInfo] forKeyIndex:index];
}

- (id)userInfoValueForKeyIndex:(ReceiptDataKey)index
{
    return [self valueFromDictionary:[self userInfo] forKeyIndex:index];
}

- (id)valueFromDictionary:(NSDictionary *)dictionary forKeyIndex:(ReceiptDataKey)index
{
   return dictionary[[self keyForIndex:index]];
}

- (NSString *)keyForIndex:(ReceiptDataKey)index
{
    return receiptDataKeys[index];
}

- (NSDictionary *)branchInfo
{
    NSDictionary *dictBranchInfo = [rmsDbController.globalDict valueForKey:@"BranchInfo"];
    return dictBranchInfo;
}

- (NSDictionary *)userInfo
{
    NSDictionary *dictUserInfo = [rmsDbController.globalDict valueForKey:@"UserInfo"];
    return dictUserInfo;
}

- (NSString *)discountTotalForReceipt
{
  //  float totalDiscount = 0.0;
     totalDiscount = 0.0;

    if ([[self keyForIndex:ReceiptDataKeyItemDiscount] isEqualToString:@"ItemDiscountAmount"]) {
        
        receiptDataArray = [self sortedReceiptDataArray];
        for (NSDictionary *billEntry in receiptDataArray)
        {
            totalDiscount += [[self valueFromDictionary:billEntry forKeyIndex:ReceiptDataKeyItemDiscount] floatValue];
        }
    }
    else
    {
        receiptDataArray = [self sortedReceiptDataArray];
        for (NSDictionary *billEntry in receiptDataArray)
        {
            totalDiscount += [[self valueFromDictionary:billEntry forKeyIndex:ReceiptDataKeyItemDiscount] floatValue] ;
        }
    }
    
    NSNumber *discountAmount = @(totalDiscount);
    NSString *strDiscount = [self currencyFormattedStringForAmount:discountAmount.floatValue];
    return strDiscount;
}


-(NSString *)getImageForHtmlBase64:(UIImage *)pImage{
    NSData *imageData = UIImagePNGRepresentation(pImage);
    NSString *strImage = [NSString stringWithFormat:@"<div style=\"float:left;text-align:center; width:100%%;\"><img src=\"data:image/gif;base64,%@\" align=\"center\" style=\"width: 336px; height: 112px /></div>",[imageData base64EncodedStringWithOptions:0]];

    return strImage;
}


- (NSString *)htmlForItemDictionary:(NSDictionary *)billEntry
{
    NSString *itemHtml = @"";
    BOOL isqtyMoreThan1 = FALSE;
    if (iqty > 1)
    {
        isqtyMoreThan1 = TRUE;
    }
    
    NSString *strHTML = [self htmlBillTextGenericForItemwithDictionary:billEntry withMoreThan1Qty:isqtyMoreThan1];
    if(gasDetail.length == 0){
        itemHtml = [itemHtml stringByAppendingString:strHTML];
    }
    
    float fdiscAmt = [[self valueFromDictionary:billEntry forKeyIndex:ReceiptDataKeyItemDiscount] floatValue];
    float ffeesAmt = 0.00;
    if ([billEntry objectForKey:@"ExtraCharge"])
    {
       ffeesAmt = [[billEntry valueForKey:@"ExtraCharge"] floatValue];
    }
    else
    {
        ffeesAmt = [[self valueFromDictionary:[self valueFromDictionary:billEntry forKeyIndex:ReceiptDataKeyItem] forKeyIndex:ReceiptDataKeyExtraCharge] floatValue] * [[self valueFromDictionary:billEntry forKeyIndex:ReceiptDataKeyItemQty] intValue];
    }
    float checkCaseFeesAmt = [[[self valueFromDictionary:billEntry forKeyIndex:ReceiptDataKeyItem] valueForKey:@"CheckCashCharge"] floatValue];
    
    
    //Set fee for checkcase
    if (checkCaseFeesAmt != 0)
    {
        itemHtml = [itemHtml stringByAppendingString:[self htmlBillCheckCaseAmountItem:billEntry]];
    }
    
    //hiten
    // set Item Fees Detail....
    
    if (ffeesAmt != 0)
    {
        itemHtml = [itemHtml stringByAppendingString:[self htmlBillExtraChargeAmountItem:billEntry]];
    }
    // set Item Detail with More than 1  qty....
    if (iqty > 1)
    {
        itemHtml = [itemHtml stringByAppendingString:[self htmlBillTextQuantityForItem:billEntry]];
    }
    
 //   itemHtml = [itemHtml stringByAppendingString:[self htmlBillTextPackageQtyForItem:billEntry]];
    // set Item Discount Detail....
    if (fdiscAmt != 0)
    {
        itemHtml = [itemHtml stringByAppendingString:[self htmlBillTextDiscountForItem:billEntry]];
        // float fdistotprice= iqty * fdiscAmt;
        //totDisAmount+=fdistotprice;
    }
    
    
    qty += [[self valueFromDictionary:billEntry forKeyIndex:ReceiptDataKeyItemQty] intValue] / [[billEntry valueForKey:@"PackageQty"] intValue];
    float itemAmount = 0.00;
    float itemBasicAmount = 0.00;
    
    if ([billEntry objectForKey:@"ItemBasicPrice"]) {
        itemAmount = [[billEntry valueForKey:@"itemPrice"] floatValue];
        itemBasicAmount = [[billEntry valueForKey:@"ItemBasicPrice"] floatValue];
    }
    else if ([billEntry objectForKey:@"ItemBasicAmount"])
    {
        itemAmount = [[billEntry valueForKey:@"ItemAmount"] floatValue];
        
        if ([[billEntry valueForKey:@"VariationAmount"] floatValue] > 0)
        {
            itemAmount  = itemAmount - [[billEntry valueForKey:@"VariationAmount"] floatValue];
        }
        itemBasicAmount = [[billEntry valueForKey:@"ItemBasicAmount"] floatValue];
    }

    float BasicPrice;
    if(iqty==1)
    {
        BasicPrice = itemBasicAmount;
        if( (itemAmount > 0 && itemAmount > itemBasicAmount) || (itemAmount < 0 && itemAmount < itemBasicAmount))
        {
            BasicPrice = itemAmount;
        }
        
    }
    else{
        BasicPrice = [[self valueFromDictionary:billEntry forKeyIndex:ReceiptDataKeyItemQty] intValue]*itemBasicAmount;

        if( (itemAmount > 0 && itemAmount > itemBasicAmount) || (itemAmount < 0 && itemAmount < itemBasicAmount))
        {
            BasicPrice = [[self valueFromDictionary:billEntry forKeyIndex:ReceiptDataKeyItemQty] intValue]*itemAmount;

        }
        
    }
    
    if(fdiscAmt!=0)
    {
        if ([[self keyForIndex:ReceiptDataKeyItemDiscount] isEqualToString:@"ItemDiscountAmount"]) {
            float fdistotprice = [[self valueFromDictionary:billEntry forKeyIndex:ReceiptDataKeyItemDiscount] floatValue];
            BasicPrice = BasicPrice - fdistotprice;
        }
       else
        {
            float fdistotprice = fdiscAmt;
            BasicPrice = BasicPrice - fdistotprice;
       }
    }
    
//    if(iqty==1)
//    {
        if ([[[self valueFromDictionary:billEntry forKeyIndex:ReceiptDataKeyItem] valueForKey:@"isCheckCash"] boolValue] == YES)
        {
            float feeAmount = [[self valueFromDictionary:billEntry forKeyIndex:ReceiptDataKeyItemQty] intValue] * [[[self valueFromDictionary:billEntry forKeyIndex:ReceiptDataKeyItem] valueForKey:@"CheckCashCharge"] floatValue];
            subtotal -= [[self valueFromDictionary:billEntry forKeyIndex:ReceiptDataKeyItemQty] intValue]*[[self valueFromDictionary:billEntry forKeyIndex:ReceiptDataKeyItemBasicPrice] floatValue];
            subtotal += feeAmount;
        }
        else if ([[[self valueFromDictionary:billEntry forKeyIndex:ReceiptDataKeyItem] valueForKey:@"isExtraCharge"] boolValue] == YES || ffeesAmt != 0.00)
        {
            float totalExtchargeamt = 0.0;
            if ([[self keyForIndex:ReceiptDataKeyItemDiscount] isEqualToString:@"ItemDiscountAmount"]) {
                totalExtchargeamt = ffeesAmt;
                subtotal += ffeesAmt;
            }
            else
            {
                totalExtchargeamt = ffeesAmt * iqty;
                subtotal += ffeesAmt;
            }
        }

        else
        {
           // subtotal+= (BasicPrice + [self variationCostForPrintbillEntryDictionary:billEntry]);
           // subtotal += ffeesAmt;
        }
  //  }
//    else{
//        
//      //  subtotal+= (BasicPrice + [self variationCostForPrintbillEntryDictionary:billEntry]);
//      //  subtotal += ffeesAmt;
//    }

    if ([[[self valueFromDictionary:billEntry forKeyIndex:ReceiptDataKeyItem] valueForKey:@"isCheckCash"] boolValue]== NO)
    {
        float BasicPrice;
        float itemAmount = 0.00;
        float itemBasicAmount = 0.00;
        
        if ([billEntry objectForKey:@"ItemBasicPrice"]) {
            itemAmount = [[billEntry valueForKey:@"itemPrice"] floatValue];
            itemBasicAmount = [[billEntry valueForKey:@"ItemBasicPrice"] floatValue];
        }
        else if ([billEntry objectForKey:@"ItemBasicAmount"])
        {
            itemAmount = [[billEntry valueForKey:@"ItemAmount"] floatValue];
            
            if ([[billEntry valueForKey:@"VariationAmount"] floatValue] > 0)
            {
                itemAmount  = itemAmount - [[billEntry valueForKey:@"VariationAmount"] floatValue];
            }
            itemBasicAmount = [[billEntry valueForKey:@"ItemBasicAmount"] floatValue];
        }
        
        if(iqty==1)
        {
            if( (itemAmount > 0 && itemAmount > itemBasicAmount) || (itemAmount < 0 && itemAmount < itemBasicAmount))
            {
                BasicPrice = itemAmount;
            }
            else
            {
                BasicPrice = itemBasicAmount;
            }
        }
        else
        {
            if( (itemAmount > 0 && itemAmount > itemBasicAmount) || (itemAmount < 0 && itemAmount < itemBasicAmount))
            {
                BasicPrice = itemAmount *[[self valueFromDictionary:billEntry forKeyIndex:ReceiptDataKeyItemQty] intValue];
            }
            else
            {
                BasicPrice = itemBasicAmount *[[self valueFromDictionary:billEntry forKeyIndex:ReceiptDataKeyItemQty] intValue];
            }
        }
        
        if(fdiscAmt != 0)
        {
            if ([[self keyForIndex:ReceiptDataKeyItemDiscount] isEqualToString:@"ItemDiscountAmount"]) {
                float discount = [[self valueFromDictionary:billEntry forKeyIndex:ReceiptDataKeyItemDiscount] floatValue];
                if (discount > 0) {
                    BasicPrice = BasicPrice - discount;
                }
                else{
                    discount = -discount;
                    BasicPrice = BasicPrice + discount;

                }
            }
            else
            {
                float fdistotprice = fdiscAmt;
                
                BasicPrice = BasicPrice - fdistotprice;
            }
        }
        
        if(iqty==1)
        {
            subtotal+= (BasicPrice + [self variationCostForPrintbillEntryDictionary:billEntry]) * [[self valueFromDictionary:billEntry forKeyIndex:ReceiptDataKeyItemQty] intValue];
        }
        else{
            
            subtotal+= (BasicPrice + [self variationCostForPrintbillEntryDictionary:billEntry]);
        }
    }


    
    tax += [[self valueFromDictionary:billEntry forKeyIndex:ReceiptDataKeyItemTax] floatValue];
    
    return itemHtml;
}


-(NSString *)htmlBillTextForItem
{
    NSString *itemHtml = @"";
//    int qty =0;
//    float subtotal = 0;
//    float tax = 0;
//    float totDisAmount = 0;
    qty =0;
     subtotal = 0;
   tax = 0;
   // float totDisAmount = 0;
    //float totalfee=0;
    
    invoiceDetailDict = [[NSMutableDictionary alloc]init];
    receiptDataArray = [self sortedReceiptDataArray];
    for (NSDictionary *billEntry in receiptDataArray)
    {
        iqty = [[self valueFromDictionary:billEntry forKeyIndex:ReceiptDataKeyItemQty] intValue];
        
        itemHtml = [itemHtml stringByAppendingString:[self htmlForItemDictionary:billEntry]];
    }
    float tipAmout = [self getSumOfTheValue:@"TipsAmount" forBillDetail:paymentDatailsArray];
    //subtotal = subtotal;
    float totalAmount = subtotal+tax;
   
    float totalAmountWithTips = 0.0;
    if(tipAmout > 0)
    {
        totalAmountWithTips = totalAmount+tipAmout;
    }
    
    invoiceDetailDict[@"totalAmount"] = [NSString stringWithFormat:@"%.2f",totalAmount];
    invoiceDetailDict[@"subtotal"] = [NSString stringWithFormat:@"%.2f",subtotal];
    if(tipAmout > 0)
    {
        invoiceDetailDict[@"tipAmount"] = [NSString stringWithFormat:@"%.2f",tipAmout];
        invoiceDetailDict[@"totalAmountWithTips"] = [NSString stringWithFormat:@"%.2f",totalAmountWithTips];
    }
    invoiceDetailDict[@"qty"] = [NSString stringWithFormat:@"%d",qty];
    invoiceDetailDict[@"tax"] = [NSString stringWithFormat:@"%.2f",tax];
    return itemHtml;
}

-(NSString *)htmlBillTextGenericForItemwithDictionary:(NSDictionary *)itemDictionary withMoreThan1Qty:(BOOL)isQtyMoreThan1
{
    NSString *htmldata = @"";

    NSString *total = @"";
    float itemAmount = 0.00;
    float itemBasicAmount = 0.00;
    
    if ([itemDictionary objectForKey:@"ItemBasicPrice"]) {
        itemAmount = [[itemDictionary valueForKey:@"itemPrice"] floatValue];
        itemBasicAmount = [[itemDictionary valueForKey:@"ItemBasicPrice"] floatValue];
    }
    else if ([itemDictionary objectForKey:@"ItemBasicAmount"])
    {
        itemAmount = [[itemDictionary valueForKey:@"ItemAmount"] floatValue];
        
        if ([[itemDictionary valueForKey:@"VariationAmount"] floatValue] > 0)
        {
            itemAmount  = itemAmount - [[itemDictionary valueForKey:@"VariationAmount"] floatValue];
        }
        itemBasicAmount = [[itemDictionary valueForKey:@"ItemBasicAmount"] floatValue];
    }


    if (isQtyMoreThan1)
    {
         total = @"";
    }
    else
    {
        if((itemAmount > 0 && itemAmount > itemBasicAmount) || (itemAmount < 0 && itemAmount < itemBasicAmount))
        {
            total = [self currencyFormattedStringForAmount:itemAmount]; /// ItemBasicPrice
        }
        else
        {
            total = [self currencyFormattedStringForAmount:itemBasicAmount]; /// ItemBasicPrice
        }
    }
    
    htmldata = [htmldata stringByAppendingFormat:@"<tr><td valign=\"top\"  style=\"word-break:break-all; padding-right:10px;\"><font size=\"2\">%@</font> </td><td align=\"left\" valign=\"top\" style=\"width:40%@; word-break:break-all; padding-right:10px;\" ><font size=\"2\">%@</font> </td> <td align=\"right\" valign=\"top\"><font size=\"2\">%@</font></td></tr>",itemDictionary[@"Barcode"],@"%",[self valueFromDictionary:itemDictionary forKeyIndex:ReceiptDataKeyItemName],total];
   
    if ([[self valueFromDictionary:itemDictionary forKeyIndex:ReceiptDataKeyItemName] isEqualToString:@"RapidRMS Gift Card"]) {
        
        NSString *giftAccNo = [NSString stringWithFormat:@"Account No:%@",[itemDictionary valueForKey:@"CardNo"]];
        htmldata = [htmldata stringByAppendingFormat:@"<tr><td valign=\"top\" style=\"word-break:break-all; padding-right:10px;\"><font size=\"2\"></font> </td><td align=\"left\" valign=\"top\" style=\"width:40%@; word-break:break-all;  padding-right:10px;\" ><font size=\"2\">%@</font> </td> <td align=\"right\" valign=\"top\"><font size=\"2\">%@</font></td></tr>",@"%",giftAccNo,@""];
        
    }

    if([self valueFromDictionary:itemDictionary forKeyIndex:ReceiptDataKeyInvoiceVariationdetail])
    {
        NSArray *variationDetails = [self valueFromDictionary:itemDictionary forKeyIndex:ReceiptDataKeyInvoiceVariationdetail];
        
        if ([variationDetails isKindOfClass:[NSArray class]])
        {
            if (variationDetails.count >0)
            {
                for (int varItem =0 ; varItem < variationDetails.count; varItem++)
                {
                    NSDictionary *variationDetail = variationDetails[varItem];
                    
                    NSString *variationName = [self valueFromDictionary:variationDetail forKeyIndex:ReceiptDataKeyVariationItemName];
                    NSString *variationPrice = [self currencyFormattedStringForAmount:[[self valueFromDictionary:variationDetail forKeyIndex:ReceiptDataKeyVariationPrice] floatValue] * [[self valueFromDictionary:itemDictionary forKeyIndex:ReceiptDataKeyItemQty] intValue]];
                    
                    htmldata = [htmldata stringByAppendingFormat:@"<tr><td valign=\"top\" style=\"word-break:break-all; padding-right:10px;\"><font size=\"2\"></font> </td><td align=\"left\" valign=\"top\" style=\"width:40%@; word-break:break-all;  padding-right:10px;\" ><font size=\"2\">%@</font> </td> <td align=\"right\" valign=\"top\"><font size=\"2\">%@</font></td></tr>",@"%",variationName,variationPrice];
                }
            }
        }
    }
    return htmldata;
}

-(NSString *)htmlBillExtraChargeAmountItem:(NSDictionary *)itemDictionary
{
    NSString *htmldata = @"";
    float feeAmount = 0.0;
    if ([[self keyForIndex:ReceiptDataKeyItemDiscount] isEqualToString:@"ItemDiscountAmount"]) {
        feeAmount = [[self valueFromDictionary:[self valueFromDictionary:itemDictionary forKeyIndex:ReceiptDataKeyItem] forKeyIndex:ReceiptDataKeyExtraCharge] floatValue];
    }
    else
    {
        feeAmount = [[self valueFromDictionary:itemDictionary forKeyIndex:ReceiptDataKeyItemQty] intValue] *[[self valueFromDictionary:[self valueFromDictionary:itemDictionary forKeyIndex:ReceiptDataKeyItem] forKeyIndex:ReceiptDataKeyExtraCharge] floatValue];
    }
    NSNumber *doubleFeeAmount = [NSNumber numberWithDouble:feeAmount];
    NSString *feeAmountString=[self.crmController.currencyFormatter stringFromNumber:doubleFeeAmount];
    htmldata = [htmldata stringByAppendingFormat:@"<tr><td valign=\"top\" style=\"word-break:break-all; padding-right:10px;\"><font size=\"3\"></font> </td><td align=\"left\" valign=\"top\" style=\"width:40%%; word-break:break-all;  padding-right:10px;\" ><font size=\"3\">Fee</font> </td> <td align=\"right\" valign=\"top\"><font size=\"3\">%@</font></td></tr>", feeAmountString];
    return htmldata;
}

-(NSString *)htmlBillCheckCaseAmountItem:(NSDictionary *)itemDictionary
{
    NSString *htmldata = @"";
    float feeAmount = [[self valueFromDictionary:itemDictionary forKeyIndex:ReceiptDataKeyItemQty] intValue] * [[[self valueFromDictionary:itemDictionary forKeyIndex:ReceiptDataKeyItem] valueForKey:@"CheckCashCharge"] floatValue];
    NSNumber *doubleFeeAmount = [NSNumber numberWithDouble:feeAmount];
    NSString *feeAmountString = [self.crmController.currencyFormatter stringFromNumber:doubleFeeAmount];
    htmldata = [htmldata stringByAppendingFormat:@"<tr><td valign=\"top\" style=\"word-break:break-all; padding-right:10px;\"><font size=\"3\"></font> </td><td align=\"left\" valign=\"top\" style=\"width:40%%; word-break:break-all;  padding-right:10px;\" ><font size=\"3\">Fee</font> </td> <td align=\"right\" valign=\"top\"><font size=\"3\">%@</font></td></tr>", feeAmountString];
    return htmldata;
}

-(NSString *)htmlBillTextQuantityForItem:(NSDictionary *)itemDictionary
{
    NSString *htmldata = @"";
    float qtyXPrice= 0.0;
    float price =0.0;
    float itemAmount = 0.00;
    float itemBasicAmount = 0.00;
    
    if ([itemDictionary objectForKey:@"ItemBasicPrice"]) {
        itemAmount = [[itemDictionary valueForKey:@"itemPrice"] floatValue];
        itemBasicAmount = [[itemDictionary valueForKey:@"ItemBasicPrice"] floatValue];
    }
    else if ([itemDictionary objectForKey:@"ItemBasicAmount"])
    {
        itemAmount = [[itemDictionary valueForKey:@"ItemAmount"] floatValue];
        
        if ([[itemDictionary valueForKey:@"VariationAmount"] floatValue]>0) {
            itemAmount  = itemAmount - [[itemDictionary valueForKey:@"VariationAmount"] floatValue];
        }
        itemBasicAmount = [[itemDictionary valueForKey:@"ItemBasicAmount"] floatValue];
    }
    
    if( (itemAmount > 0 && itemAmount > itemBasicAmount) || (itemAmount < 0 && itemAmount < itemBasicAmount))
    {
         qtyXPrice= [[self valueFromDictionary:itemDictionary forKeyIndex:ReceiptDataKeyItemQty] intValue] * itemAmount;
        price = itemAmount * [[itemDictionary valueForKey:@"PackageQty"] intValue];
    }
    else{
         qtyXPrice= [[self valueFromDictionary:itemDictionary forKeyIndex:ReceiptDataKeyItemQty] intValue] *itemBasicAmount;
        price = itemBasicAmount * [[itemDictionary valueForKey:@"PackageQty"] intValue];
    }
   
    NSInteger itemQty = [[self valueFromDictionary:itemDictionary forKeyIndex:ReceiptDataKeyItemQty] intValue] / [[itemDictionary valueForKey:@"PackageQty"] intValue];

    htmldata = [htmldata stringByAppendingFormat:@"<tr><td valign=\"top\"style=\"word-break:break-all; padding-right:10px;\"><font size=\"2\"></font> </td><td align=left\" valign=\"top\" style=\"width:40%%; word-break:break-all;  padding-right:10px;\" ><font size=\"2\">%ld x %@</font> </td> <td align=\"right\" valign=\"top\"><font size=\"2\"> %@ </font></td></tr>", (long)itemQty,[self currencyFormattedStringForAmount:price],[self currencyFormattedStringForAmount:qtyXPrice]];
    return htmldata;
}

-(NSString *)htmlBillTextPackageQtyForItem:(NSDictionary *)itemDictionary
{
        NSString *htmldata = @"";
        htmldata = [htmldata stringByAppendingFormat:@"<tr><td valign=\"top\"style=\"word-break:break-all; padding-right:10px;\"><font size=\"2\"></font> </td><td align=left\" valign=\"top\" style=\"width:40%%; word-break:break-all;  padding-right:10px;\" ><font size=\"2\">%@</font> </td> <td align=\"right\" valign=\"top\"><font size=\"2\">  </font></td></tr>",[itemDictionary valueForKey:@"PackageType"]];
        return htmldata;
}


-(NSString *)htmlBillTextDiscountForItem:(NSDictionary *)itemDictionary
{
    NSString *htmldata = @"";
    
    float fdistotprice = 0.0 ;
    if ([[self keyForIndex:ReceiptDataKeyItemDiscount] isEqualToString:@"ItemDiscountAmount"]) {
        fdistotprice = [[self valueFromDictionary:itemDictionary forKeyIndex:ReceiptDataKeyItemDiscount] floatValue];
    }
    else
    {
        fdistotprice = [[self valueFromDictionary:itemDictionary forKeyIndex:ReceiptDataKeyItemDiscount] floatValue];
    }
    
        fdistotprice=-fdistotprice;// display negative amount
    
    NSNumber *doubledisAmount = [NSNumber numberWithDouble:fdistotprice];
    
    NSString *sdisamount=[self.crmController.currencyFormatter stringFromNumber:doubledisAmount];
    
    htmldata = [htmldata stringByAppendingFormat:@"<tr><td valign=\"top\" style=\"word-break:break-all; padding-right:10px;\"><font size=\"3\"></font> </td><td align=\"left\" valign=\"top\" style=\"width:40%%; word-break:break-all;  padding-right:10px;\" ><font size=\"2\">Discount</font> </td> <td align=\"right\" valign=\"top\"><font size=\"2\">%@</font></td></tr>", sdisamount];
    
    return htmldata;
}

-(NSString *)htmlBillTextSubtotal:(NSString *)html
{
    html = [html stringByReplacingOccurrencesOfString:@"$$SUB_TOTAL$$" withString:[self currencyFormattedStringForKey:@"subtotal" dictionary:invoiceDetailDict]];
    html = [html stringByReplacingOccurrencesOfString:@"$$TAX$$" withString:[self currencyFormattedStringForKey:@"tax" dictionary:invoiceDetailDict]];
    
    if([invoiceDetailDict valueForKey:@"tipAmount"])
    {
        NSString *strTip = [NSString stringWithFormat:@"<div style=\"float:left; width:100%%;\"><div style=\"float:right; text-align:left;\">%@</div><div style=\"float:right; \">Tip :</div></div>",[self currencyFormattedStringForKey:@"tipAmount" dictionary:invoiceDetailDict]];
        NSString *strTotal = [NSString stringWithFormat:@"<div style=\"float:left; width:100%%;\"><div style=\"float:right; text-align:left;\"><strong>%@</strong></div><div style=\"float:right; \"><strong>Total :</strong></div></div>",[self currencyFormattedStringForKey:@"totalAmountWithTips" dictionary:invoiceDetailDict]];
        html = [html stringByReplacingOccurrencesOfString:@"$$TIP$$" withString:[NSString stringWithFormat:@"%@",strTip]];
        html = [html stringByReplacingOccurrencesOfString:@"$$TIPSWITHTOTAL$$" withString:[NSString stringWithFormat:@"%@",strTotal]];
        html = [html stringByReplacingOccurrencesOfString:@"$$TIPANDTOTAL$$" withString:[NSString stringWithFormat:@"%@",@""]];
    }
    else if([tipSettings isEqual: @(1)])
    {
        NSString *tipAndTotal = [self htmlForTipAndTotal];
        if([invoiceDetailDict valueForKey:@"tipAmount"]){
            html = [html stringByReplacingOccurrencesOfString:@"$$TIPANDTOTAL$$" withString:[NSString stringWithFormat:@"%@",tipAndTotal]];
            html = [html stringByReplacingOccurrencesOfString:@"$$TIP$$" withString:[NSString stringWithFormat:@"%@",@""]];
            html = [html stringByReplacingOccurrencesOfString:@"$$TIPSWITHTOTAL$$" withString:[NSString stringWithFormat:@"%@",@""]];
        }
        else{
            html = [html stringByReplacingOccurrencesOfString:@"$$TIPANDTOTAL$$" withString:[NSString stringWithFormat:@"%@",@""]];
            html = [html stringByReplacingOccurrencesOfString:@"$$TIP$$" withString:[NSString stringWithFormat:@"%@",@""]];
            html = [html stringByReplacingOccurrencesOfString:@"$$TIPSWITHTOTAL$$" withString:[NSString stringWithFormat:@"%@",@""]];
        }
    }
    else
    {
        html = [html stringByReplacingOccurrencesOfString:@"$$TIPANDTOTAL$$" withString:[NSString stringWithFormat:@"%@",@""]];
        html = [html stringByReplacingOccurrencesOfString:@"$$TIP$$" withString:[NSString stringWithFormat:@"%@",@""]];
        html = [html stringByReplacingOccurrencesOfString:@"$$TIPSWITHTOTAL$$" withString:[NSString stringWithFormat:@"%@",@""]];
    }
    
    html = [html stringByReplacingOccurrencesOfString:@"$$TOTAL$$" withString:[self currencyFormattedStringForKey:@"totalAmount" dictionary:invoiceDetailDict]];
    html = [html stringByReplacingOccurrencesOfString:@"$$QTY$$" withString:[invoiceDetailDict valueForKey:@"qty"]];
    return html;
}

- (NSString *)htmlForTipAndTotal
{
    NSString *html = @"";
    html = [html stringByAppendingFormat:@"<div style=\" float:left; width:100%%; height: 15px;\"></div>"];
    html = [html stringByAppendingFormat:@"<div style=\"float:left;\">Tip &nbsp; :</div><div style=\" float:left; border-bottom:1px solid #000; ; width:75%%; height: 17px;\"></div>"];
    html = [html stringByAppendingFormat:@"<div style=\" float:left; width:100%%; height: 15px;\"></div>"];
    html = [html stringByAppendingFormat:@"<div style=\"float:left;\"><strong>Total</strong> &nbsp; :</div><div style=\" float:left; border-bottom:1px solid #000; ; width:71%%; height: 17px;\"></div>"];
    html = [html stringByAppendingFormat:@"<div style=\" float:left; width:100%%; height: 15px;\"></div>"];
    return html;
}

- (NSString *)generateHtmlForTips
{
    NSString *html = @"";
    float tipAmount = [self getSumOfTheValue:@"TipsAmount" forBillDetail:paymentDatailsArray];
    if (tipAmount > 0)
    {
    }
    else
    {
        if([tipSettings isEqual: @(1)]){
            if (arrTipsPercent.count>0) {
                html = [html stringByAppendingFormat:@"<table width=\"60%%\" align=\"center\">"];
                for(int i=0;i<arrTipsPercent.count;i++){
                    NSMutableDictionary *dicTips = arrTipsPercent[i];
                    html = [html stringByAppendingFormat:@"<tr><td width=\"100\">%@%%</td>",[dicTips valueForKey:@"TipsPercentage"]];
                    html = [html stringByAppendingFormat:@"<td width=\"100\">%@</td></tr>",[rmsDbController applyCurrencyFomatter:[dicTips valueForKey:@"TipsAmount"]]];
                }
                html = [html stringByAppendingFormat:@"</table>"];
            }
        }
    }
    return html;
}

-(NSString *)htmlBillFooter:(NSString *)html withChangeDue:(NSString *)changeDue
{
    NSString *strPayType =  [self checkPaymentTypeWithChangeDue:changeDue];
    html = [html stringByReplacingOccurrencesOfString:@"$$PAYMENT_TYPE$$" withString:strPayType];
//    if ([strPayType isEqualToString:@""]) {
//            html = [html stringByReplacingOccurrencesOfString:@"$$GIFTACCNO$$" withString:strPayType];
//    }
    return html;
}

-(NSString *)checkPaymentTypeWithChangeDue:(NSString *)changeDue{
    
    NSString *htmlpaymentData = @"";
    
    if([paymentDatailsArray isKindOfClass:[NSArray class]] && paymentDatailsArray.count > 0 ){
        for(int i = 0;i<paymentDatailsArray.count;i++)
        {
            NSString *strPaymentName = paymentDatailsArray[i][@"PayMode"] ;
            NSString *strAmount = paymentDatailsArray[i][@"BillAmount"] ;
            
            NSString *tipsAmount = paymentDatailsArray[i][@"TipsAmount"];
            
            NSNumber *numPayAmount = @(strAmount.floatValue + tipsAmount.floatValue);
            
            NSString *Amount =[self.crmController.currencyFormatter stringFromNumber:numPayAmount];
            strPaymentName = [NSString stringWithFormat:@"%@ Tendered :",strPaymentName];
            
            htmlpaymentData = [htmlpaymentData stringByAppendingFormat:@"<div style=\"float:left; width:100%%;\"><div style=\"float:right; text-align:left;\">%@</div><div style=\"float:right; \">%@</div></div>",Amount,strPaymentName];
            
            if ([paymentDatailsArray[i][@"PayMode"] isEqualToString:@"Demo Gift card"]) {
                
                NSString *strAccNo = paymentDatailsArray[i][@"AccNo"];
               
                htmlpaymentData = [htmlpaymentData stringByAppendingFormat:@"<div style=\"float:left; width:100%%;\"><div style=\"float:right; text-align:left;\">%@</div><div style=\"float:right; \">%@</div></div>",strAccNo,@"GiftCard Account No:"];
            }
            if([paymentDatailsArray[i][@"PayMode"] isEqualToString:@"Cash"])
            {
             //   NSString *strChagneDue = [changeDue stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
                NSNumber *numChangeAmount=@([self RemoveSymbolFromString:changeDue]);
                NSString *changeDueAmount =[self.crmController.currencyFormatter stringFromNumber:numChangeAmount];
                htmlpaymentData = [htmlpaymentData stringByAppendingFormat:@"<div style=\"float:left; width:100%%;\"><div style=\"float:right; text-align:left;\">%@</div><div style=\"float:right; \">%@</div></div>",changeDueAmount,@"Change Due :"];
            }
            
            if (/*[[paymentDatailsArray[i] valueForKey:@"AuthCode"]length]>0 &&*/
                [[paymentDatailsArray[i] valueForKey:@"CardType"]length]>0 && [[paymentDatailsArray[i] valueForKey:@"TransactionNo"]length]>0 && [[paymentDatailsArray[i] valueForKey:@"AccNo"]length]>0)
            {
                htmlpaymentData = [htmlpaymentData stringByAppendingFormat:@"<div style=\"float:left; width:100%%;\"><div style=\"float:right; text-align:left;\">%@</div><div style=\"float:right; \">Card Holder Name :   </div></div>",[self valueFromDictionary:paymentDatailsArray[i] forKeyIndex:ReceiptDataKeyCardHolderName]];
                
                htmlpaymentData = [htmlpaymentData stringByAppendingFormat:@"<div style=\"float:left; width:100%%;\"><div style=\"float:right; text-align:left;\">%@</div><div style=\"float:right; \">Card Number :   </div></div>",[self valueFromDictionary:paymentDatailsArray[i] forKeyIndex:ReceiptDataKeyCardAccNo]];
                
                if (![[self valueFromDictionary:paymentDatailsArray[i] forKeyIndex:ReceiptDataKeyAuthCode] isEqualToString:@"-"])
                {
                    htmlpaymentData = [htmlpaymentData stringByAppendingFormat:@"<div style=\"float:left; width:100%%;\"><div style=\"float:right; text-align:left;\">%@</div><div style=\"float:right; \">Auth Code   :  </div></div>",[self valueFromDictionary:paymentDatailsArray[i] forKeyIndex:ReceiptDataKeyAuthCode]];
                }
                
                if ([paymentDatailsArray[i][@"SignatureImage"] isKindOfClass:[NSData class]]) {
                    UIImage *imageFromData = [UIImage imageWithData:paymentDatailsArray[i][@"SignatureImage"]];
                    NSString *htmlImageData = [self getImageForHtmlBase64:imageFromData];
                    htmlpaymentData = [htmlpaymentData stringByAppendingFormat:@"%@",htmlImageData];
                }
                else if ([paymentDatailsArray[i][@"SignatureImage"] isKindOfClass:[NSString class]] && [paymentDatailsArray[i][@"SignatureImage"] length] > 0)
                {
                    NSData* data = [[NSData alloc] initWithBase64EncodedString:paymentDatailsArray[i][@"SignatureImage"] options:0];
                    
                    if (data == nil) {
                        data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",paymentDatailsArray[i][@"SignatureImage"]]]];

                    }
//                    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[[paymentDatailsArray objectAtIndex:i] objectForKey:@"SignatureImage"]]]];
                    UIImage *imageFromData = [UIImage imageWithData:data];
                    NSString *htmlImageData = [self getImageForHtmlBase64:imageFromData];
                    htmlpaymentData = [htmlpaymentData stringByAppendingFormat:@"%@",htmlImageData];
                }
            }
        }
    }
    return htmlpaymentData;
}

-(NSString *)writeDataOnCacheDirectory:(NSData *)data withHtml:(NSString *)html
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:html])
    {
        [[NSFileManager defaultManager] removeItemAtPath:html error:nil];
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths.firstObject;
    html = [documentsDirectory stringByAppendingPathComponent:@"CustomerDetail.html"];
    [data writeToFile:html atomically:YES];
    return html;
}

#pragma mark - TCP Printing

- (void)printInvoiceReceiptFromHtml:(NSString *)path withPort:portName portSettings:portSettings
{
    printJob = [[PrintJob alloc] initWithPort:portName portSettings:portSettings deviceName:@"" withDelegate:nil];
    [self LoadReceiptHtml:path];
}

-(void)LoadReceiptHtml:(NSString *)path{
    NSData *myData = [NSData dataWithContentsOfFile:path];
    NSString *stringHtml = [[NSString alloc] initWithData:myData encoding:NSUTF8StringEncoding];
    webViewForTCPPrinting = [[UIWebView alloc] initWithFrame:CGRectMake(0.0, 0.0, 576, 200)];
    webViewForTCPPrinting.delegate = self;
    [webViewForTCPPrinting loadHTMLString:stringHtml baseURL:nil];
}

#pragma mark - Web View Delegate

- (void)webViewDidStartLoad:(UIWebView *)webView{
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    CGFloat height = [webView stringByEvaluatingJavaScriptFromString:@"document.height"].floatValue;
    CGFloat width = [webView stringByEvaluatingJavaScriptFromString:@"document.width"].floatValue;
    CGRect frame = webView.frame;
    frame.size.height = height;
    frame.size.width = width;
    webView.frame = frame;
    [self printImagefromWebview:webView];
}

#pragma mark - Print Image From Html WebView

-(void)printImagefromWebview:(UIWebView *)pwebview{
    UIImage *img = [UIImage imageWithData:[self getImageFromView:pwebview]];
    UIImage *printImage = [self imageResize:img andResizeTo:CGSizeMake(img.size.width * 1.4, img.size.height * 1.4)];
    [printJob printImage:printImage];
    [printJob cutPaper:PC_PARTIAL_CUT_WITH_FEED];
    [printJob firePrint];
}

#pragma mark - Image Resizing

- (UIImage *)imageResize:(UIImage*)img andResizeTo:(CGSize)newSize
{
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 1.0);
    [img drawInRect:CGRectMake(-120,0,newSize.width,newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(NSData *)getImageFromView:(UIView *)view  // Mine is UIWebView but should work for any
{
    NSData *pngImg;
//    CGFloat max;
//    CGSize viewSize = [view bounds].size;
    
    // Get the size of the the FULL Content, not just the bit that is visible
    CGSize size = [view sizeThatFits:CGSizeZero];
    
    // Scale down if on iPad to something more reasonable
//    max = (viewSize.width > viewSize.height) ? viewSize.width : viewSize.height;
//    if( max > 960 )
//        scale = 960/max;
    
    UIGraphicsBeginImageContextWithOptions( size, YES, 1.0 );
    
    // Set the view to the FULL size of the content.
    view.frame = CGRectMake(0, 0, size.width, size.height);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    pngImg = UIImagePNGRepresentation(image);
    
    UIGraphicsEndImageContext();
    NSLog(@"Image size is  == %@",NSStringFromCGSize(image.size));
    return pngImg;    // Voila an image of the ENTIRE CONTENT, not just visible bit
}

#pragma mark - Bluetooth Printing
//// print receipt start ////

- (NSInteger)sectionAtSectionIndex:(NSInteger)sectionIndex {
    return [_sections[sectionIndex] integerValue];
}
- (void)printInvoiceReceiptForInvoiceNo:(NSString *)strInvoiceNo withChangeDue:(NSString *)changeDue withDelegate:(id)delegate
{
    receiptDataArray = [self sortedReceiptDataArray];
    if(receiptDataArray.count>0)
    {
        [self configureInvoiceReceiptSection];
        [self configurePrint:portSettingsForPrinter portName:portNameForPrinter withDelegate:delegate];
        strInvoice = strInvoiceNo;
        strChangeDue = changeDue;
        _printerWidth = 48;

        NSInteger sectionCount = _sections.count;
        for (int i = 0; i < sectionCount; i++) {
            ReceiptSection section = [self sectionAtSectionIndex:i];
            [self printHeaderForSection:section];
            [self printCommandForSectionAtIndex:i];
            [self printFooterForSection:section];
        }
        
        [self concludePrint];

//        int totlength = 48;  //star printer 48 char length fix
//        NSMutableData *commands = [[NSMutableData alloc] init];
//        [self generatePrintReceiptCommands:commands totlength:totlength forInvoice:strInvoiceNo withChangeDue:changeDue];
//        [PrinterFunctions sendCommand:commands portName:portNameForPrinter portSettings:portSettingsForPrinter timeoutMillis:10000 deviceName:@"Printer"];
    }
}

- (void)configurePrint:(NSString *)portSettings portName:(NSString *)portName withDelegate:(id)delegate
{
    BOOL isBlueToothPrinter = [portName isEqualToString:@"BT:Star Micronics"];
    
    if (isBlueToothPrinter) {
        printJob = [[PrintJob alloc] initWithPort:portName portSettings:portSettings deviceName:@"Printer" withDelegate:delegate];
        [printJob enableSlashedZero:YES];
    }
    else
    {
        printJob = [[RasterPrintJobBase alloc] initWithPort:portName portSettings:portSettings deviceName:@"Printer" withDelegate:delegate];
    }
}

- (void)concludePrint
{
    [printJob cutPaper:PC_PARTIAL_CUT_WITH_FEED];
    [printJob firePrint];
    printJob = nil;
}

-(void)printHeaderForSection:(NSInteger)section
{
    {
        switch (section) {
            case ReceiptSectionReceiptHeader:
                break;
                
            case ReceiptSectionReceiptInfo:
                break;
                
            case ReceiptSectionItemDetail:
                [printJob enableBold:YES];
                [printJob printSeparator];
                [self defaultFormatForItemDetail];
                [printJob printText1:@"SKU" text2:@"Description" text3:@"Total"];
                [printJob printSeparator];
                [printJob enableBold:NO];
                break;
                
            case ReceiptSectionTotalSaleDetail:
                break;
                
//            case ReceiptSectionTipDetail:
//                break;
                
            case ReceiptSectionCardDetail:
                break;
                
            case ReceiptSectionReceiptFooter:
                break;
                
            case ReceiptSectionBarcode:
                break;
                
            default:
                //      [_printJob printLine:[NSString stringWithFormat:@"Section Header - %@", @(section)]];
                break;
        }
    }
    
}

-(void)printCommandForSectionAtIndex:(NSInteger)sectionIndex
{
    NSArray *sectionFields = _fields[sectionIndex];
    NSInteger fieldCount = sectionFields.count;
    for (int i = 0; i < fieldCount; i++) {
        [self printCommandForFieldAtIndex:i sectionIndex:sectionIndex];
    }
}

- (void)printCommandForFieldAtIndex:(NSInteger)fieldIndex sectionIndex:(NSInteger)sectionIndex
{
    NSNumber *fieldNumber = _fields[sectionIndex][fieldIndex];
    ReceiptFeild fieldId = fieldNumber.integerValue;
    [self printFieldWithId:fieldId];
}

- (void)printFieldWithId:(NSInteger)fieldId
{
    switch (fieldId) {
        case ReceiptFieldStoreName:
            [self printStoreName];
            break;
            
        case ReceiptFieldAddressline1:
            [self printAddressLine1];
            break;
            
        case ReceiptFieldAddressline2:
           [self printAddressLine2];
            break;
            
        case ReceiptFieldReceiptName:
           [self printReceiptName];
            break;
            
        case ReceiptFieldInvoiceNo:
            [self printInvoiceNumber];
            break;
            
        case ReceiptFieldCashierAndRegisterName:
            [self printCashierAndRegister];
            break;
            
        case ReceiptFieldTransactionDate:
            [self printTrasactionDateAndTime];
            break;
            
        case ReceiptFieldPrintDate:
            [self printDateAndTime];
            break;
            
        case ReceiptFieldItemDetail:
            subtotal = 0;
            tax = 0;
            qty = 0;
            totalDiscount = 0;
            [self printItemDetail];
            break;
            
        case ReceiptFieldTotalQTY:
            [self printTotalQTY];
            break;
            
        case ReceiptFieldSubTotal:
            [self printSubTotal];
            break;
            
        case ReceiptFieldTax:
            [self printTax];
            break;
            
        case ReceiptFieldAmount:
            [self printAmount];
            break;
            
        case ReceiptFieldTip:
            [self printTip];
            break;
            
        case ReceiptFieldTotal:
            [self printTotal];
            break;
            
//        case ReceiptFieldTipArray:
//            [self printTipDetail];
//            break;
            
        case ReceiptFieldCashDetail:
            [self printCashDetailArray];
            break;
            
        case ReceiptFieldSignuture:
//            [self printSignuture];
            break;
            
            
        case ReceiptFieldDiscount:
            [self printDiscountFiled];
            break;
            
        case ReceiptFieldThanksMessage:
            [self printThanksMessage];
            break;
            
        case ReceiptFieldBarcode:
           [self printBarcode];
            break;
            
        default:
            NSLog(@"Implement Field - %@", @(fieldId));
            break;
    }
    
}

- (void)printStoreName {
    [printJob setTextAlignment:TA_CENTER];
    if ((rmsDbController.globalDict)[@"ReceiptMasterInfo"] && [(rmsDbController.globalDict)[@"ReceiptMasterInfo"] count] > 0) {
        [printJob printLine:(rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"StoreName"]];
    }
    else
    {
        [printJob printLine:[self branchInfoValueForKeyIndex:ReceiptDataKeyBranchName]];
    }
}

- (void)printAddressLine1 {
    [printJob setTextAlignment:TA_CENTER];
    NSString *addressLine1;
    if ((rmsDbController.globalDict)[@"ReceiptMasterInfo"] && [(rmsDbController.globalDict)[@"ReceiptMasterInfo"] count] > 0) {
        addressLine1 = [NSString stringWithFormat:@"%@", (rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"Address"]];
        
        NSArray *arrAddress = [addressLine1 componentsSeparatedByString:@"\r\n"];
        if(arrAddress.count == 1)
        {
            arrAddress = [addressLine1 componentsSeparatedByString:@","];
        }
        for (uint i=0; i < arrAddress.count ;i++)
        {
            NSString *address = [arrAddress objectAtIndex:i];
            [printJob printLine:address];
        }
    }
    else {
      addressLine1 = [NSString stringWithFormat:@"%@  , %@", [self branchInfoValueForKeyIndex:ReceiptDataKeyAddress1],[self branchInfoValueForKeyIndex:ReceiptDataKeyAddress2]];
        [printJob printLine:addressLine1];
    }
}

- (void)printAddressLine2 {
    [printJob setTextAlignment:TA_CENTER];
    if ((rmsDbController.globalDict)[@"ReceiptMasterInfo"] && [(rmsDbController.globalDict)[@"ReceiptMasterInfo"] count] > 0) {
        if ((rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"Email"] && [(rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"Email"] length] > 0) {
            NSString *email = [NSString stringWithFormat:@"%@", (rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"Email"]];
            NSString *phoneNo = [NSString stringWithFormat:@"%@", (rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"PhoneNo"]];
            [printJob printLine:email];
            [printJob printLine:phoneNo];
        }
        else
        {
            NSString *phoneNo = [NSString stringWithFormat:@"%@", (rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"PhoneNo"]];
            [printJob printLine:phoneNo];
        }
    }
    else {
        NSString *addressLine2 = [NSString stringWithFormat:@"%@ , %@ - %@", [self branchInfoValueForKeyIndex:ReceiptDataKeyCity],[self branchInfoValueForKeyIndex:ReceiptDataKeyState],[self branchInfoValueForKeyIndex:ReceiptDataKeyZipCode]];
        [printJob printLine:addressLine2];
    }
}

- (void)printReceiptName {
    [printJob setTextAlignment:TA_CENTER];
    [printJob enableInvertColor:YES];
    [printJob printLine:@" Sales Receipt "];

//    if([paymentDatailsArray isKindOfClass:[NSArray class]])
//    {
//        [printJob printLine:@" Sales Receipt "];
//    }
//    else{
//        [printJob printLine:@" Void Receipt "];
//    }
    if (self.isVoidInvoicePrint == TRUE) {
        [printJob printLine:@" Void "];
    }
    [printJob enableInvertColor:NO];
}

- (void)printInvoiceNumber {
    [printJob setTextAlignment:TA_LEFT];
    [printJob printLine:[NSString stringWithFormat:@"Invoice #: %@",strInvoice]];
    [printJob enableInvertColor:NO];
}

-(void)printCashierAndRegister
{
    NSString *strCashier = @"";
    NSString *strRegister = @"";
    if (self.isInvoiceReceipt) {
        strRegister = [NSString stringWithFormat:@"Register #: %@",self.registerName];
        strCashier = [NSString stringWithFormat:@"Cashier #: %@",self.cashierName];
    }
    else
    {
        NSString *salesPersonName=[NSString stringWithFormat:@"%@",[self userInfoValueForKeyIndex:ReceiptDataKeyUserName]];
        strCashier = [NSString stringWithFormat:@"Cashier #: %@",salesPersonName];

        strRegister = [NSString stringWithFormat:@"Register #: %@",(rmsDbController.globalDict)[@"RegisterName"]];
    }
    [self defaultFormatForCashierAndRegisterName];
    [printJob printText1:strCashier text2:strRegister];

}

-(void)printTrasactionDateAndTime
{
    [printJob setTextAlignment:TA_LEFT];
    if (strReceiptDate) {
        [printJob printLine:[NSString stringWithFormat:@"Trnx Date:%@",strReceiptDate]];
    }
}
-(void)printTransactionAccNo
{
    NSString *text = [[receiptDataArray valueForKey:@"CardNo"]firstObject];
    if([text isEqualToString:@""])
    {
        return;
    }
    else
    {
        [printJob printLine:[NSString stringWithFormat:@"GiftCard Account No:%@",text]];
    }
}

-(void)printDateAndTime
{
    [printJob setTextAlignment:TA_LEFT];
    NSDate * date = [NSDate date];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM/dd/yyyy";
    NSDateFormatter* timeFormatter = [[NSDateFormatter alloc] init];
    timeFormatter.dateFormat = @"hh:mm a";
    NSString *printDate = [dateFormatter stringFromDate:date];
    NSString *printTime = [timeFormatter stringFromDate:date];
    [printJob printLine:[NSString stringWithFormat:@"Current Date:%@ %@\r\n",printDate,printTime]];
}

- (void)printItemDetailWithDictionary:(NSDictionary *)receiptDictionary {
    NSString *text1 = [NSString stringWithFormat:@"%@", receiptDictionary[@"Barcode"]];
    
    NSString *text2 =[NSString stringWithFormat:@"%@", [self valueFromDictionary:receiptDictionary forKeyIndex:ReceiptDataKeyItemName]];
    
    iqty = [[self valueFromDictionary:receiptDictionary forKeyIndex:ReceiptDataKeyItemQty] intValue];
    NSString *text3;
    NSString *text4;
    
    float itemAmount = 0.00;
    float itemBasicAmount = 0.00;
    
    if ([receiptDictionary objectForKey:@"ItemBasicPrice"]) {
         itemAmount = [[receiptDictionary valueForKey:@"itemPrice"] floatValue];
         itemBasicAmount = [[receiptDictionary valueForKey:@"ItemBasicPrice"] floatValue];
    }
    else if ([receiptDictionary objectForKey:@"ItemBasicAmount"])
    {
        itemAmount = [[receiptDictionary valueForKey:@"ItemAmount"] floatValue];
        
        if ([[receiptDictionary valueForKey:@"VariationAmount"] floatValue]>0) {
            itemAmount  = itemAmount - [[receiptDictionary valueForKey:@"VariationAmount"] floatValue];
        }
        itemBasicAmount = [[receiptDictionary valueForKey:@"ItemBasicAmount"] floatValue];
    }
    
    if (iqty ==1)
    {
        float price = 0.00;
        if( (itemAmount > 0 && itemAmount > itemBasicAmount) || (itemAmount < 0 && itemAmount < itemBasicAmount))
        {
           price = itemAmount;
        }
        else
        {
            price = itemBasicAmount;
        }
        
        text3 =  [NSString stringWithFormat:@"%@",[self currencyFormattedStringForAmount:price]];
    }
    else
    {
        NSString *sQty=[NSString stringWithFormat:@"%d",[[self valueFromDictionary:receiptDictionary forKeyIndex:ReceiptDataKeyItemQty] intValue] ];
        NSString *spQty=[NSString stringWithFormat:@"%d",[[self valueFromDictionary:receiptDictionary forKeyIndex:ReceiptDataKeyItemQty] intValue] / [[receiptDictionary valueForKey:@"PackageQty"] intValue]];

        float totAmount = 0.00;
        float price1 = 0.00;

        if( (itemAmount > 0 && itemAmount > itemBasicAmount) || (itemAmount < 0 && itemAmount < itemBasicAmount))
        {
            totAmount  = sQty.integerValue * itemAmount;
            price1 = itemAmount * [[receiptDictionary valueForKey:@"PackageQty"] intValue];
        }
        else
        {
            totAmount  = sQty.integerValue * itemBasicAmount;
            price1 = itemBasicAmount * [[receiptDictionary valueForKey:@"PackageQty"] intValue] ;
        }
        text3 =  [NSString stringWithFormat:@"%@",[self currencyFormattedStringForAmount:totAmount]];
        text4 =  [NSString stringWithFormat:@"%@ X %.2f",spQty,price1];
    }
    
    [self defaultFormatForItemName:text2];
    
    if (iqty ==1){
    
            if(gasDetailAvailable == NO){
                [printJob printText1:text1 text2:text2 text3:text3];
            }
    }
    else{
        
        [printJob printText1:text1 text2:text2 text3:@""];
        [self defaultFormatForItemName:text4];
        [printJob printText1:@"" text2:text4 text3:text3];
    }
  //  [self setPackageQtyDetail:receiptDictionary];
    [self setVariationAmount:receiptDictionary];
    [self setFeesValue:receiptDictionary];
    //[self setGasInfoValue:receiptDictionary];
}

-(void)setPackageQtyDetail:(NSDictionary*)receiptDictionary
{
    
     //   NSInteger pckQty = [[self valueFromDictionary:receiptDictionary forKeyIndex:ReceiptDataKeyItemQty] intValue] / [[receiptDictionary valueForKey:@"PackageQty"] intValue] ;
     //   NSString *packageType = [NSString stringWithFormat: @"%ld %@" , (long)pckQty , [receiptDictionary valueForKey:@"PackageType"]];
        NSString *packageType = [NSString stringWithFormat: @"%@" , [receiptDictionary valueForKey:@"PackageType"]];
    
       [self defaultFormatForVariationColoum];
        [printJob printText1:@"" text2:packageType text3:@""];
}



- (void)printItemDetail {
#ifdef PRINT_A_FEW
    NSInteger count = 0;
#endif
    
    receiptDataArray = [self sortedReceiptDataArray];
    if(receiptDataArray.count > 0){
    for (NSDictionary *receiptDictionary in receiptDataArray) {
        NSString *item = [NSString stringWithFormat:@"%@", [self valueFromDictionary:receiptDictionary forKeyIndex:ReceiptDataKeyItemName]];
        if ([item isEqualToString:@"RapidRMS Gift Card"]) {
           
            [self printItemDetailWithDictionary:receiptDictionary];
            NSString *giftAccNo = [receiptDictionary valueForKey:@"CardNo"];
            [printJob printText1:@"" text2:[NSString stringWithFormat:@"Account No:%@",giftAccNo] text3:@""];
            
        }
        else
        {
        [self printItemDetailWithDictionary:receiptDictionary];
        }
#ifdef PRINT_A_FEW
            count++;
            if (count == 3)
            {
                
                break;
            }
#endif
            
        }
    }
    else
    {
        [printJob enableBold:YES];
        [printJob setTextAlignment:TA_CENTER];
        [printJob printLine:[NSString stringWithFormat:@"%@",@"Item Details Missing"]];
        [printJob enableBold:NO];
        [printJob printLine:@""];
    }
    
    [printJob printSeparator];
    
}

-(void)setVariationAmount:(NSDictionary*)receiptDictionary
{
    if([[self valueFromDictionary:receiptDictionary forKeyIndex:ReceiptDataKeyInvoiceVariationdetail] isKindOfClass:[NSArray class]])
    {
        NSArray *variationDetails = [self valueFromDictionary:receiptDictionary forKeyIndex:ReceiptDataKeyInvoiceVariationdetail];
        
        if (variationDetails.count >0)
        {
            for (int varItem =0 ; varItem < variationDetails.count; varItem++)
            {
                NSDictionary *variationDetail = variationDetails[varItem];
                
                NSString *variationName = [self valueFromDictionary:variationDetail forKeyIndex:ReceiptDataKeyVariationItemName];
                NSString *variationPrice = [self currencyFormattedStringForAmount:[[self valueFromDictionary:variationDetail forKeyIndex:ReceiptDataKeyVariationPrice] floatValue] * [[self valueFromDictionary:receiptDictionary forKeyIndex:ReceiptDataKeyItemQty] intValue]];
                [self defaultFormatForVariationColoum];
                [printJob printText1:@"" text2:variationName text3:variationPrice];
            }
        }
    }
}



-(void)setFeesValue:(NSDictionary*)receiptDictionary
{
    NSString *extraChargeString;
    if([receiptDictionary objectForKey:@"ExtraCharge"])
    {
        extraChargeString = [NSString stringWithFormat:@"%@",[self valueFromDictionary:receiptDictionary forKeyIndex:ReceiptDataKeyExtraCharge]];
    }
    else{
        extraChargeString = [NSString stringWithFormat:@"%@",[self valueFromDictionary:[self valueFromDictionary:receiptDictionary forKeyIndex:ReceiptDataKeyItem] forKeyIndex:ReceiptDataKeyExtraCharge]];

    }
        
    
 //  extraChargeString = [NSString stringWithFormat:@"%@",[self valueFromDictionary:[self valueFromDictionary:receiptDictionary forKeyIndex:ReceiptDataKeyItem] forKeyIndex:ReceiptDataKeyExtraCharge]];
    
  //  NSString *extraChargeString = [NSString stringWithFormat:@"%@",[self valueFromDictionary:receiptDictionary forKeyIndex:ReceiptDataKeyExtraCharge]];
    
    CGFloat extChargeAmount = [extraChargeString floatValue];
    NSMutableArray *reciptDataArray = [self valueFromDictionary:receiptDictionary forKeyIndex:ReceiptDataKeyItem];
    
    float fdiscAmt=[[self valueFromDictionary:receiptDictionary forKeyIndex:ReceiptDataKeyItemDiscount] floatValue];
    
    if(fdiscAmt != 0)
    {
        float fdistotprice=  fdiscAmt;
        
        totalDiscount+=fdistotprice;
        
        fdistotprice=-fdistotprice;// display negative amount
        
        NSNumber *doubledisAmount = [NSNumber numberWithDouble:fdistotprice];
        
        NSString *sdisamount = [self currencyFormattedStringForAmount:doubledisAmount.floatValue];
        
        if ([[self keyForIndex:ReceiptDataKeyItemDiscount] isEqualToString:@"ItemDiscountAmount"]) {
            float discount = [[self valueFromDictionary:receiptDictionary forKeyIndex:ReceiptDataKeyItemDiscount] floatValue];
            discount = -discount;// display negative amount
            NSNumber *discountAmount = @(discount);
            NSString *strDiscount = [self currencyFormattedStringForAmount:discountAmount.floatValue];
            [self defaultFormatForItemDetail];
            [printJob printText1:@"" text2:@"Discount" text3:strDiscount];
        }
        else
        {
            [self defaultFormatForItemDetail];
            [printJob printText1:@"" text2:@"Discount" text3:sdisamount];
        }
    }
    
    if ([[reciptDataArray valueForKey:@"isCheckCash"] boolValue]==YES)
    {
        float chkCheckcashAmount=[[reciptDataArray valueForKey:@"CheckCashCharge"] floatValue];
        NSString *strCheckCashAmount = [NSString stringWithFormat:@"%@",[self currencyFormattedStringForAmount:chkCheckcashAmount]];
        
        [self defaultFormatForItemDetail];
        [printJob printText1:@"" text2:@"Fee" text3:strCheckCashAmount];
        
        subtotal -= [[self valueFromDictionary:receiptDictionary forKeyIndex:ReceiptDataKeyItemQty] intValue]*[[self valueFromDictionary:receiptDictionary forKeyIndex:ReceiptDataKeyItemBasicPrice] floatValue];
        subtotal += chkCheckcashAmount;
    }
    else if ([[reciptDataArray valueForKey:@"isExtraCharge"] boolValue]==YES || extChargeAmount != 0.00)
    {
        [printJob setTextAlignment:TA_RIGHT];
        float totalExtchargeamt = 0.0;
        iqty=[[self valueFromDictionary:receiptDictionary forKeyIndex:ReceiptDataKeyItemQty] intValue];
        if ([[self keyForIndex:ReceiptDataKeyItemDiscount] isEqualToString:@"ItemDiscountAmount"]) {
            totalExtchargeamt = extChargeAmount;
            subtotal += extChargeAmount;
        }
        else
        {
            totalExtchargeamt = extChargeAmount * iqty;
            subtotal+=[[self valueFromDictionary:receiptDictionary forKeyIndex:ReceiptDataKeyItemQty] intValue]*extChargeAmount;
        }
        NSString *sExtprice=[NSString stringWithFormat:@"%@", [self currencyFormattedStringForAmount:totalExtchargeamt]];
        [self defaultFormatForItemDetail];
        [printJob printText1:@"" text2:@"Fee" text3:sExtprice];
        
    }
    else
    {
        
    }
    [printJob setTextAlignment:TA_LEFT];
    qty+=[[self valueFromDictionary:receiptDictionary forKeyIndex:ReceiptDataKeyItemQty] intValue]/[[receiptDictionary valueForKey:@"PackageQty"] intValue];
    if ([[reciptDataArray valueForKey:@"isCheckCash"] boolValue]==NO)
    {
        float BasicPrice;
        float itemAmount = 0.00;
        float itemBasicAmount = 0.00;
        
        if ([receiptDictionary objectForKey:@"ItemBasicPrice"]) {
            itemAmount = [[receiptDictionary valueForKey:@"itemPrice"] floatValue];
            itemBasicAmount = [[receiptDictionary valueForKey:@"ItemBasicPrice"] floatValue];
        }
        else if ([receiptDictionary objectForKey:@"ItemBasicAmount"])
        {
            itemAmount = [[receiptDictionary valueForKey:@"ItemAmount"] floatValue];
            
            if ([[receiptDictionary valueForKey:@"VariationAmount"] floatValue] > 0)
            {
                itemAmount  = itemAmount - [[receiptDictionary valueForKey:@"VariationAmount"] floatValue];
            }
            itemBasicAmount = [[receiptDictionary valueForKey:@"ItemBasicAmount"] floatValue];
        }
        
        if(iqty==1)
        {
            if( (itemAmount > 0 && itemAmount > itemBasicAmount) || (itemAmount < 0 && itemAmount < itemBasicAmount))
            {
                BasicPrice = itemAmount;
            }
            else
            {
                BasicPrice = itemBasicAmount;
            }
        }
        else
        {
            if( (itemAmount > 0 && itemAmount > itemBasicAmount) || (itemAmount < 0 && itemAmount < itemBasicAmount))
            {
                BasicPrice = itemAmount *[[self valueFromDictionary:receiptDictionary forKeyIndex:ReceiptDataKeyItemQty] intValue];
            }
            else
            {
                BasicPrice = itemBasicAmount *[[self valueFromDictionary:receiptDictionary forKeyIndex:ReceiptDataKeyItemQty] intValue];
            }
        }
        
        if(fdiscAmt != 0)
        {
            if ([[self keyForIndex:ReceiptDataKeyItemDiscount] isEqualToString:@"ItemDiscountAmount"]) {
                float discount = [[self valueFromDictionary:receiptDictionary forKeyIndex:ReceiptDataKeyItemDiscount] floatValue];
                BasicPrice = BasicPrice - discount;
            }
            else
            {
                float fdistotprice = fdiscAmt;
                
                BasicPrice = BasicPrice - fdistotprice;
            }
        }
        
        if(iqty==1)
        {
            subtotal+= (BasicPrice + [self variationCostForPrintbillEntryDictionary:receiptDictionary]) * [[self valueFromDictionary:receiptDictionary forKeyIndex:ReceiptDataKeyItemQty] intValue];
        }
        else{
            
            subtotal+= (BasicPrice + [self variationCostForPrintbillEntryDictionary:receiptDictionary]);
        }
    }
    tax+=[[self valueFromDictionary:receiptDictionary forKeyIndex:ReceiptDataKeyItemTax] floatValue];
}

-(void)printTotalQTY
{
    [printJob setTextAlignment:TA_LEFT];
    [printJob printLine:[NSString stringWithFormat:@"Total QTY :%d ", qty]];
}

-(void)printSubTotal
{
    [printJob setTextAlignment:TA_RIGHT];
    [printJob printLine:[NSString stringWithFormat:@"Subtotal : %@",[self currencyFormattedStringForAmount:subtotal]]];
}

-(void)printTax
{
    [printJob setTextAlignment:TA_RIGHT];
    [printJob printLine:[NSString stringWithFormat:@"Tax :%@",[self currencyFormattedStringForAmount:tax]]];
}

-(void)printAmount
{
    [printJob setTextAlignment:TA_RIGHT];
    float Amount = subtotal + tax;
    [printJob printLine:[NSString stringWithFormat:@"Amount :%@",[self currencyFormattedStringForAmount:Amount]]];
}

-(void)printTip
{
    float tipAmount = [self getSumOfTheValue:@"TipsAmount" forBillDetail:paymentDatailsArray];
    if (tipAmount>0)
    {
        [printJob setTextAlignment:TA_RIGHT];
        [printJob printLine:[NSString stringWithFormat:@"Tip :%@",[self currencyFormattedStringForAmount:tipAmount]]];
    }
    else
    {
        if([tipSettings isEqual: @(1)])
        {
        [printJob setTextAlignment:TA_RIGHT];
        [printJob printLine:@""];
        [printJob printLine:[NSString stringWithFormat:@"Tip :_______________________"]];
        }
    }
//    else
//    {
//        [printJob setTextAlignment:TA_RIGHT];
//        [printJob printLine:[NSString stringWithFormat:@"Tip :_______________________"]];
//    }
}

-(void)printTotal
{
    float tipAmount = [self getSumOfTheValue:@"TipsAmount" forBillDetail:paymentDatailsArray];
    
    if (tipAmount>0)
    {
        [printJob setTextAlignment:TA_RIGHT];
        float Total = subtotal + tax + tipAmount;
        [printJob printLine:[NSString stringWithFormat:@"Total :%@",[self currencyFormattedStringForAmount:Total]]];
    }
    else
    {
        if([tipSettings isEqual: @(1)])
        {
        [printJob setTextAlignment:TA_RIGHT];
        [printJob printLine:@""];
        [printJob printLine:[NSString stringWithFormat:@"Total :______________________"]];
        [printJob printLine:@""];
        [self printTipDetail];
        [printJob printLine:@""];

        }
    }

    [printJob printSeparator];
//    else
//    {
//        [printJob setTextAlignment:TA_RIGHT];
//        [printJob printLine:[NSString stringWithFormat:@"Total :______________________"]];
//    }
}

-(void)printTipDetail
{
    for(int i=0;i<arrTipsPercent.count;i++){
        NSMutableDictionary *dicTips = arrTipsPercent[i];
        NSString *strTipsPercentage = [NSString stringWithFormat:@"%@%%",[self valueFromDictionary:dicTips forKeyIndex:ReceiptDataKeyTipsPercentage]];
        NSString *strTipsAmount = [NSString stringWithFormat:@"%@",[self currencyFormattedStringForKey:receiptDataKeys[ReceiptDataKeyTipsAmount] dictionary:dicTips]];
        [self defaultFormatForTipsDetails];
        [printJob printText1:strTipsPercentage text2:@"" text3:strTipsAmount];
    }
}

-(CGFloat)RemoveSymbolFromString:(NSString *)stringToRemoveSymbol
{
    NSString *sAmount=[stringToRemoveSymbol stringByReplacingOccurrencesOfString:self.crmController.currencyFormatter.internationalCurrencySymbol withString:@""];
    CGFloat fsAmount = [[self.crmController.currencyFormatter numberFromString:sAmount] floatValue];
    return fsAmount;
}
-(void)printCashDetailArray
{
    if([paymentDatailsArray isKindOfClass:[NSArray class]] && paymentDatailsArray.count >0 ){
      
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"SignatureImage"
                                                      ascending:YES];
        paymentDatailsArray = [paymentDatailsArray sortedArrayUsingDescriptors:@[sortDescriptor]];
       
        [printJob setTextAlignment:TA_RIGHT];
        for(int i = 0;i<paymentDatailsArray.count;i++)
        {
            NSString *strPaymentName = paymentDatailsArray[i][@"PayMode"] ;
            NSString *strAmount = paymentDatailsArray[i][@"BillAmount"] ;
            
            NSString *tipsAmount = paymentDatailsArray[i][@"TipsAmount"];
            
            NSNumber *numPayAmount = @(strAmount.floatValue + tipsAmount.floatValue);
            
            NSString *Amount =[self.crmController.currencyFormatter stringFromNumber:numPayAmount];
            
            [printJob setTextAlignment:TA_RIGHT];
            [printJob printLine:[NSString stringWithFormat:@"%@ Tendered: %@",strPaymentName,Amount]];
           
            NSString *strCardType = paymentDatailsArray[i][@"CardType"];
            if([strCardType isEqualToString:@"RMSGiftCard"])
            {
                NSString * accNo = paymentDatailsArray[i][@"AccNo"];
                [printJob printLine:[NSString stringWithFormat:@"GiftCard Account No:%@",accNo]];
            }
            if([strPaymentName isEqualToString:@"Demo Gift card"])
            {
                
            }
            if([strPaymentName isEqualToString:@"Cash"])
            {
             //   NSString *strChagneDueDetail = [strChangeDue stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
                //[self RemoveSymbolFromString:strChangeDue]
                
                NSNumber *numChangeAmount=@([self RemoveSymbolFromString:strChangeDue]);
                NSString *changeDueAmount =[self.crmController.currencyFormatter stringFromNumber:numChangeAmount];
                [printJob setTextAlignment:TA_RIGHT];
                [printJob printLine:[NSString stringWithFormat:@"Change Due : %@",changeDueAmount]];
            }
            
            if(/*[[paymentDatailsArray[i] valueForKey:@"AuthCode"]length]>0 &&*/
               [[paymentDatailsArray[i] valueForKey:@"CardType"]length]>0 && [[paymentDatailsArray[i] valueForKey:@"TransactionNo"]length]>0 && [[paymentDatailsArray[i] valueForKey:@"AccNo"]length]>0)
            {
                [printJob setTextAlignment:TA_RIGHT];
                NSString *strCardholdername = [NSString stringWithFormat:@"Card Holder Name : %@",[paymentDatailsArray[i] valueForKey:@"CardHolderName"]];
                NSString *strcardNumber = [NSString stringWithFormat:@"Card Number : %@",[paymentDatailsArray[i] valueForKey:@"AccNo"]];
                [printJob printLine:strCardholdername];
                [printJob printLine:strcardNumber];

            
                
                if ([[paymentDatailsArray[i] valueForKey:@"GatewayType"]isKindOfClass:[NSString class]] && [[paymentDatailsArray[i] valueForKey:@"GatewayType"] isEqualToString:@"Pax"]) {
                    
                    if (paymentDatailsArray[i][@"GatewayResponse"])
                    {
//                        NSDictionary *paxAdditionalFieldsDictionary = [[paymentDatailsArray objectAtIndex:i] valueForKey:@"PaxAdditionalFields"];
                        NSDictionary *paxAdditionalFieldsDictionary = [self objectFromJsonString:[paymentDatailsArray[i] valueForKey:@"GatewayResponse"]];

//                        if (paxAdditionalFieldsDictionary != nil) {
//                            if ([[paxAdditionalFieldsDictionary valueForKey:@"EntryMode"] integerValue] == Swipe) {
//                                [self addPrintLineForEntryMode:@"EntryMode" forDictionary:paxAdditionalFieldsDictionary];
//                            }
//                            else
//                            {
                                [self addPrintLineForKey:@"AppName" forDictionary:paxAdditionalFieldsDictionary];
                                [self addPrintLineForKey:@"AID" forDictionary:paxAdditionalFieldsDictionary];
                                [self addPrintLineForKey:@"ARQC" forDictionary:paxAdditionalFieldsDictionary];
                                [self addPrintLineForEntryMode:@"EntryMode" forDictionary:paxAdditionalFieldsDictionary];
                                [self addPrintLineForKey:@"RemainingBalance" forDictionary:paxAdditionalFieldsDictionary];
                        
                        if ([strPaymentName isEqualToString:@"Debit"]) {
                            [printJob printLine:@"CVM: Debit/Pin"];
                        }
                        else
                        {
                            [self addPrintLineForCVM:@"CVM" forDictionary:paxAdditionalFieldsDictionary];
                        }
                        }
                    }
                }
                
                if (![[paymentDatailsArray[i] valueForKey:@"AuthCode"] isEqualToString:@"-"] && [[paymentDatailsArray[i] valueForKey:@"AuthCode"] length] > 0)
                {
                    NSString *strAuthCode =[NSString stringWithFormat:@"Auth Code : %@",[paymentDatailsArray[i] valueForKey:@"AuthCode"]];
                    [printJob printLine:strAuthCode];
                    [printJob printLine:@""];
                    
                }
                [self printSignutureWithDetail:paymentDatailsArray[i]];
            }
        }
    else
    {
        [printJob enableBold:YES];
        [printJob setTextAlignment:TA_CENTER];
        [printJob printLine:[NSString stringWithFormat:@"%@",@"Payment Details Missing"]];
        [printJob enableBold:NO];
        [printJob printLine:@""];

    }
}
-(id)objectFromJsonString:(NSString *)jsonString {
    NSError *error;
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    if (! jsonData) {
        return nil;
    }
    return [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves error:&error];
}

-(void)addPrintLineForKey:(NSString *)key forDictionary:(NSDictionary *)creditcardInformationDictionary
{
    if (creditcardInformationDictionary[key] && [[creditcardInformationDictionary valueForKey:key] length] > 0) {
        [printJob printLine:[NSString stringWithFormat:@"%@: %@",key,creditcardInformationDictionary[key]]];
    }
}
-(void)addPrintLineForEntryMode:(NSString *)key forDictionary:(NSDictionary *)creditcardInformationDictionary
{
    if (creditcardInformationDictionary[key] && [[creditcardInformationDictionary valueForKey:key] length] > 0) {
        int enterMode = [creditcardInformationDictionary[key] intValue];
        [printJob printLine:[NSString stringWithFormat:@"%@: %@",key,[self getStringFromEntryMode:enterMode]]];
    }
}

-(void)addPrintLineForCVM:(NSString *)key forDictionary:(NSDictionary *)creditcardInformationDictionary
{
    if (creditcardInformationDictionary[key] && [[creditcardInformationDictionary valueForKey:key] length] > 0) {
        int CVM = [creditcardInformationDictionary[key] intValue];
        [printJob printLine:[NSString stringWithFormat:@"%@: %@",key,[self getStringFromCVM:CVM]]];
    }
}

-(NSString *)getStringFromEntryMode:(EntryMode) entryMode{
    switch (entryMode) {
        case Manual:
            return @"Manual";
            break;
        case Swipe:
            return @"Swipe";
            break;
        case Contactless:
            return @"Contactless";
            break;
        case Scanner:
            return @"Scanner";
            break;
        case Chip:
            return @"Chip";
            break;
        case ChipFallBackSwipe:
            return @"ChipFallBackSwipe";
            break;
            
        default:
            return @"";
            break;
    }
}



-(NSString *)getStringFromCVM:(CVMType) cvmType{
    
    switch (cvmType) {
        case  FailCVMProcessing:
        case  PlaintextOfflinePINandSignature:
        case  EncipheredOfflinePINVerificationandSignature:
        case  Signature:
            return @"Signature";
            break;
            
        case  PlaintextOfflinePINVerification:
        case  OnlinePIN:
        case  EncipheredOfflinePINVerification:
            return @"PIN";
            break;
            
        default:
            return @"";
            break;
    }
}



-(void)printSignutureWithDetail:(NSMutableDictionary *)paymentDetail
{

    UIImage *customerSignature ;
    if ([[paymentDetail valueForKey:@"SignatureImage"] isKindOfClass:[NSData class]]) {
            NSData *imagedata = [paymentDetail valueForKey:@"SignatureImage"];
            customerSignature = [UIImage imageWithData:imagedata];
    }
    else if ([[paymentDetail valueForKey:@"SignatureImage"] isKindOfClass:[NSString class]] &&  [paymentDetail[@"SignatureImage"] length] > 0)
    {
        
        NSData* data = [[NSData alloc] initWithBase64EncodedString:paymentDetail[@"SignatureImage"] options:0];
        
        if (data == nil) {
            data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",paymentDetail[@"SignatureImage"]]]];
            
        }
//        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[paymentDetail valueForKey:@"SignatureImage"]]]];
        customerSignature = [UIImage imageWithData:data];
    }
    
    if(customerSignature != nil)
    {
        [printJob setTextAlignment:TA_CENTER];   // Alignment(center)
        [printJob printImage:customerSignature];
        NSString *line = [[NSString string] stringByPaddingToLength:45 withString:@"-" startingAtIndex:0];
        NSString *strLine = [NSString stringWithFormat:@"X %@",line];
        [printJob printLine:strLine];
        [self printAgreementText];
       
        [printJob printLine:@""];
        
        [printJob setTextAlignment:TA_CENTER]; 
        NSString *line1 = [[NSString string] stringByPaddingToLength:48 withString:@"-" startingAtIndex:0];
        [printJob printLine:line1];

        [printJob printLine:@""];
        
    }
    else
    {
        [printJob printLine:@""];
    }
    
    
    
   //    if ([imageURL isEqual:[NSNull null]] && imageURL == nil)
    //    {
    //    }
    //    else
    //    {
    //        if([imageURL isKindOfClass:[NSString class]]){
    //            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
    //            if(!imageData)
    //            {
    //                imageData = [[NSData alloc] initWithBase64EncodedString:imageURL options:0];
    //            }
    //            customerSignatureImage = [[UIImage alloc] initWithData:imageData];
    //        }
    //        else{
    //            NSData *imageData = (NSData *)imageURL;
    //            customerSignatureImage = [[UIImage alloc] initWithData:imageData];
    //        }
    //    }
    //
    //    if(customerSignatureImage != nil)
    //    {
    //        [printJob setTextAlignment:TA_CENTER];   // Alignment(center)
    //        [printJob printImage:customerSignatureImage];
    //        NSString *line = [[NSString string] stringByPaddingToLength:45 withString:@"-" startingAtIndex:0];
    //        NSString *strLine = [NSString stringWithFormat:@"X %@",line];
    //        [printJob printLine:strLine];
    //        [self printAgreementText];
    //    }
    //    else
    //    {
    //        [printJob printLine:@""];
    //    }
}

-(void)printAgreementText
{
    [printJob setTextAlignment:TA_LEFT];
    [printJob printLine:[NSString stringWithFormat:@"I AGREE TO PAY ABOVE TOTAL AMOUNT ACCORDING TO"]];
    [printJob printLine:[NSString stringWithFormat:@"CARD ISSUER AGREEMENT."]];
}

-(void)printDiscountFiled
{
    NSString *strDiscount = [self discountTotalForReceipt];
    float discount = [rmsDbController removeCurrencyFomatter:strDiscount];
    if (discount != 0 && discount>0)
    {
        [printJob setTextAlignment:TA_CENTER];
        [printJob enableInvertColor:YES];
        [printJob printLine:[NSString stringWithFormat:@" You Saved : %@ ",strDiscount]];
        [printJob enableInvertColor:NO];
    }
}

- (NSMutableAttributedString *)attributedStringWithBiggerSizeOfFontFromString:(NSString *)string
{
    NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc] initWithData:[string dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType  } documentAttributes:nil error:nil];
    
    [attrStr enumerateAttributesInRange: NSMakeRange(0, attrStr.string.length)
                                options:NSAttributedStringEnumerationReverse usingBlock:
     ^(NSDictionary *attributes, NSRange range, BOOL *stop) {
         UIFont *font = [attributes valueForKey:@"NSFont"];
         UIFont *newFont = [UIFont fontWithName:font.fontName size:25];
         [attrStr addAttribute:NSFontAttributeName value:newFont range:range];
     }];
    return attrStr;
}

-(void)printThanksMessage
{
    [printJob setTextAlignment:TA_CENTER];

    if ((rmsDbController.globalDict)[@"ReceiptMasterInfo"] && [(rmsDbController.globalDict)[@"ReceiptMasterInfo"] count] > 0 && (rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"ThanksNote"] && [(rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"ThanksNote"] length] > 0) {
        NSString *thanksMessage = [NSString stringWithFormat:@"%@", (rmsDbController.globalDict)[@"ReceiptMasterInfo"] [@"ThanksNote"]];
//        NSMutableAttributedString *attrStr = [self attributedStringWithBiggerSizeOfFontFromString:thanksMessage];
//        [printJob beginRasterModePrinting];
//        //[printJob printAttributedStringLine:attrStr];
//        [printJob endRasterModePrinting];
        
        NSArray *arrThanks = [thanksMessage componentsSeparatedByString:@"\r\n"];
        
        for (uint i=0; i < arrThanks.count ;i++)
        {
            NSString *strThanks = [arrThanks objectAtIndex:i];
            [printJob printLine:strThanks];
        }
        
    }
    else {
        if ([[self branchInfoValueForKeyIndex:ReceiptDataKeyHelpMessage1] length]>0)
        {
            [printJob printLine:[NSString stringWithFormat:@"%@",[self branchInfoValueForKeyIndex:ReceiptDataKeyHelpMessage1]]];
        }
        [printJob printLine:[NSString stringWithFormat:@"%@",[self branchInfoValueForKeyIndex:ReceiptDataKeyBranchName]]];
        if ([[self branchInfoValueForKeyIndex:ReceiptDataKeyHelpMessage2] length]>0)
        {
            [printJob printLine:[NSString stringWithFormat:@"%@",[self branchInfoValueForKeyIndex:ReceiptDataKeyHelpMessage2]]];
        }
        if ([[self branchInfoValueForKeyIndex:ReceiptDataKeyHelpMessage3] length]>0)
        {
            [printJob printLine:[NSString stringWithFormat:@"%@",[self branchInfoValueForKeyIndex:ReceiptDataKeyHelpMessage3]]];
        }
    }
}

- (NSArray *)segmentsForText:(NSAttributedString*)text width:(NSUInteger)width {
    NSMutableArray *text1Segments = [NSMutableArray array];

//    if (text.length == 0) {
//        return text1Segments;
//    }
//    
//    width = MIN(width, text.length);
//    NSRange segmentRange;
//    segmentRange.location = 0;
//    segmentRange.length = width;
//    
//    if (text.length) {
//        [text enumerateAttributesInRange: segmentRange
//                                 options:NSAttributedStringEnumerationReverse usingBlock:
//         ^(NSDictionary *attributes, NSRange range, BOOL *stop) {
//                     text = [text s];
//         }];
//    }
    
//    for (NSString *segment = [text substringWithRange:segmentRange]; segment.length != 0; segment = [text substringWithRange:segmentRange]) {
//        [text1Segments addObject:segment];
//        
//        text = [text substringFromIndex:segmentRange.length];
//        width = MIN(width, text.length);
//        segmentRange.location = 0;
//        segmentRange.length = width;
//    }

    return text1Segments;
}

-(void)printBarcode
{
    [printJob setTextAlignment:TA_CENTER];
    [printJob printBarCode:strInvoice];

    if([printJob isKindOfClass:[RasterPrintJob class]]){
        [printJob printLine:strInvoice];
    }
}

//// footerSection
- (void)printFooterForSection:(NSInteger)section {
    switch (section) {
        case ReceiptSectionReceiptHeader:
            [printJob printLine:@""];
            break;
            
        case ReceiptSectionReceiptInfo:
            break;
            
        case ReceiptSectionItemDetail:
            break;
            
        case ReceiptSectionTotalSaleDetail:
            [printJob printLine:@""];
            break;
            
//        case ReceiptSectionTipDetail:
//            [printJob printLine:@""];
//            break;
            
        case ReceiptSectionCardDetail:
            [printJob printLine:@""];
            break;
            
        case ReceiptSectionReceiptFooter:
            [printJob printLine:@""];
            break;
            
        case ReceiptSectionBarcode:
            [printJob printLine:@""];
            break;
            
            default:
            break;
    }
}

- (NSString*)currencyFormattedAmount:(NSNumber*)amount {
    if (![amount isKindOfClass:[NSNumber class]]) {
        if ([amount isKindOfClass:[NSString class]]) {
            amount = @(amount.floatValue);
        }
    }
    NSString *formattedAmount = [rmsDbController.currencyFormatter stringFromNumber:amount];
    return formattedAmount;
}

- (void)defaultFormatForTipsDetails
{
    columnWidths[0] = 23;
    columnWidths[1] = 0;
    columnWidths[2] = 23;
    columnAlignments[0] = RPAlignmentRight;
    columnAlignments[1] = RPAlignmentLeft;
    columnAlignments[2] = RPAlignmentLeft;
    [printJob setColumnWidths:columnWidths columnAlignments:columnAlignments];
}

- (void)defaultFormatForTwoColumn
{
    columnWidths[0] = 23;
    columnWidths[1] = 23;
    columnAlignments[0] = RPAlignmentLeft;
    columnAlignments[1] = RPAlignmentRight;
    [printJob setColumnWidths:columnWidths columnAlignments:columnAlignments];
}

- (void)defaultFormatForReceptInfo
{
    columnWidths[0] = 18;
    columnWidths[1] = 29;
    columnAlignments[0] = RPAlignmentLeft;
    columnAlignments[1] = RPAlignmentRight;
    [printJob setColumnWidths:columnWidths columnAlignments:columnAlignments];
}

- (void)defaultFormatForCashierAndRegisterName
{
    columnWidths[0] = 25;
    columnWidths[1] = 22;
    columnAlignments[0] = RPAlignmentLeft;
    columnAlignments[1] = RPAlignmentRight;
    [printJob setColumnWidths:columnWidths columnAlignments:columnAlignments];
}

- (void)defaultFormatForTipDetail
{
    columnWidths[0] = 18;
    columnWidths[1] = 18;
    columnAlignments[0] = RPAlignmentRight;
    columnAlignments[1] = RPAlignmentLeft;
    [printJob setColumnWidths:columnWidths columnAlignments:columnAlignments];
}

- (void)defaultFormatForThreeColumn
{
    columnWidths[0] = 15;
    columnWidths[1] = 16;
    columnWidths[2] = 15;
    columnAlignments[0] = RPAlignmentLeft;
    columnAlignments[1] = RPAlignmentRight;
    columnAlignments[2] = RPAlignmentRight;
    [printJob setColumnWidths:columnWidths columnAlignments:columnAlignments];
}

- (void)defaultFormatForVariationColoum
{
    columnWidths[0] = 15;
    columnWidths[1] = 16;
    columnWidths[2] = 15;
    columnAlignments[0] = RPAlignmentLeft;
    columnAlignments[1] = RPAlignmentLeft;
    columnAlignments[2] = RPAlignmentRight;
    [printJob setColumnWidths:columnWidths columnAlignments:columnAlignments];
}


- (void)defaultFormatForFourColumn
{
    columnWidths[0] = 7;
    columnWidths[1] = 18;
    columnWidths[2] = 7;
    columnWidths[3] = 13;
    columnAlignments[0] = RPAlignmentLeft;
    columnAlignments[1] = RPAlignmentRight;
    columnAlignments[2] = RPAlignmentLeft;
    columnAlignments[3] = RPAlignmentRight;
    [printJob setColumnWidths:columnWidths columnAlignments:columnAlignments];
}


- (void)defaultFormatForItemDetail
{
    columnWidths[0] = 15;
    columnWidths[1] = 17;
    columnWidths[2] = 14;
    columnAlignments[0] = RPAlignmentLeft;
    columnAlignments[1] = RPAlignmentLeft;
    columnAlignments[2] = RPAlignmentRight;
    [printJob setColumnWidths:columnWidths columnAlignments:columnAlignments];
}

- (void)defaultFormatForItemName:(NSString *)strItemName
{
    BOOL isSpecialChar = [self isSpecialCharacterAvailableInString:strItemName];
  
    columnWidths[0] = 15;

    if (isSpecialChar)
    {
        columnWidths[1] = 17;

        NSInteger textlength = strItemName.length;
        if (textlength >= 12)
        {
            columnWidths[2] = 11;
        }
        else
        {
            columnWidths[2] = 13;
        }
    }
    else
    {
        columnWidths[1] = 18;
        columnWidths[2] = 13;
    }
    columnAlignments[0] = RPAlignmentLeft;
    columnAlignments[1] = RPAlignmentLeft;
    columnAlignments[2] = RPAlignmentRight;
    [printJob setColumnWidths:columnWidths columnAlignments:columnAlignments];
}

-(BOOL)isSpecialCharacterAvailableInString:(NSString *)string
{
    BOOL isSpecialChar = FALSE;
    NSString *strSpecial = @"ã å ā à á â ä æ š ß ś ż ž ź č ç ć ñ ń ł ė ę ē ê è é ë ÿ ū ù û ü ú ì į í î ï ī ò œ ô ö ó õ ø ō";
    NSArray *arrSpecialChar = [strSpecial componentsSeparatedByString:@" "];
    
    for (NSString * specialChar in arrSpecialChar)
    {
        if ([string rangeOfString:specialChar].location == NSNotFound)
        {
            isSpecialChar = FALSE;
        }
        else
        {
            isSpecialChar = TRUE;
            break;
        }
    }
    return isSpecialChar;
}

-(CGFloat)getSumOfTheValue:(NSString *)key forBillDetail:(NSArray *)billDetailArray
{
    CGFloat sum  = 0.00;
    if([billDetailArray isKindOfClass:[NSArray class]] && billDetailArray.count > 0){
        for (NSDictionary *dictionary in billDetailArray) {
            sum += [[dictionary valueForKey:key] floatValue];
        }
    }
    return sum;
}

- (float)variationCostForPrintbillEntryDictionary:(NSDictionary *)billEntryDictionary
{
    float variationCost=0.0;
    if([[self valueFromDictionary:billEntryDictionary forKeyIndex:ReceiptDataKeyInvoiceVariationdetail] isKindOfClass:[NSArray class]])
    {
        variationCost = [[(NSArray *)[self valueFromDictionary:billEntryDictionary forKeyIndex:ReceiptDataKeyInvoiceVariationdetail] valueForKeyPath:@"@sum.Price"] floatValue];
        variationCost = variationCost * [[self valueFromDictionary:billEntryDictionary forKeyIndex:ReceiptDataKeyVariationQty] floatValue];
    }
    return variationCost;
}

- (NSString *)currencyFormattedStringForKey:(NSString *)key dictionary:(NSDictionary *)dictionary
{
    return [rmsDbController applyCurrencyFomatter:dictionary[key]];
}

- (NSString *)currencyFormattedStringForAmount:(float)amount
{
    return [rmsDbController.currencyFormatter stringFromNumber:@(amount)];
}

//// print receipt end ////

-(NSArray *)sortedReceiptDataArray
{
    for (NSDictionary *dict in receiptDataArray) {
        if ([dict objectForKey:@"RowPosition"])
        {
            isSorting = TRUE;
            continue;
        }
        else
        {
            isSorting = FALSE;
        }
    }
    NSSortDescriptor *sorting = [[NSSortDescriptor alloc]initWithKey:@"itemIndex" ascending:YES];

    if (isSorting) {
        sorting = [[NSSortDescriptor alloc]initWithKey:@"RowPosition" ascending:YES];
    }
    NSArray *sortDescriptors = [NSArray arrayWithObject:sorting];
    NSArray *sortedArray = [receiptDataArray sortedArrayUsingDescriptors:sortDescriptors];
    return sortedArray;
}

@end
