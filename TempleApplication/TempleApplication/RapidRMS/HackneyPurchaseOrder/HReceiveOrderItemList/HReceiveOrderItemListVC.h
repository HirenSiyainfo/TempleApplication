//
//  HReceiveOrderItemListVC.h
//  RapidRMS
//
//  Created by Siya on 25/12/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EmailFromViewController.h"

@interface HReceiveOrderItemListVC : UIViewController<NSFetchedResultsControllerDelegate,UpdateDelegate>

@property (nonatomic, strong) NSString *strPoid;

-(void)searchVendorItemWithSearchString:(NSString *)strSearch;
@end
