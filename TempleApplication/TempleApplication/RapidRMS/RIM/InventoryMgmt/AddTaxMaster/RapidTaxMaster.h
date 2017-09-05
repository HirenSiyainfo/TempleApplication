//
//  RapidTaxMaster.h
//  RapidRMS
//
//  Created by Siya Infotech on 25/09/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RapidTaxMaster : NSObject

@property (nonatomic, strong) NSNumber *TaxId;
@property (nonatomic, strong) NSNumber *SrNo;
@property (nonatomic, strong) NSString *TAXNAME;
@property (nonatomic, strong) NSNumber *PERCENTAGE;
@property (nonatomic, strong) NSString *Type;
@property (nonatomic, strong) NSNumber *Amount;
@property (nonatomic, strong) NSNumber *BranchId;
@property (nonatomic, strong) NSNumber *CreatedBy;
@property (nonatomic, strong) NSString *CreatedDate;

-(void)configureRapidTaxMasterFromDictionary :(NSDictionary *)taxMasterDictionary;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSDictionary *rapidTaxMasterDictionary;


@end
