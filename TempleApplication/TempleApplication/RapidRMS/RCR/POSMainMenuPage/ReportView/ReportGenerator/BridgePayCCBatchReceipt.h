//
//  BridgePayCCBatchReceipt.h
//  RapidRMS
//
//  Created by Siya7 on 6/10/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BasicCCbatchReceipt.h"

@interface BridgePayCCBatchReceipt : BasicCCbatchReceipt
-(instancetype)initWithPortName:(NSString *)portName portSetting:(NSString *)portSettings withBridgePayCCBatchData:(NSArray *)bridgePayCCBatchDetail;

@end
