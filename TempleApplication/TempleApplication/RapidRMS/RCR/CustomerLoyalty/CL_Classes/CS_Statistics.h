//
//  CS_Statistics.h
//  RapidRMS
//
//  Created by Siya Infotech on 07/12/15.
//  Copyright © 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CS_Statistics : NSObject
@property (nonatomic,strong) NSString *customerName;
@property (nonatomic,strong) NSString *loyaltyNo;
@property (nonatomic,strong) NSString *contactNo;
@property (nonatomic,strong) NSString *email;
@property (nonatomic,strong) NSString *dob;
@property (nonatomic,strong) NSString *address;
@property (nonatomic,strong) NSString *lastPurchaseDateTime;
@property (nonatomic,strong) NSString *avgTickets;
@property (nonatomic,strong) NSString *customerNo;
@property (nonatomic,strong) NSNumber *avgQty;
@property (nonatomic,strong) NSNumber *purchaseItem;



@property (nonatomic,strong) NSArray *topItems;
@property (nonatomic,strong) NSArray *topTags;
@property (nonatomic,strong) NSMutableArray *paymentType;

@property (nonatomic,strong) NSMutableArray *departmentArray;

-(void)setupCustomerStatisticsDetail:(NSDictionary *)customerStatisticDetailDictionary;

@end
