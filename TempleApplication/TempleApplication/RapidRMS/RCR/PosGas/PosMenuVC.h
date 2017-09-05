//
//  PosMenuVC.h
//  RapidRMS
//
//  Created by Siya Infotech on 12/08/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BillAmountCalculator.h"


typedef NS_ENUM(NSInteger, POS_MENU) {
    ITEM_POS_MENU = 500,
    HOLD_POS_MENU,
    RECALL_POS_MENU,
    VOID_POS_MENU,
    DISCOUNT_POS_MENU,
    CANCEL_POS_MENU,
    REFUND_POS_MENU,
    INVOICE_POS_MENU,
    NO_SALE_POS_MENU,
    DROP_POS_MENU,
    GIFT_CARD_POS_MENU,
    REMOVE_TAX_MENU,
    SEND_ORDER_POS_MENU,
    SWITCH_TABLE_POS_MENU,
    MANAGER_REPORTS_POS_MENU,
};

@class PosMenuVC;

@protocol PosMenuDelegate <NSObject>

- (void)didSelectMenu:(PosMenuVC*)posMenu menuId:(NSInteger)menuId;

@end

@interface PosMenuVC : UIViewController

@property (nonatomic, weak) id<PosMenuDelegate> menuDelegate;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) BillAmountCalculator *billAmountCalculator;
@property(nonatomic,strong) NSMutableArray *posMenuVCarray;
@property (assign) float alphaOpasity;

-(void)setMenuTitles:(NSArray*)menuTitles;
-(void)setRecallCount:(NSInteger)recallCount AtIndex:(NSInteger)index;
-(void)clearSelection;
-(void)setOpasityForCollectionview :(float)opasity;
-(CGPoint)centerForMenuAtPoint:(NSIndexPath *)selectedMenuIndexpath ;

@end
