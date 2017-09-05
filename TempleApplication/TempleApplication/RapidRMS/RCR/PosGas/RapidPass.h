//
//  RapidPass.h
//  RapidRMS
//
//  Created by siya-IOS5 on 6/25/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RapidPass : NSObject
@property (nonatomic,strong) NSString *usedDays;
@property (nonatomic,strong) NSNumber *availableDays;
@property (nonatomic,strong) NSString *purchaseDate;
@property (nonatomic,strong) NSString *lastVisitDateTime;
@property (nonatomic,strong) NSString *expiredDate;
@property (nonatomic,strong) NSString *typeOfPass;
@property (nonatomic,strong) NSString *regInvoiceNo;
@property (nonatomic,strong) NSString *passNo;
@property (nonatomic,strong) NSNumber *passItemId;
@property (nonatomic,strong) NSNumber *validityStatus;
@property (nonatomic,strong) NSNumber *passTicketId;
@property (nonatomic,strong) NSString *availableExpiryDays;
@property (nonatomic,strong) NSString *qrCode;

-(void)configureRapidPassWithDetail:(NSDictionary *)passDetail;

@end
