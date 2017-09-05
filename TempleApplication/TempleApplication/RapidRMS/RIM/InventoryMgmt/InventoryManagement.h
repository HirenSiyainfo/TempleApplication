//
//  InventoryManagement.h
//  I-RMS
//
//  Created by Siya Infotech on 09/08/13.
//  Copyright (c) 2013 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MultipleBarcodePopUpVC.h"
#import "SideMenuVCDelegate.h"
#ifdef LINEAPRO_SUPPORTED
#import "DTDevices.h"
#endif
#if 0
#import "AppDelegate.h"
//#import "menuViewController.h"
#import "RimMenuVC.h"
#import "AsyncImageView.h"
#import "GenerateOrderView.h"
#import "PurchaseOrderFilterListDetail.h"
#import "OpenListViewController.h"
#import "UpdateManager.h"
#import "ItemCountListVC.h"

@class RimMenuVC;
@class NewOrderScannerView;
@class InventoryOutScannerView;
@class InventoryCountView;
#endif

@interface InventoryManagement : UIViewController<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,UITabBarControllerDelegate,UITabBarDelegate,NSFetchedResultsControllerDelegate, UpdateDelegate,MultipleBarcodePopUpVCDelegate,UIPopoverControllerDelegate
#ifdef LINEAPRO_SUPPORTED
,DTDeviceDelegate
#endif
>
{
    
#ifdef LINEAPRO_SUPPORTED
    DTDevices *dtdev;
#endif
    BOOL flgDonebutton;
}

@property (nonatomic, strong, readonly) NSFetchedResultsController *itemResultsController;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, weak) id<SideMenuVCDelegate> sideMenuVCDelegate;

@property (nonatomic) BOOL checkSearchRecord;
@property (nonatomic) BOOL isItemActive;
@property (nonatomic) BOOL isKeywordFilter;
@property (nonatomic) BOOL isAbcShortingFilter;
@property (nonatomic) BOOL checkCalledFunction;
@property (nonatomic) BOOL isLablePrintSelect;

@property (nonatomic, weak) IBOutlet UIView *footerView;


@property (nonatomic, weak) IBOutlet UITableView *tblviewInventory;
//@property (nonatomic, weak) IBOutlet UITableView *filterTypeTable;

@property (nonatomic, weak) IBOutlet UIButton *btn_Done;
@property (nonatomic, weak) IBOutlet UIButton *showCalendar;

@property (nonatomic, weak) IBOutlet UIButton *btnAddItem;
@property (nonatomic, weak) IBOutlet UILabel *lblAddItem;

@property (nonatomic, weak) IBOutlet UIButton *btn_ItemInfo;
@property (nonatomic, weak) IBOutlet UILabel *lblItemInfo;

@property (nonatomic, weak) IBOutlet UIButton *btnSelectMode;
@property (nonatomic, weak) IBOutlet UILabel *lblSelectMode;

@property (nonatomic, weak) IBOutlet UIButton *btnLabelPrint;
@property (nonatomic, weak) IBOutlet UILabel *lblLabelPrint;

@property (nonatomic, weak) IBOutlet UIButton *btnMenu;
@property (nonatomic, weak) IBOutlet UILabel *lblMenu;

@property (nonatomic, weak) IBOutlet UIView *viewSubClassFooter;
@property (nonatomic, weak) IBOutlet UIButton *btnAddToListItem;

@property (nonatomic, weak) IBOutlet UITextField *txtUniversalSearch;

@property (nonatomic, strong) NSMutableArray *arrTempSelected;
@property (nonatomic, strong) NSMutableArray *itemSelectModeArray;

@property (nonatomic, strong) NSString *searchText;

-(void)reloadInventoryMgmtTable;

@end