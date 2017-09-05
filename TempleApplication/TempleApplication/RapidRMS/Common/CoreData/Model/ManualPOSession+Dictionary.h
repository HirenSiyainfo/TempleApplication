//
//  ManualPOSession+Dictionary.h
//  RapidRMS
//
//  Created by Siya on 16/01/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "ManualPOSession.h"

@interface ManualPOSession (Dictionary)

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSDictionary *manualPoSessionDictionary;
@property (NS_NONATOMIC_IOSONLY, getter=getmanualPoSessionDictionary, readonly, copy) NSDictionary *getmanualPoSessionDictionary;
-(void)updateManualPoDictionary :(NSDictionary *)manualPODictionary;
@end
