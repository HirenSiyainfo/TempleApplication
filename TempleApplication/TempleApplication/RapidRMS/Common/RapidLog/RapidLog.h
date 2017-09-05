//
//  RapidLog.h
//  RapidRMS
//
//  Created by Siya10 on 15/09/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RapidLog : NSObject

-(void)xmppMessagewithReq:(NSMutableDictionary *)logDictionary;
-(void)rapidLogWC:(NSMutableDictionary *)dictParam;
@end
