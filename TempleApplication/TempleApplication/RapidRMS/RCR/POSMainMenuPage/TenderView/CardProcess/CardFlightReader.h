//
//  CardFlightReader.h
//  RapidRMS
//
//  Created by siya-IOS5 on 6/3/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "RmsCardReader.h"
@interface CardFlightReader : RmsCardReader

- (instancetype)initWithDelegate:(id<RmsCardReaderDelegate>)delegate NS_DESIGNATED_INITIALIZER;
@end
