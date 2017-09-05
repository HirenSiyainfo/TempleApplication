//
//  CL_HouseChage.h
//  RapidRMS
//
//  Created by Siya Infotech on 26/04/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CL_HouseCharge : NSObject

@property (nonatomic,strong) NSString *houseChageDate;
@property (nonatomic,strong) NSString *invoice;
@property (nonatomic,strong) NSNumber *Credit;
@property (nonatomic,strong) NSNumber *debit;
@property (nonatomic,strong) NSNumber *balance;

-(void)setupCustomerHouseChargeDetail:(NSDictionary *)customerHouseChargeDetailDictionary;

@end
