//
//  popOverController.h
//  POSFrontEnd
//
//  Created by Minesh Purohit on 04/12/11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>



@protocol PopOverControllerDelegate<NSObject>

-(void)didEditItemWithItemPrice:(NSString *)itemPrice;
-(void)didEditItemWithItemQty:(NSString *)itemQty;
-(void)didCancelEditItemPopOver;

@end
@class POSMainMenuView;

@interface PopOverController : UIViewController <UITextFieldDelegate>
{
    
}
@property (nonatomic, weak) id<PopOverControllerDelegate> popOverControllerDelegate;
@property (nonatomic, strong) NSMutableArray * topingListAry;
@property (nonatomic, strong) NSString * notificationName;
@property (nonatomic, strong) NSString * isFrom;

@property (nonatomic) BOOL isPrice;
@property (nonatomic) BOOL isPriceEdited;
@property (nonatomic) BOOL isInvoice;

@property (nonatomic, strong)NSString *invoiceString;
@property (nonatomic, strong)NSString *itemHeaderTitle;

-(void)updateHeaderTitleLabelWithText:(NSString *)titleLabelText;

- (NSMutableDictionary *) setUpTopingsArray:(NSMutableArray *) topingData  atIndex:(NSIndexPath *)index withPrice:(NSString *)price;

@end
