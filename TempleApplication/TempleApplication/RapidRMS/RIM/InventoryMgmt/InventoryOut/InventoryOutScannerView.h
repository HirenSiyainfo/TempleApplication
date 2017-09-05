//
//  NewOrderScannerView.h
//  I-RMS
//
//  Created by Siya Infotech on 16/09/13.
//  Copyright (c) 2013 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "SideMenuVCDelegate.h"

@class InventoryHome;

@interface InventoryOutScannerView : UIViewController <UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIGestureRecognizerDelegate,UITextViewDelegate, UpdateDelegate,UIPopoverControllerDelegate,NDHTMLtoPDFDelegate,UIDocumentInteractionControllerDelegate>


@property (nonatomic, weak) id<SideMenuVCDelegate> sideMenuVCDelegate;
@property (nonatomic) BOOL isItemOrderUpdate;
@property (nonatomic, strong) NSMutableArray *arrOutOpenData;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end