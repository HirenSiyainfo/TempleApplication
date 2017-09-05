//
//  SizeMaster+Dictionary.h
//  POSRetail
//
//  Created by Siya Infotech on 15/03/14.
//  Copyright (c) 2014 Nirav Patel. All rights reserved.
//

#import "SizeMaster.h"

@interface SizeMaster (Dictionary)
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSDictionary *sizeMasterDictionary;
-(void)updateSizeMasterFromDictionary :(NSDictionary *)sizeMasterDictionary;

@end
