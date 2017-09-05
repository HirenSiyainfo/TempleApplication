//
//  RapidPass.m
//  RapidRMS
//
//  Created by siya-IOS5 on 6/25/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "RapidPass.h"

@implementation RapidPass

-(void)configureRapidPassWithDetail:(NSDictionary *)passDetail
{
    self.usedDays = passDetail[@"UsedDays"];
    self.availableDays = passDetail[@"AvailableDays"];
    self.purchaseDate =  passDetail[@"PurchaseDate"];
    self.lastVisitDateTime = passDetail[@"LastVisitDateTime"];
    self.expiredDate = passDetail[@"ExpiredDate"];
    self.typeOfPass =  passDetail[@"TypeOfPass"];
    self.regInvoiceNo =  passDetail[@"RegInvoiceNo"];
    self.passNo =  passDetail[@"CRDNumber"];
    self.passItemId = passDetail[@"PassItemId"];
    self.passTicketId = passDetail[@"Id"];
    self.validityStatus = passDetail[@"ValidityStatus"];
    self.availableExpiryDays = [passDetail[@"AvailExpirationDays"] stringValue];
    self.qrCode = passDetail[@"QRCode"];
}

@end
