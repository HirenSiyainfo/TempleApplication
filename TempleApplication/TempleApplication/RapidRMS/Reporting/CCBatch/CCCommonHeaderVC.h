//
//  CCCommonHeaderVC.h
//  RapidRMS
//
//  Created by Siya-mac5 on 27/06/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCBatchVC.h"

@protocol CCCommonHeaderVCDelegate <NSObject>

- (void)didSearch:(NSString *)text;
- (void)didClearSearch;

@end

@interface CCCommonHeaderVC : UIViewController

- (void)updateCCBatchCommonHeaderWith:(CCBatchTrnxDetailStruct *)cCBatchTrnxDetail;
- (void)clearSearchTextField;

@property (nonatomic, weak) id <CCCommonHeaderVCDelegate> cCCommonHeaderVCDelegate;
@end
