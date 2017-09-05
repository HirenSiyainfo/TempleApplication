//
//  HostReportResponse.h
//  PaxControllerApp
//
//  Created by siya-IOS5 on 8/13/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "PaxResponse.h"

@interface HostReportResponse : PaxResponse
@property (nonatomic, readonly) NSString *numberOfLines;
@property (nonatomic, strong) NSMutableDictionary *hostReportDetail;
@property (nonatomic, readonly) NSString *reportType;

@end
