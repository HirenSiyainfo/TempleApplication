//
//  ReleaseModuleVC.h
//  RapidRMS
//
//  Created by Siya-mac5 on 07/08/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ReleaseModuleVCDelegate <NSObject>
- (void)startActivityIndicator;
- (void)stopActivityIndicator;
- (void)replaceRegisterResponse:(id)response error:(NSError *)error;
@end

@interface ReleaseModuleVC : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, weak)  id <ReleaseModuleVCDelegate> releaseModuleVCDelegate;

@property (nonatomic, strong) NSString *strBranchId;
@property (nonatomic, strong) NSString *strCOMCOD;

@property (nonatomic, strong) NSMutableArray *activeDevResultRelease;
@property (nonatomic, strong) NSMutableArray *activeModules;

@property (nonatomic, assign) BOOL isRcrActive;

-(void)makeReleaseActiveModule;
-(void)filterWithUserWiseReleaseModule:(NSString *)strRegName;
@end
