//
//  ActiveModuleVC.h
//  RapidRMS
//
//  Created by Siya on 18/12/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ActiveModuleVCDelegate <NSObject>
- (void)startActivityIndicator;
- (void)stopActivityIndicator;
- (void)replaceRegisterResponse:(id)response error:(NSError *)error;
@end

@interface ActiveModuleVC : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UpdateDelegate>

@property (nonatomic, weak) id <ActiveModuleVCDelegate> activeModuleVCDelegate;

@property (nonatomic, strong) NSMutableArray *activeDevices;
@property (nonatomic, strong) NSMutableArray *activeModules;

@property (nonatomic, strong) NSString *strCOMCOD;
@property (nonatomic, strong) NSString *strBranchId;

@property (nonatomic, assign) BOOL isRcrActive;

-(void)makeUserWiseActiveModule;
-(void)filterWithRegisterWise:(NSNumber *)registerNumber;
-(void)loadAllUserModule;
@end
