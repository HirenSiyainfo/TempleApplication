//
//  ItemMultipleSelectionVC.h
//  RapidRMS
//
//  Created by Siya Infotech on 18/06/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

//
//  InventoryManagement.h
//  I-RMS
//
//  Created by Siya Infotech on 09/08/13.
//  Copyright (c) 2013 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#ifdef LINEAPRO_SUPPORTED
#import "DTDevices.h"
#endif
//#import "menuViewController.h"
#import "RimMenuVC.h"
#import "AsyncImageView.h"
#import "GenerateOrderView.h"
#import "PurchaseOrderFilterListDetail.h"
#import "OpenListVC.h"
#import "UpdateManager.h"
#import "NewManualItemVC.h"
#import "ManualEntryRecevieItemList.h"

@protocol POMultipleItemSelectionVCDelegate <NSObject>
    -(void)didSelectionChangeInPOMultipleItemSelectionVC:(NSMutableArray *) selectedObject;
@end

@class RimMenuVC;
@class NewOrderScannerView;
@class InventoryOutScannerView;
@class InventoryCountView;
@class DeliveryListScanVC;

@interface POMultipleItemSelectionVC : UIViewController<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,UITabBarControllerDelegate,UITabBarDelegate,NSFetchedResultsControllerDelegate, UpdateDelegate
#ifdef LINEAPRO_SUPPORTED
,DTDeviceDelegate
#endif
>

@property (nonatomic, weak) id<POMultipleItemSelectionVCDelegate> pOMultipleItemSelectionVCDelegate;

@property (nonatomic, assign) BOOL flgRedirectToOpenList;
@property (nonatomic, assign) BOOL checkSearchRecord;
@property (nonatomic, assign) BOOL flgRedirectToGenerateOdr;

@property (nonatomic, strong) ManualEntryRecevieItemList *objNewItemReceiveList;
@property (nonatomic, strong) NSMutableDictionary *objeNewSuppInfo;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

-(IBAction)cancelClick:(id)sender;
@end


