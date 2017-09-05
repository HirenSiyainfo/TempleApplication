//
//  OpenListViewController.h
//  I-RMS
//
//  Created by Siya Infotech on 06/03/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RimMenuVC.h"
#import "NDHTMLtoPDF.h"
// CoreData Import
#import "Department+Dictionary.h"
#import "POmenuListDelegateVC.h"

@interface OpenListVC : UIViewController <UIActionSheetDelegate, UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,NDHTMLtoPDFDelegate,UIDocumentInteractionControllerDelegate,UpdateDelegate>
    

@property (nonatomic, weak) id<POmenuListVCDelegate> pOmenuListVCDelegate;

@property (nonatomic, weak) IBOutlet UIView *uvPendingDeliveryList;
@property (nonatomic, weak) IBOutlet UIButton *btnDeliveryIn;
@property (nonatomic, weak) IBOutlet UITableView *tblPendingDeliveryData;

@property (nonatomic, assign) BOOL booltoolbardelivery;

@property (nonatomic, strong) NSMutableArray *arrPendingDeliveryData;
@property (nonatomic, strong) NSMutableArray *arrayGlobalPandingList;
@property (nonatomic, strong) NSMutableArray *arrTempSelectedData;

@property (nonatomic, strong) NSString *strSelectedPO_No;
@property (nonatomic, strong) NSString *strSelectedInvoiceNo;
@property (nonatomic, strong) NSString *strSelectedPurOrdId;
@property (nonatomic, strong) NSString *strSelectedRecieveId;
@property (nonatomic, strong) NSString *strSelectedDLTitle;
@property (nonatomic, strong) NSString *strSelectedDLDate;
@property (nonatomic, strong) NSString *strPopUpTimeDuration;
@property (nonatomic, strong) NSString *strPopUpFromDate;
@property (nonatomic, strong) NSString *strPopUpToDate;
@property (nonatomic, strong) NSString *strPopUpDepartment;
@property (nonatomic, strong) NSString *strPopUpSupplier;
@property (nonatomic, strong) NSString *strPopUpTags;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
