//
//  RcrPosVC.h
//  RapidRMS
//
//  Created by Siya Infotech on 30/06/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PosMenuVC.h"
#import "TenderShortcutVC.h"
#import "TenderViewController.h"
#import "GusestSelectionVC.h"
#import "GiftCardPosVC.h"
#import "RemoveTaxVC.h"
#import "DepartmetCollectionVC.h"
#import "SubDepartmetCollectionVC.h"
#import "FavouriteCollectionVC.h"
#import "SubDeptItemCollectionVC.h"
#import "EBTViewController.h"

@protocol TenderDelegate;
//“Say hi to Harry”.
@class Department,SubDepartment;

typedef NS_ENUM(NSInteger, DiscountSubCategory) {
    QtyItemDiscount = 1,
    MixAndMatchDiscount,
    PriceMdItemDiscount,
    SwipeItemDiscount,
    
    SalesItemPercentageDiscount,
    SalesItemAmountDiscount,
    SalesBillPercentageDiscount,
    SalesBillAmountDiscount,
   
    ManualItemPercentageDiscount,
    ManualItemAmountDiscount,
    ManualBillPercentageDiscount,
    ManualBillAmountDiscount,
    
    /// All new id should be added under this.
};

typedef NS_ENUM(NSInteger, DiscountCategory) {
    DiscountCategoryPredefined = 1,
    DiscountCategoryCustomized,
    DiscountCategoryManual,
    DiscountCategoryInvalid = 1000,
};

@interface RcrPosVC : UIViewController <UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UITextViewDelegate,PosMenuDelegate,TenderDelegate,GiftCardPosDelegate>
{
    NSMutableDictionary *currentBillEntryDictionary;
    
    NSArray *menuId;
    
    UIViewController *giftcardPopup;
    
    UIPopoverPresentationController *giftcardPopOverController;
    
    RemoveTaxVC *removeTaxVC;
    GusestSelectionVC *guestSelectionVC;

}

@property (nonatomic, weak) IBOutlet UITextField *departmentAmountTextField;

@property (nonatomic, strong) IBOutlet UIView *departmentNumpadView;
@property (nonatomic, weak) IBOutlet UIView *departmentFavouriteContainer;
@property (nonatomic, weak) IBOutlet UIView *posMenuContainer;

@property (nonatomic, weak) IBOutlet UIButton *enterDepartment;
@property (nonatomic, weak) IBOutlet UIButton *buttonForOfflineInvoiceCount;
@property (nonatomic, weak) IBOutlet UIButton *btnAddCustomerLoyalty;
@property (nonatomic, weak) IBOutlet UIButton *btnGuestAdd;

@property (nonatomic, weak) IBOutlet UILongPressGestureRecognizer *longPressGesture;

@property (nonatomic, strong) PosMenuVC *posMenuVC;
@property (nonatomic, strong) RemoveTaxVC *removeTaxVC;
@property (nonatomic, strong) TenderShortcutVC *tenderShortcutVC;
@property (nonatomic, strong) EBTViewController *eBTViewController;
@property (nonatomic, strong) DepartmetCollectionVC *departments;
@property (nonatomic, strong) SubDepartmetCollectionVC *subDeptCollectionVC;
@property (nonatomic, strong) FavouriteCollectionVC *favourite;
@property (nonatomic, strong) SubDeptItemCollectionVC *subDeptItemCollectionVC;
@property (nonatomic, strong) UpdateManager *updateManager;

@property (nonatomic, strong) NSMutableArray *reciptDataAry;
@property (nonatomic, strong) NSMutableArray *payentVoidDataAry;

@property (nonatomic, strong) NSManagedObjectID * restaurantOrderObjectId;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, assign) NSInteger recallCount;

@property (nonatomic,strong) NSNumber *orderId;

@property (nonatomic) BOOL isDepartment;

@property (nonatomic, strong) NSMutableDictionary *dictGiftCard;
@property (nonatomic, strong) NSMutableDictionary *selectedCustomerDetail;
@property (nonatomic, strong) NSMutableDictionary *selectedFuelDict;
@property (nonatomic, strong) NSMutableDictionary *restaurantOrderDictionary;

@property (nonatomic, assign) float fuelPumpPrice;

@property (nonatomic, strong) NSMutableArray <UIViewController *> *presentedViewControllers;

@property (nonatomic, strong) NSString *shiftInRequire;
@property (nonatomic, strong) NSString *moduleIdentifierString;



-(void)setItemDetail:(Item *)anitem;
-(void)processNextStepForItem;
- (void)_launchPriceAtPos_Retail:(Item *)item;
-(void)didSelectedDepartment:(Department *)selectedDepartment withUICollectionViewCell:(UICollectionViewCell *)collectionCell;
-(void)didSelectedSubDepartment:(SubDepartment *)selectedSubDepartment department:(Department *)selectedDepartment;
- (void)addItemWithItemId:(NSString *)itemId withSalesPrice:(NSString *)salesPrice ;
- (NSMutableDictionary *)setSubTotalsToDictionaryForReciptArray:(NSMutableArray *)dataArray;

- (Item*)fetchAllItems :(NSString *)itemId;
- (Department*)fetchAllDepartments :(NSString *)strdeptId;
//- (SubDepartment *)fetchAllSubDepartments :(NSString *)strSubDeptId;
- (void)setFeesAmount:(NSString*)amountValue type:(NSString*)type checkCash:(BOOL)checkCash;
-(NSString *)sectionNameForHeader:(NSString *)sectionName;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSMutableArray *reciptDataAryForBillOrder;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *logOutMessage;


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller;
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath ;
- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type;
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller ;

-(IBAction)loadDepartment:(id)sender;
-(IBAction)loadFavouriteItem:(id)sender;
- (void)presentViewAsModal:(UIViewController *)presentedViewController;
- (void)removePresentModalView;
-(void)dropAmountPopUpOpenProcess;
- (void)failToOpenDrawer;
@end


@interface RcrPosVC (ForRcRGas)
-(NSManagedObjectID *)createRCRGasForBillDictionary:(NSMutableDictionary *)billDictionary;
-(void) didSelectwithMultipleItemArray:(NSMutableArray *)selectedItemArray;
- (void)updateBillUI;


@end
