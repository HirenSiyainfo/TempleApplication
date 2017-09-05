//
//  MESearchItemSelectionVC.h
//  RapidRMS
//
//  Created by Siya on 17/01/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "InventoryManagement.h"

@protocol MESearchItemSelectionVCDelegate
-(void)didSelectItems:(NSArray *) selectedItems;
@end

@interface MESearchItemSelectionVC : InventoryManagement

@property (nonatomic,weak) id<MESearchItemSelectionVCDelegate> meSearchItemSelectionVC;
@end
