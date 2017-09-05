//
//  ItemSwipeEditVC.h
//  RapidRMS
//
//  Created by siya-IOS5 on 8/5/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BillAmountCalculator.h"



@protocol ItemSwipeEditDelegate<NSObject>

-(void)didEditItemWithEditPrice :(BOOL)isEditPrice withEditedPrice:(NSNumber *)editedPrice withEditQty:(BOOL)isEditQty withBillEntry:(NSMutableDictionary *)editDictionary;
-(void)didCancelEditSwipe;
-(void)openItemTaxRemoveMessagePopUp;
-(void)didRemoveItem;

@end

@interface ItemSwipeEditVC : UIViewController

@property (nonatomic,strong)NSMutableDictionary *swipeDictionary;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, weak) id<ItemSwipeEditDelegate> itemSwipeEditDelegate;

@property (strong, nonatomic) NSString *moduleIdentifier;
@property (nonatomic, assign) BOOL isNoPrintForItem;
@property (nonatomic, strong) BillAmountCalculator *editBillAmountCalculator;

-(void)removeTaxWithMessage:(NSString *)message;

@end
