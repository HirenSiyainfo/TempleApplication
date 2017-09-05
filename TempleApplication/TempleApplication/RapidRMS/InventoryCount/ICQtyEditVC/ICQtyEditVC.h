//
//  ICQtyEditVC.h
//  RapidRMS
//
//  Created by Siya Infotech on 02/01/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ItemInventoryCountSession+Dictionary.h"
#import "ItemInventoryCount+Dictionary.h"


@protocol ICQtyEditDelegate<NSObject>
-(void)didAddItemToInventoryCountListWith:(ItemInventoryCount *)itemInventoryCount withItem:(Item *)item withCountDetail:(NSMutableDictionary *)countDictionary;
-(void)didCancelItemInventoryCountProcess;
@end

@interface ICQtyEditVC : UIViewController

@property (nonatomic, weak) id<ICQtyEditDelegate> iCQtyEditDelegate;

@property (nonatomic, weak) ItemInventoryCount *selectedItemInventoryCount;
@property (nonatomic, strong) Item *selectedItem;
@property (nonatomic, weak) IBOutlet UIView *roundedView;

@end