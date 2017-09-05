//
//  KitchenPrinting.m
//  RapidRMS
//
//  Created by Siya Infotech on 12/05/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "KitchenPrinting.h"
#import "RestaurantOrder+Dictionary.h"
#import "RestaurantItem+Dictionary.h"
#import "RasterPrintJobBase.h"
#import <UIKit/UIWebView.h>

typedef NS_ENUM(NSUInteger, KPAlignment) {
    KPAlignmentLeft,
    KPAlignmentCenter,
    KPAlignmentRight,
};

@interface KitchenPrinting () <UIWebViewDelegate>
{
    UIWebView *webViewKitchenPrinting;
    NSInteger columnWidths[6];
    NSInteger columnAlignments[6];
}

@property (strong, nonatomic) PrintJob *printJob;
@property (strong, nonatomic) NSArray *itemListArray;
@property (strong, nonatomic) RestaurantOrder *restaurantOrder;

@end

@implementation KitchenPrinting 

- (void)configureKitchenPrint:(NSString *)portName portSettings:(NSString *)portSettings withDelegate:(id)delegate
{
    BOOL isBlueToothPrinter = [portName isEqualToString:@"BT:Star Micronics"];
    
    if (isBlueToothPrinter) {
        _printJob = [[PrintJobBase alloc] initWithPort:portName portSettings:portSettings deviceName:@"Printer" withDelegate:delegate];
        [_printJob enableSlashedZero:YES];
    }
    else
    {
        _printJob = [[RasterPrintJobBase alloc] initWithPort:portName portSettings:portSettings deviceName:@"Printer" withDelegate:delegate];
    }
}

- (instancetype)initWithPortName:(NSString *)portName portSetting:(NSString *)portSettings itemList:(NSArray *)itemList restaurantOrder:(RestaurantOrder *)restOrder withDelegate:(id)delegate
{
    self = [super init];
    if (self) {
        [self configureKitchenPrint:portName portSettings:portSettings withDelegate:delegate];
        webViewKitchenPrinting = [[UIWebView alloc] initWithFrame:CGRectMake(0, 64, 370, 230)];
        webViewKitchenPrinting.delegate = self;
        self.itemListArray = itemList;
        self.restaurantOrder = restOrder;
    }
    return self;
}

- (void)concludePrint
{
    [_printJob cutPaper:PC_PARTIAL_CUT_WITH_FEED];
    [_printJob firePrint];
    _printJob = nil;
}

- (void)printKitchenReceipt
{
    [self printReceiptTitle];
    [self printKOTNoAndDate];
    [self printTableNoAndTime];
    [self printNameAndQty];
    [self printItemNameAndItemQty];
    [self printTotalItems];
    [self concludePrint];
}

-(void)printReceiptTitle {
    [_printJob setTextAlignment:TA_CENTER];
    [_printJob enableBold:YES];
    [_printJob printLine:@"FOOD"];
    [_printJob enableBold:NO];
}

-(void)printKOTNoAndDate {
    [self defaultFormatForTwoColumn];
    NSString *currentDate = [NSString stringWithFormat:@"Date: %@",[self dateAndTime] [@"CurrentDate"]];
    [_printJob printText1:@"$$KOT No$$" text2:currentDate];
}

-(void)printTableNoAndTime {
    [self defaultFormatForTwoColumn];
    NSString *tableNo = [NSString stringWithFormat:@"Table No: %@",self.restaurantOrder.tabelName];
    NSString *currentDate = [NSString stringWithFormat:@"Time: %@",[self dateAndTime] [@"CurrentTime"]];
    [_printJob printText1:tableNo text2:currentDate];
    [_printJob printSeparator];
}

-(void)printNameAndQty {
    [self defaultFormatForTwoColumn];
    [_printJob printText1:@"Name" text2:@"Qty"];
    [_printJob printSeparator];
}

-(void)printItemNameAndItemQty {
    for (RestaurantItem *restaurantItem in self.itemListArray)
    {
        NSString *itemName = [NSString stringWithFormat:@"%@",restaurantItem.itemName];
        NSInteger restaurantItemQty = restaurantItem.quantity.integerValue - restaurantItem.previousQuantity.integerValue;
        NSString *itemQty = [NSString stringWithFormat:@"%ld",(long)restaurantItemQty];
        [self defaultFormatForTwoColumn];
        [_printJob printText1:itemName text2:itemQty];
    }
    [_printJob printSeparator];
}

-(void)printTotalItems {
    [_printJob setTextAlignment:TA_LEFT];
    NSInteger totalItemQty = 0;
    for (RestaurantItem *restaurantItem in self.itemListArray)
    {
        NSInteger restaurantItemQty = restaurantItem.quantity.integerValue - restaurantItem.previousQuantity.integerValue;
        totalItemQty+= restaurantItemQty;
    }
    NSString *totalItems = [NSString stringWithFormat:@"Total Items: %ld",(long)totalItemQty];
    [_printJob printLine:totalItems];
}

-(NSDictionary *)dateAndTime {
    NSDate * date = [NSDate date];
    //Create the dateformatter object
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM/dd/yyyy";
    
    //Create the timeformatter object
    NSDateFormatter* timeFormatter = [[NSDateFormatter alloc] init];
    timeFormatter.dateFormat = @"hh:mm a";
    
    //Get the string date
    NSString *printDate = [dateFormatter stringFromDate:date];
    NSString *printTime = [timeFormatter stringFromDate:date];
    return @{@"CurrentDate":printDate, @"CurrentTime":printTime};
}

- (void)defaultFormatForTwoColumn
{
    columnWidths[0] = 24;
    columnWidths[1] = 23;
    columnAlignments[0] = KPAlignmentLeft;
    columnAlignments[1] = KPAlignmentRight;
    [_printJob setColumnWidths:columnWidths columnAlignments:columnAlignments];
}

- (void)printHtml
{
    NSString *kitchenPrintItemHtml = [self htmlForKitchenPrintItemFrom:self.itemListArray withRestaurantOrder:self.restaurantOrder];
    [webViewKitchenPrinting loadHTMLString:kitchenPrintItemHtml baseURL:nil];
}

-(NSString *)htmlForKitchenPrintItemFrom:(NSArray *)kitchenPrintItemArray withRestaurantOrder:(RestaurantOrder *)restaurantOrder
{
    NSString *kitchenPrintItemHtml = [[NSBundle mainBundle] pathForResource:@"food" ofType:@"html"];
    kitchenPrintItemHtml = [NSString stringWithContentsOfFile:kitchenPrintItemHtml encoding:NSUTF8StringEncoding error:nil];
    
    kitchenPrintItemHtml = [kitchenPrintItemHtml stringByReplacingOccurrencesOfString:@"$$Table NO$$" withString:[NSString stringWithFormat:@"Table No :%@",restaurantOrder.tabelName]];
    
    NSDate * date = [NSDate date];
    //Create the dateformatter object
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM/dd/yyyy";
    
    //Create the timeformatter object
    NSDateFormatter* timeFormatter = [[NSDateFormatter alloc] init];
    timeFormatter.dateFormat = @"hh:mm a";
    
    //Get the string date
    NSString *printDate = [dateFormatter stringFromDate:date];
    NSString *printTime = [timeFormatter stringFromDate:date];
    
    kitchenPrintItemHtml = [kitchenPrintItemHtml stringByReplacingOccurrencesOfString:@"$$DATE$$" withString:[NSString stringWithFormat:@"Date: %@",printDate]];
    kitchenPrintItemHtml = [kitchenPrintItemHtml stringByReplacingOccurrencesOfString:@"$$TIME$$" withString:[NSString stringWithFormat:@"Time: %@",printTime]];
    
    NSString  *itemHtml = @"";
    NSInteger totalItemQty = 0;
    for (RestaurantItem *restaurantItem in kitchenPrintItemArray)
    {
        NSInteger restaurantItemQty = restaurantItem.quantity.integerValue - restaurantItem.previousQuantity.integerValue;
        
        itemHtml = [itemHtml stringByAppendingFormat:@"<tr><td valign=\"top\"  style=\"word-break:break-all; padding-right:10px;\"><font size=\"2\">%@</font> </td><td align=\"left\" valign=\"top\" style=\"width:40;text-align:center; word-break:break-all; padding-right:10px;\" >%ld </td></tr>",restaurantItem.itemName,(long)restaurantItemQty];
        totalItemQty+= restaurantItemQty;
    }
    
    kitchenPrintItemHtml = [kitchenPrintItemHtml stringByReplacingOccurrencesOfString:@"$$ITEM_LIST$$" withString:[NSString stringWithFormat:@"%@",itemHtml]];
    
    kitchenPrintItemHtml = [kitchenPrintItemHtml stringByReplacingOccurrencesOfString:@"$$TOTAL_ITEM$$" withString:[NSString stringWithFormat:@"Total Items :%ld",(long)totalItemQty]];
    
    return kitchenPrintItemHtml;
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.printJob beginRasterModePrinting];
    UIImage *image = [self takeScreenShotFromView:webViewKitchenPrinting];
    [self.printJob printImage:image];
    [self.printJob endRasterModePrinting];
    [self.printJob cutPaper:PC_PARTIAL_CUT_WITH_FEED];
    [self.printJob firePrint];
}

- (UIImage *)takeScreenShotFromView:(UIWebView *)webView
{
    CGFloat height = [webView stringByEvaluatingJavaScriptFromString:@"document.height"].floatValue;
    CGFloat width = [webView stringByEvaluatingJavaScriptFromString:@"document.width"].floatValue;
    CGRect frame = webView.frame;
    frame.size.height = height;
    frame.size.width = width;
    webView.frame = frame;

    UIGraphicsBeginImageContext(webView.scrollView.contentSize);
    [webViewKitchenPrinting.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

@end
