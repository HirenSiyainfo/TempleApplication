//
//  MMDSlideItemListVC.h
//  RapidRMS
//
//  Created by Siya Infotech on 25/01/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSUInteger, ItemListViewTypes)
{
    ItemListViewTypesItem = 1,
    ItemListViewTypesGroup,
    ItemListViewTypesTag,
    ItemListViewTypesDepartment,
};
@protocol DidSelectItemListDelegate <NSObject>
    -(void)didSelectItemList:(NSMutableArray *) arrSelectedItems;
    @property (NS_NONATOMIC_IOSONLY, getter=getSelectedItems, readonly, copy) NSMutableArray *selectedItems;
@optional
    -(void)willCloseItemSelectionView;
@end

@interface MMDSlideItemListVC : UIViewController
@property (nonatomic, strong) NSDictionary * resetNewInfo;
@property (nonatomic , weak) id<DidSelectItemListDelegate> delegate;

@property (nonatomic) ItemListViewTypes selectedView;
@property (nonatomic) BOOL isXitemList;
@property (nonatomic) BOOL isMandMDiscount;
@property (nonatomic, strong) NSManagedObjectContext * moc;
@end
