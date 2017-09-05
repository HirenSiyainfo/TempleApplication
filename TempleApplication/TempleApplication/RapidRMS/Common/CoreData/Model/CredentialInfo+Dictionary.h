//
//  CredentialInfo+Dictionary.h
//  RapidRMS
//
//  Created by siya-IOS5 on 2/23/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "CredentialInfo.h"

@interface CredentialInfo (Dictionary)
-(void)updateCredetnialDictionary :(NSDictionary *)creditcardCredetnialDictionary;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSDictionary *credetnialDictionary;
@end
