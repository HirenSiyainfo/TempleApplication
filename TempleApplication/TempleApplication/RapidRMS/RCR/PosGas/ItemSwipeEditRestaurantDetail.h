//
//  ItemSwipeEditRestaurantDetail.h
//  RapidRMS
//
//  Created by siya-IOS5 on 4/27/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol ItemSwipeEditRestaurantDetailDelegate<NSObject>
-(void)didEditRestaurantItemSectionAtIndexpath:(NSIndexPath *)indexpath;

@end

@interface ItemSwipeEditRestaurantDetail : UITableViewCell
@property (nonatomic,weak) IBOutlet UILabel *cellLabelText;
@property (nonatomic,weak) IBOutlet UIButton *printStatus;
@property (nonatomic,strong) NSIndexPath *currentIndexpathForRestaurant;

-(void)updatePrintStatus:(NSDictionary *)editDictionary diplayPrintButtonForCell:(BOOL)diplayPrintButton;
-(void)updateDineInStatus:(NSDictionary *)editDictionary;

@property (nonatomic, weak) id<ItemSwipeEditRestaurantDetailDelegate> itemSwipeEditRestaurantDetailDelegate;

@end
