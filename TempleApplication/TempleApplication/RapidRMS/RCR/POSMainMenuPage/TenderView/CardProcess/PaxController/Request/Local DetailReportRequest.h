//
//  Local DetailReportRequest.h
//  PaxControllerApp
//
//  Created by siya-IOS5 on 1/11/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PaxRequest.h"
@interface Local_DetailReportRequest : PaxRequest
- (instancetype)initWithRecordNumber:(NSInteger)recordNumber  NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithReferenceNumber:(NSString *)referenceNumber  NS_DESIGNATED_INITIALIZER;

@end
