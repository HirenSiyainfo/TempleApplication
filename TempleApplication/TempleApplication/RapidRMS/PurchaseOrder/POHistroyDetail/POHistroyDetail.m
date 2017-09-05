//
//  POHistroyDetail.m
//  RapidRMS
//
//  Created by Siya10 on 13/10/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "POHistroyDetail.h"
#import "RmsDbController.h"
#import "POOrderDetailCell.h"
#import "Item+Dictionary.h"
#import "RimLoginVC.h"
#import "POOrderItemInfo.h"
#import "EmailFromViewController.h"

@interface POHistroyDetail ()<UpdateDelegate,UIDocumentInteractionControllerDelegate,NDHTMLtoPDFDelegate>
{
     POOrderItemInfo *poOrderItemInfo;
     CGPoint infoButtonPosition;
}
@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) UpdateManager *updateManager;

@property (nonatomic, strong) NSManagedObjectContext *manageObjectContext;
@property (nonatomic, strong) RapidWebServiceConnection *poOrderHistroyDetail;
@property (nonatomic, strong) RapidWebServiceConnection *itemInfoWC;

@property (nonatomic, strong) NSMutableArray *orderHistroyDetailData;

@property (nonatomic,weak) IBOutlet UITableView *tblOrderHistroyDetail;
@property (nonatomic,weak) IBOutlet UILabel *poNumber;
@property (nonatomic,weak) UIButton *source;
@property (nonatomic, strong) NSString *emaiItemHtml;

@property (nonatomic, strong) NDHTMLtoPDF *PDFCreator;
@property (nonatomic, strong) UIDocumentInteractionController *controller;

@end

@implementation POHistroyDetail
@synthesize closeOrderDict;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.poOrderHistroyDetail = [[RapidWebServiceConnection alloc]init];
    self.itemInfoWC = [[RapidWebServiceConnection alloc]init];
    self.poNumber.text = self.closeOrderDict[@"PO_No"];
    self.updateManager = [[UpdateManager alloc] initWithManagedObjectContext:self.rmsDbController.managedObjectContext delegate:self];
    self.manageObjectContext = self.rmsDbController.managedObjectContext;
    [self orderHistroyDetail];
}

- (void)orderHistroyDetail
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    NSMutableDictionary *itemparam=[[NSMutableDictionary alloc]init];
    [itemparam setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    [itemparam setValue:[closeOrderDict valueForKey:@"PurchaseOrderId"] forKey:@"PoId"];
    itemparam[@"OpenOrderId"] = closeOrderDict[@"OpenOrderId"];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [self getClickedPODataResponse:response error:error];
        });
    };
    
    self.poOrderHistroyDetail = [self.poOrderHistroyDetail initWithRequest:KURL actionName:WSM_PO_ITEM_INFO params:itemparam completionHandler:completionHandler];
}

- (void)getClickedPODataResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil)
    {
        if ([response isKindOfClass:[NSDictionary class]])
        {
            if ([[response  valueForKey:@"IsError"] intValue] == 0)
            {
                NSMutableArray *arrtempPoData = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                self.orderHistroyDetailData = arrtempPoData[0][@"lstItem"];
                [self.tblOrderHistroyDetail reloadData];

            }
            else
            {
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:@"No record found close order." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  150.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.orderHistroyDetailData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    POOrderDetailCell *poOrderDetailcell = (POOrderDetailCell *)[tableView dequeueReusableCellWithIdentifier:@"POOrderDetailCell"];
    poOrderDetailcell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSDictionary *orderItemDict = self.orderHistroyDetailData[indexPath.row];
    
    Item *anItem = (Item *)[self.updateManager __fetchEntityWithName:@"Item" key:@"itemCode" value:orderItemDict[@"ItemId"] shouldCreate:NO moc:self.manageObjectContext];
    poOrderDetailcell.RqSingle.text = [NSString stringWithFormat:@"%@", orderItemDict[@"ReOrder"]];
    if(anItem){
       [poOrderDetailcell configureItemDetail:orderItemDict withItem:anItem];
    }
    poOrderDetailcell.RqCashPack.text = [NSString stringWithFormat:@"%@/%@",orderItemDict[@"ReOrderCase"],orderItemDict[@"ReOrderPack"]];
    [poOrderDetailcell.buttonAction addTarget:self action:@selector(itemInfoTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    return poOrderDetailcell;
}

-(void)itemInfoTapped:(id)sender
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    self.source =  sender;
    infoButtonPosition = [sender convertPoint:CGPointZero toView:self.tblOrderHistroyDetail];
    
    NSMutableDictionary *itemparam=[[NSMutableDictionary alloc]init];
    [itemparam setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    [itemparam setValue:[(self.orderHistroyDetailData)[[sender tag]] valueForKey:@"ItemId"] forKey:@"ItemId"];
    
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *strDateTime = [formatter stringFromDate:date];
    
    [itemparam setValue:strDateTime forKey:@"LocalDateTime"];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [self getItemInfoResponse:response error:error];
        });
    };
    
    self.itemInfoWC = [self.itemInfoWC initWithRequest:KURL actionName:WSM_PO_ITEM_INFO params:itemparam completionHandler:completionHandler];
}

-(void)getItemInfoResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil)
    {
        if ([response isKindOfClass:[NSDictionary class]])
        {
            if ([[response  valueForKey:@"IsError"] intValue] == 0)
            {
                NSMutableArray *arrSelectedItemInfo = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"PurchaseOrder_iPhone" bundle:nil];
                poOrderItemInfo = [storyBoard instantiateViewControllerWithIdentifier:@"POOrderItemInfo"];
                poOrderItemInfo.orderitemInfo = arrSelectedItemInfo.firstObject;
                poOrderItemInfo.view.frame = CGRectMake(0.0, 150.0, 320.0, 259.0);
                [poOrderItemInfo presentViewControllerForviewConteroller:self sourceView:self.source ArrowDirection:UIPopoverArrowDirectionLeft];
            }
            
        }
        else
        {
            UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
            {
                
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:[response  valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
        }
    }
}

#pragma mark Open More Option

-(IBAction)openMoreOption:(id)sender{
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"MORE" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Email" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        if(self.orderHistroyDetailData.count>0)
        {
            [self htmlBillText:self.orderHistroyDetailData];
            
        }
        
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Preview" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        if(self.orderHistroyDetailData.count>0)
        {
            [self htmlBillTextForPreview:self.orderHistroyDetailData];
        }
        
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }]];
    [self presentViewController:actionSheet animated:YES completion:nil];
}

-(void)htmlBillText:(NSMutableArray *)arryInvoice
{
    self.emaiItemHtml = [[NSBundle mainBundle] pathForResource:@"purchaseorderitem" ofType:@"html"];
    self.emaiItemHtml = [NSString stringWithContentsOfFile:self.emaiItemHtml encoding:NSUTF8StringEncoding error:nil];
    
    self.emaiItemHtml = [self htmlBillHeader:self.emaiItemHtml invoiceArray:arryInvoice];
    
    // set Html itemDetail
    NSString *itemHtml = [self htmlBillTextForItem:[arryInvoice.firstObject valueForKey:@"lstItem"]];
    self.emaiItemHtml = [self.emaiItemHtml stringByReplacingOccurrencesOfString:@"$$ITEM_HTML$$" withString:[NSString stringWithFormat:@"%@",itemHtml]];
    
    /// Write Data On Document Directory.......
    NSData* data = [self.emaiItemHtml dataUsingEncoding:NSUTF8StringEncoding];
    [self writeDataOnCacheDirectory:data];
    
    EmailFromViewController *objEmail = [[EmailFromViewController alloc]initWithNibName:@"EmailFromViewController" bundle:nil];
    
    NSData *myData = [NSData dataWithContentsOfFile:self.emaiItemHtml];
    NSString *stringHtml = [[NSString alloc] initWithData:myData encoding:NSUTF8StringEncoding];
    
    NSString *strsubjectLine = @"";
    
    objEmail.dictParameter =[[NSMutableDictionary alloc]init];
    (objEmail.dictParameter)[@"BranchID"] = [self.rmsDbController.globalDict valueForKey:@"BranchID"];
    (objEmail.dictParameter)[@"Subject"] = strsubjectLine;
    (objEmail.dictParameter)[@"InvoiceNo"] = @"";
    (objEmail.dictParameter)[@"postfile"] = myData;
    (objEmail.dictParameter)[@"HtmlString"] = stringHtml;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self presentViewController:objEmail animated:YES
                         completion:nil];
    });
    
}

-(void)writeDataOnCacheDirectory :(NSData *)data
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.emaiItemHtml])
    {
        [[NSFileManager defaultManager] removeItemAtPath:self.emaiItemHtml error:nil];
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths.firstObject;
    self.emaiItemHtml = [documentsDirectory stringByAppendingPathComponent:@"ReconcileItemList.html"];
    [data writeToFile:self.emaiItemHtml atomically:YES];
}

-(NSString *)htmlBillHeader:(NSString *)html invoiceArray:(NSMutableArray *)arrayInvoice
{
    html = [html stringByReplacingOccurrencesOfString:@"$$MENUOPERATION$$" withString:[NSString stringWithFormat:@"Vendor List"]];
    
    html = [html stringByReplacingOccurrencesOfString:@"$$BRANCH_NAME$$" withString:[NSString stringWithFormat:@"%@",[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"BranchName"]
                                                                                     ]];
    html = [html stringByReplacingOccurrencesOfString:@"$$ADDRESS$$" withString:[NSString stringWithFormat:@"%@%@",[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"Address1"],[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"Address2"]]];
    
    html =  [html stringByReplacingOccurrencesOfString:@"$$STATE_CITY_ZIPCODE$$" withString:[NSString stringWithFormat:@"%@%@%@",[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"City"],[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"State"],[[self.rmsDbController.globalDict valueForKey:@"BranchInfo"] valueForKey:@"ZipCode"]]];
    
    NSString *userName = [self.rmsDbController userNameOfApp];
    html = [html stringByReplacingOccurrencesOfString:@"$$USER_NAME$$" withString:[NSString stringWithFormat:@"%@",userName]];
    
    html = [html stringByReplacingOccurrencesOfString:@"$$REGISTER_NAME$$" withString:[NSString stringWithFormat:@"%@",(self.rmsDbController.globalDict)[@"RegisterName"]]];
    
    //    NSString  *Datetime = [NSString stringWithFormat:@"%@",[[arrayInvoice firstObject] valueForKey:@"CreatedDate"]];
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString  *currentDateTime = [formatter stringFromDate:date];
    NSString *strTime = [self getStringFormate:currentDateTime fromFormate:@"MM/dd/yyyy hh:mm a" toFormate:@"hh:mm a"];
    NSString *strDate = [self getStringFormate:currentDateTime fromFormate:@"MM/dd/yyyy hh:mm a" toFormate:@"MMM dd, yyyy"];
    
    html = [html stringByReplacingOccurrencesOfString:@"$$DATE$$" withString:[NSString stringWithFormat:@"%@",strDate]];
    html = [html stringByReplacingOccurrencesOfString:@"$$TIME$$" withString:strTime];
    
    return html;
}

-(NSString *)getStringFormate:(NSString *)pstrDate fromFormate:(NSString *)pstrFformate toFormate:(NSString *)pstrToformate{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = pstrFformate;
    NSDate *dateFromString;// = [[NSDate alloc] init];
    dateFromString = [dateFormatter dateFromString:pstrDate];
    
    NSDateFormatter* df = [[NSDateFormatter alloc]init];
    df.dateFormat = pstrToformate;
    NSString *result = [df stringFromDate:dateFromString];
    
    return result;
}

-(NSString *)htmlBillTextForItem:(NSMutableArray *)arrayInvoice
{
    NSString *itemHtml = @"";
    for (int i=0; i<arrayInvoice.count; i++)
    {
        // set Item Detail with only 1 qty....
        NSString *strHTML = [self htmlBillTextGenericForItemwithDictionary:arrayInvoice[i]];
        itemHtml = [itemHtml stringByAppendingFormat:@"%@",strHTML];
    }
    return itemHtml;
}
-(NSString *)htmlBillTextGenericForItemwithDictionary:(NSDictionary *)itemDictionary
{
    NSString *htmldata = @"";
    htmldata = [htmldata stringByAppendingFormat:@"<tr><td valign=\"top\" style=\"word-break:break-all; padding-right:10px;\"><font size=\"2\">%@</font></td><td>&nbsp</td><td align=\"left\" valign=\"top\"style=\"width:50%@; word-break:break-all; padding-right:10px;\" ><font size=\"2\">%@</font></td><td>&nbsp</td><td align=\"right\" valign=\"top\"><font size=\"2\">%@</font></td></tr>",itemDictionary[@"AddedQty"],@"%",itemDictionary[@"ItemName"],itemDictionary[@"avaibleQty"]];
    return htmldata;
}

-(void)htmlBillTextForPreview:(NSMutableArray *)arryInvoice
{
    
    self.emaiItemHtml = [[NSBundle mainBundle] pathForResource:@"purchaseorderitem" ofType:@"html"];
    self.emaiItemHtml = [NSString stringWithContentsOfFile:self.emaiItemHtml encoding:NSUTF8StringEncoding error:nil];
    
    self.emaiItemHtml = [self htmlBillHeader:self.emaiItemHtml invoiceArray:arryInvoice];
    
    // set Html itemDetail
    NSString *itemHtml = [self htmlBillTextForItem:[arryInvoice.firstObject valueForKey:@"lstItem"]];
    self.emaiItemHtml = [self.emaiItemHtml stringByReplacingOccurrencesOfString:@"$$ITEM_HTML$$" withString:[NSString stringWithFormat:@"%@",itemHtml]];
    
    /// Write Data On Document Directory.......
    NSData* data = [self.emaiItemHtml dataUsingEncoding:NSUTF8StringEncoding];
    [self writeDataOnCacheDirectory:data];
    
    self.PDFCreator = [NDHTMLtoPDF createPDFWithURL:[[NSURL alloc]initFileURLWithPath:self.emaiItemHtml]
                                         pathForPDF:@"~/Documents/previewreceipt.pdf".stringByExpandingTildeInPath
                                           delegate:self
                                           pageSize:kPaperSizeA4
                                            margins:UIEdgeInsetsMake(10, 5, 10, 5)];
    
    
    
}
#pragma mark NDHTMLtoPDFDelegate

- (void)HTMLtoPDFDidSucceed:(NDHTMLtoPDF*)htmlToPDF
{
    //NSString *result = [NSString stringWithFormat:@"HTMLtoPDF did succeed (%@ / %@)", htmlToPDF, htmlToPDF.PDFpath];
    // objPreviewandPrint.strPdfFilePath=htmlToPDF.PDFpath;
    [self openDocumentwithSharOption:htmlToPDF.PDFpath];
}

- (void)HTMLtoPDFDidFail:(NDHTMLtoPDF*)htmlToPDF
{
    //NSString *result = [NSString stringWithFormat:@"HTMLtoPDF did fail (%@)", htmlToPDF];
    // objPreviewandPrint.strPdfFilePath=result;
    
}

-(void)openDocumentwithSharOption:(NSString *)strpdfUrl{
    // here's a URL from our bundle
    NSURL *documentURL = [[NSURL alloc]initFileURLWithPath:strpdfUrl];
    
    // pass it to our document interaction controller
    self.controller.URL = documentURL;
    // present the preview
    [self.controller presentPreviewAnimated:YES];
    
}


- (UIDocumentInteractionController *)controller {
    
    if (!_controller) {
        _controller = [[UIDocumentInteractionController alloc]init];
        _controller.delegate = self;
    }
    return _controller;
}
- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
    
    return  self;
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(NSString *)application {
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application {
}


-(IBAction)logoutButton:(id)sender{
    
    NSArray *viewControllers = [self.navigationController viewControllers];
    for (UIViewController *viewCon in viewControllers) {
        if([viewCon isKindOfClass:[RimLoginVC class]]){
            [self.navigationController popToViewController:viewCon animated:YES];
        }
    }
}

-(IBAction)back:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
