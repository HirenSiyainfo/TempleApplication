//
//  ShiftReport.h
//  HtmlSS
//
//  Created by Siya Infotech on 20/05/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "BasicReport.h"

@interface ShiftReport : BasicReport

- (instancetype)initWithDictionary:(NSDictionary *)shiftReportData reportName:(NSString *)reportName NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithDictionary:(NSDictionary *)shiftReportData reportName:(NSString *)reportName isTips:(BOOL)isTips;
@end
