//
//  Customer.h
//  RapidRMS
//
//  Created by Siya Infotech on 08/06/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface Customer : NSManagedObject

// Insert code here to declare functionality of your managed object subclass
-(void)updateCustomerDetailDictionary :(NSDictionary *)customerDictionary;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSDictionary * _Nonnull customerInfoDictionary;


@end

NS_ASSUME_NONNULL_END

#import "Customer+CoreDataProperties.h"
