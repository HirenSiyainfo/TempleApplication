//
//  PurchaseOrderView.h
//  I-RMS
//
//  Created by Siya Infotech on 03/03/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPTagList.h"
#import "PurchaseOrderFilterListDetail.h"
#import "ManualFilterOptionViewController.h"
#import "NDHTMLtoPDF.h"
#import "POmenuListDelegateVC.h"
#ifdef LINEAPRO_SUPPORTED
#import "DTDevices.h"
#endif

@interface GenerateOrderView : UIViewController <UITableViewDataSource,UIActionSheetDelegate,UITableViewDelegate,UITextFieldDelegate,NDHTMLtoPDFDelegate,UIDocumentInteractionControllerDelegate,MPTagListDelegate,UpdateDelegate
#ifdef LINEAPRO_SUPPORTED
,DTDeviceDelegate
#endif
> {

}

@property(nonatomic, weak) id<POmenuListVCDelegate> pOmenuListVCDelegate;

@property (nonatomic, strong) NSMutableArray *arrUpdatePoData;
@property (nonatomic, strong) NSMutableArray *arrBackorderSelected;

@property (nonatomic, strong) NSString *strPopUpDepartment;
@property (nonatomic, strong) NSString *strPopUpSupplier;
@property (nonatomic, strong) NSString *strPopUpTags;
@property (nonatomic, strong) NSString *strPopUpTimeDuration;
@property (nonatomic, strong) NSString *strPopUpFromDate;
@property (nonatomic, strong) NSString *strPopUpToDate;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

-(void)supplierDepartmentArray:(NSMutableArray *)pArrayTemp;
-(void)hideBackOrderListWithAnimation;
@end
