//
//  MMDSelectedItemListVC.h
//  RapidRMS
//
//  Created by Siya Infotech on 25/01/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM (NSInteger , MMDItemSelectType){
    MMDItemSelectTypeItem = 1,
    MMDItemSelectTypeGroup,
    MMDItemSelectTypeTag,
    MMDItemSelectTypeDepartment,
};

@protocol MMDSelectedItemListVCDelegate <NSObject>
-(void)isFullScreenView:(BOOL) isFullscreen isXitemContainer:(BOOL)isXContainer;
-(void)didDeleteItemInContainer;
@end

@interface MMDSelectedItemListVC : UIViewController

@property (nonatomic, weak) IBOutlet UITableView * tblSelectedItemList;
@property (nonatomic, weak) id<MMDSelectedItemListVCDelegate> Delegate;

@property (nonatomic, strong) NSString * strTitleOfContainer;
@property (nonatomic, strong) NSMutableArray * arrSelectedItem;

@property (nonatomic) BOOL isXitemList;
@property (nonatomic) BOOL isMandMDiscount;

@property (nonatomic, strong) NSManagedObjectContext * moc;

@end
