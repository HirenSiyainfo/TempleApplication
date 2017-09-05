//
//  I-RMS
//
//  Created by Siya Infotech on 29/11/14.
//  Copyright (c) 2013 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ItemInfoEditVC.h"
@protocol ItemVariationChangedDelegate <NSObject>
    -(void)didChangeItemVariationAdded:(NSMutableArray *)addedItemVariation ItemVariationDeleted:(NSMutableArray *)deletedItemVariation ItemVariationDisplay:(NSMutableArray *)displayItemVariation;
@end

@interface ItemVariationRIM : UIViewController<UITextFieldDelegate>

@property (nonatomic, weak) id<ItemVariationChangedDelegate> ItemVariationChangedDelegate;

@property (nonatomic, strong) NSMutableArray *arraySelectionVeriation;

@end