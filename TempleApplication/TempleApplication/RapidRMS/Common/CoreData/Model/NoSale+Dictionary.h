//
//  NoSale+Dictionary.h
//  RapidRMS
//
//  Created by siya-IOS5 on 3/4/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "NoSale.h"

@interface NoSale (Dictionary)
-(void)updateNoSaleDictionary :(NSDictionary *)noSaleDictionary;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSDictionary *noSaleDictionary;
@end
