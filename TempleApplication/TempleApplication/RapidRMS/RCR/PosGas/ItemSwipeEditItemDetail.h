//
//  ItemSwipeEditItemDetail.h
//  RapidRMS
//
//  Created by siya-IOS5 on 4/27/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ItemSwipeEditItemDetailDelegate <NSObject>

@end

@interface ItemSwipeEditItemDetail : UITableViewCell

@property (nonatomic,weak) IBOutlet UILabel *itemName;
@property (nonatomic,weak) IBOutlet UILabel *upc;
@property (nonatomic,weak) IBOutlet AsyncImageView *itemImage;

@property (nonatomic, weak) id<ItemSwipeEditItemDetailDelegate> itemSwipeEditItemDetailDelegate;

@property (nonatomic,weak) IBOutlet UILabel *itemNo;

-(void)configureItemDetailWithDictionary:(NSMutableDictionary *)itemDictionary;

@end
