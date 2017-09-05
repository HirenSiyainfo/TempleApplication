//
//  ForceBatchCloseResponse.h
//  PaxControllerApp
//
//  Created by siya info on 30/07/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "BatchCloseResponse.h"

@interface ForceBatchCloseResponse : BatchCloseResponse
@property (nonatomic, readonly) NSInteger lineCount;
@property (nonatomic, readonly) NSArray *lineMessages;
@end
