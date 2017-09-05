//
//  ManualReceivedItem+Dictionary.h
//  RapidRMS
//
//  Created by Siya on 16/01/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "ManualReceivedItem.h"

@interface ManualReceivedItem (Dictionary)


@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSDictionary *manualPoitemSessionDictionary;
@property (NS_NONATOMIC_IOSONLY, getter=getmanualPoItemSessionDictionary, readonly, copy) NSDictionary *manualPoItemSessionDictionary;
-(void)updateManualPoitemDictionary :(NSDictionary *)manualPOitemDictionary;
-(void)interChangeValuefrom:(ManualReceivedItem *)mItem;
@end
