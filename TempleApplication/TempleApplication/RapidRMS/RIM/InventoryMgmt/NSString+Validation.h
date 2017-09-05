//
//  NSString+Validation.h
//  RapidRMS
//
//  Created by Siya9 on 02/06/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Validation)

+(NSString *)trimSpacesFromStartAndEnd:(NSString *)strString;
-(BOOL)isValidIP;
@end
