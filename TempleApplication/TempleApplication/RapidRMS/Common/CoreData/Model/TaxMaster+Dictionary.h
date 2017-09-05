//
//  TaxMaster+Dictionary.h
//  POSRetail
//
//  Created by Siya Infotech on 15/03/14.
//  Copyright (c) 2014 Nirav Patel. All rights reserved.
//

#import "TaxMaster.h"

@interface TaxMaster (Dictionary)
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSDictionary *taxMasterDictionary;
-(void)updateTaxMasterFromDictionary :(NSDictionary *)taxMasterDictionary;
@end
