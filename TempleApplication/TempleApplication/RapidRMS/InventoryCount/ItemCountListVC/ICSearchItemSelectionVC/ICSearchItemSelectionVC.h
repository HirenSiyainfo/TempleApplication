//
//  ICSearchItemSelectionVC.h
//  RapidRMS
//
//  Created by Siya Infotech on 05/01/15.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "InventoryManagement.h"

@protocol ICSearchItemSelectionVCDelegate
-(void)didSelectItems:(NSArray *) selectedItems;
@end

@interface ICSearchItemSelectionVC : InventoryManagement

@property (nonatomic,weak) id<ICSearchItemSelectionVCDelegate> icSearchItemSelectionVC;

@end