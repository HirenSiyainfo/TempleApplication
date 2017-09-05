//
//  SupplierMaster+Dictionary.h
//  POSRetail
//
//  Created by Siya Infotech on 15/03/14.
//  Copyright (c) 2014 Nirav Patel. All rights reserved.
//

#import "SupplierMaster.h"

@interface SupplierMaster (Dictionary)
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSDictionary *supplierMasterDictionary;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSDictionary *supplierLoadDictionary;
-(void)updateSupplierMasterFromDictionary :(NSDictionary *)supplierMasterDictionary;
@end
