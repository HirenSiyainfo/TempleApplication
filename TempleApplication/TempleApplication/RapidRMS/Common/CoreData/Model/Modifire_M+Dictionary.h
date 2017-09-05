//
//  Modifire_M+Dictionary.h
//  RapidRMS
//
//  Created by Siya Infotech on 09/12/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "Modifire_M.h"

@interface Modifire_M (Dictionary)

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSDictionary *itemModifireMDictionary;
-(void)updateitemModifireMDictionary :(NSDictionary *)itemModifireMDictionary;

@end