//
//  DeliveryListView.h
//  I-RMS
//
//  Created by Siya Infotech on 06/03/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NDHTMLtoPDF.h"
#import "POmenuListDelegateVC.h"

@interface CloseListVC : UIViewController <UIActionSheetDelegate,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,NDHTMLtoPDFDelegate,UIDocumentInteractionControllerDelegate>

@property(nonatomic, weak) id<POmenuListVCDelegate> pOmenuListVCDelegate;

@end
