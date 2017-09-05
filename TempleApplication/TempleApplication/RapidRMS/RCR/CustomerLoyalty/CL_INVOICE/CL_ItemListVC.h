//
//  CL_ItemListVC.h
//  RapidRMS
//
//  Created by Siya Infotech on 02/12/15.
//  Copyright © 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RapidCustomerLoyalty.h"


@protocol ItemListVCDelegate <NSObject>
@end

@interface CL_ItemListVC : UIViewController

@property (nonatomic ,weak) id<ItemListVCDelegate> itemListVCDelegate;

-(void)updateItemListViewWithRapidCustomerLoyaltyObject:(NSMutableArray *)itemList;
-(void)searchItemListData:(NSString*)itemListSearchString arrItemList:(NSMutableArray *)itemListSearchArray;
-(NSMutableArray *)itemListArray:(NSString*)itemListSearchString arrInvoicelListdata:(NSMutableArray *)itemListSearchArray;

@end
