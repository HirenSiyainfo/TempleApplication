//
//  RcdAutoLock.h
//  DataReceiveApp
//
//  Created by Siya Infotech on 23/06/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RapidAutoLock : NSObject

-(instancetype)initWithLock:(id<NSLocking>)lock NS_DESIGNATED_INITIALIZER;
-(void)unlock;
@end
