//
//  HistoryReportResponse.h
//  PaxControllerApp
//
//  Created by siya-IOS5 on 8/13/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PaxResponse.h"

@interface HistoryReportResponse : PaxResponse
@property (nonatomic,strong)  NSMutableDictionary *totalCountDetail ;
@property (nonatomic,strong) NSMutableDictionary *totalAmountDetail;
@property (nonatomic, readonly) NSString *batchNumber;
@property (nonatomic, readonly) NSString *timeStamp;

@end
