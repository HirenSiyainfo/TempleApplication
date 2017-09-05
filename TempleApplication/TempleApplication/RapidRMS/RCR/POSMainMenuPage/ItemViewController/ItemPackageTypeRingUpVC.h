//
//  ItemPackageTypeRingUpVC.h
//  RapidRMS
//
//  Created by Siya Infotech on 2/27/17.
//  Copyright © 2017 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Item;
@protocol ItemPackageTypeRingUpDelegate<NSObject>
-(void)didRingUpItemFormPackageTypeDetail :(Item *)item withItemQty:(NSNumber *)qty withPackageType: (NSString *)packageType;

-(void)didCancelPackageTypeCustomeVC;

@end

@interface ItemPackageTypeRingUpVC : UIViewController

@property (nonatomic, weak) id<ItemPackageTypeRingUpDelegate> itemPackageTypeRingUpDelegate;
@property (nonatomic,strong) NSMutableArray *arrayItem;
@property (nonatomic,strong) NSString *strItemName;

@end
