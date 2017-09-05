//
//  NewOrderScannerView.h
//  I-RMS
//
//  Created by Siya Infotech on 16/09/13.
//  Copyright (c) 2013 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "NDHTMLtoPDF.h"
#import "SideMenuVCDelegate.h"

@protocol GeneralDelegate <UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIGestureRecognizerDelegate,UITextViewDelegate,UIPopoverControllerDelegate,NDHTMLtoPDFDelegate,UIDocumentInteractionControllerDelegate>
@end


@interface NewOrderScannerView : UIViewController <GeneralDelegate,UpdateDelegate>

@property (nonatomic, weak) id<SideMenuVCDelegate> sideMenuVCDelegate;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic) BOOL isItemOrderUpdate;
@property (nonatomic, strong) NSMutableArray *arrInOpenData;

@end

