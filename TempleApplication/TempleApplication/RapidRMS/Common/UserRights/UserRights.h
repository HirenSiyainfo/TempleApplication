//
//  UserRights.h
//  RapidRMS
//
//  Created by Siya-mac5 on 25/04/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,UserRight) {
    //Change Price - POS Item Swipe Edit Price
    UserRightChangePrice = 1,
    
    //Discount - POS Item Swipe Remove Discount, Discount From Sales Screen
    UserRightDiscount = 2,
    
    //Tax - POS Item Swipe Edit Add & Remove Tax, Remove Tax From Sales Screen
    UserRightTax = 3,
    
    //Z Report Print - Access Z Report & Print Z Report From Daily Report
    UserRightZReportPrint = 4,
    
    //ZZ Report Print - Access ZZ Report & Print ZZ Report From Daily Report
    UserRightZZReportPrint = 5,
    
    //Daily (Z) Report - Access Manager Z Report From Daily Report
    UserRightManagerZReport = 6 ,
    
    //Monthly (ZZ) Report - Access Manager ZZ Report From Daily Report
    UserRightManagerZZReport = 7,
    
    //Inventory Info - Item Add & Update From Rapid
    UserRightInventoryInfo = 8,
    
    //Invoice Void Transaction - Void Transaction From Invoice
    UserRightVoidTransaction = 9,
    
    //Cash Register Access - Access RCR
    UserRightOrderProcess = 10,
    
    //Tender Process - Unused because of Duplication
    UserRightTenderProcessUnusedDuplicated = 11,
    
    //Cancel Invoice - Cancel Invoice From Sales Screen
    UserRightCancelInvoice = 12,
    
    //Delete Hold Invoice - Delete Hold Invoice From Recall List
    UserRightDeleteHoldInvoice = 13,
    
    //Tickets - Access Ticket Validation Screen From Sales Screen & Ticket Module
    UserRightTickets = 14,
    
    //Customer Loyalty - Access Customer Loyalty From Invoice & CL Module, Add,Update & Delete Customer
    UserRightCustomerLoyalty = 15,
    
    //Clock In Out - Access CLIO from RCR & CLIO Module
    UserRightClockInOut = 16,
    
    //Shift In Out - Access SIO From RCR, SIO, Access & Print Shift Report From Daily Report
    UserRightShiftInOut = 17,
    
    //X Report - Access X Report From RCR & DR , Print X Report From Daily Report
    UserRightXReport = 18,
    
    //CC Batch - Access CC Batch
    UserRightCCBatch = 19,
    
    //Manual Entry - Access Manual Entry
    UserRightManualEntry = 20,
    
    //POSSetting - Access Setting
    UserRightSetting = 21,
    
    //ClockInOutAction - Update/Remove Clock-In/Out details
    UserRightClockInOutAction = 22,
};

@interface UserRights : NSObject

+ (void)updateUserRights:(NSArray *)newUserRights;
+ (BOOL)hasRights:(UserRight)userRight;

@end
