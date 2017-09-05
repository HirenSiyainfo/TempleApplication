//
//  ItemDisplayViewController.h
//  RapidRMS
//
//  Created by siya-IOS5 on 4/17/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Item;

@protocol ItemRingupSelectionDelegate <NSObject>

-(void) didSelectItemRingup:(Item *)ringupItem;
-(void) didSelectItemRingupId:(NSString *)ringupItemId;
-(void) didSelectwithMultipleItemArray:(NSMutableArray *)selectedItemArray;
-(void) didselectFavouriteItem:(NSString *)favouriteItemString withUnfavouriteItem:(NSString *)unFavouriteItemItemString;
-(void) didCancelItemRingup;

@end

@interface ItemDisplayViewController : UIViewController<UIAlertViewDelegate,NSFetchedResultsControllerDelegate,FBLoginViewDelegate>
{
}

@property (nonatomic, weak) id<ItemRingupSelectionDelegate> rcrPosVcDeleage;

@property (nonatomic) BOOL isItemForFavourite;

-(IBAction)itemOkClick:(id)sender;
-(IBAction)btn_ItemCancel:(id)sender;
-(IBAction)btn_ItemQty:(id)sender;
-(IBAction)btn_itemPriceSorting:(id)sender;
-(IBAction)itemdescriptbtn:(UIButton *)sender;
-(IBAction)itemdepartbtn:(UIButton *)sender;
-(IBAction)btnInfo_Clicked:(UIButton *)sender;
-(IBAction)btnFilter_Clicked:(UIButton *)sender;
-(IBAction)itemPosttoFacebook:(id)sender;

@end
