//
//  AddRestaurantOrder.h
//  RapidRMS
//
//  Created by siya-IOS5 on 4/7/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddRestaurantOrderDelegate<NSObject>

-(void)didInsertRestaurantOrder:(NSDictionary *)orderDetail;
-(void)didCancelRestaurantOrder;
@end


@interface AddRestaurantOrder : UIViewController<NSFetchedResultsControllerDelegate>
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, weak) id<AddRestaurantOrderDelegate> addRestaurantOrderDelegate;

@end
