//
//  PaxCCBatchReceipt.h
//  RapidRMS
//
//  Created by Siya7 on 6/8/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "BasicCCbatchReceipt.h"

@interface PaxCCBatchReceipt : BasicCCbatchReceipt

- (instancetype)initWithPortName:(NSString *)portName portSetting:(NSString *)portSettings withTotalCount:(NSInteger)totalCount withTotalAmount:(NSString *)totalAmount withBatchNo:(NSString *)batchNo batchDictionary:(NSMutableDictionary *)batchDict;

@end
