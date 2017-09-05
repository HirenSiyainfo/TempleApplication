//
//  RestaurantOrderList.h
//  RapidRMS
//
//  Created by siya-IOS5 on 4/7/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RestaurantOrderList : UIViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,strong) NSString *shiftRequire;

@end
