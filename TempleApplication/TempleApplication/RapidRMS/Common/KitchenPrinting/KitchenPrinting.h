//
//  KitchenPrinting.h
//  RapidRMS
//
//  Created by Siya Infotech on 12/05/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PrintJob.h"
#import "RasterPrintJob.h"

@interface KitchenPrinting : NSObject <UIWebViewDelegate>

- (instancetype)initWithPortName:(NSString *)portName portSetting:(NSString *)portSettings itemList:(NSArray *)itemList restaurantOrder:(RestaurantOrder *)restOrder withDelegate:(id)delegate NS_DESIGNATED_INITIALIZER;

- (void)printKitchenReceipt;

@end
