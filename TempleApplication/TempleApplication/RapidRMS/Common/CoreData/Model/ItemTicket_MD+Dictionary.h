//
//  ItemTicket_MD+Dictionary.h
//  RapidRMS
//
//  Created by siya-IOS5 on 6/24/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "ItemTicket_MD.h"

@interface ItemTicket_MD (Dictionary)
-(void)updateItemTicketlDictionary :(NSDictionary *)itemTicketDictionary;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSMutableDictionary *itemTicketDictionary;

@end
