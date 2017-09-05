//
//  CCOverViewVC.h
//  RapidRMS
//
//  Created by Siya-mac5 on 18/06/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCBatchVC.h"

@interface CCOverViewVC : UIViewController

-(void)loadCCBatchPieChart:(NSMutableArray *)creditCardDetail;
- (void)updateCommonHeaderWith:(CCBatchTrnxDetailStruct *)cCBatchTrnxDetail;

@end
