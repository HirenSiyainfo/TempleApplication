//
//  KitchenPrinter+Dictionary.h
//  RapidRMS
//
//  Created by siya-IOS5 on 4/6/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "KitchenPrinter.h"

@interface KitchenPrinter (Dictionary)

@property (NS_NONATOMIC_IOSONLY, getter=getprinterDictionary, readonly, copy) NSDictionary *printerDictionary;
-(void)updatePrinterDictionary :(NSDictionary *)printerDictionary;
@end
