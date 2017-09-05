//
//  DepartmetCollectionVC.h
//  RapidRMS
//
//  Created by siya-IOS5 on 27/11/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubDepartment+Dictionary.h"

@protocol SubDepartmetItemsVcDelegate <NSObject>

-(void)didSelectSubDeptItem:(Item *)selectedSubDeprItem;
-(void)didSelectSubDeptFromItem:(SubDepartment *)selectedSubDepartment department:(Department *)selectedDepartment;

@end


@protocol SubDepartmetItemsCountDelegate <NSObject>

-(void)didChangeSubDepartmentItemCount:(NSInteger)subDepartmentItemCount;

@end


@interface SubDeptItemCollectionVC : UIViewController <NSFetchedResultsControllerDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UIScrollViewDelegate>//DepartmetCollectionVcDelegate

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (assign) CGFloat numerOfItemPerPage;

@property (nonatomic, weak) id<SubDepartmetItemsVcDelegate> subDepartmetItemsVcDelegate;
@property (nonatomic, weak) id<SubDepartmetItemsCountDelegate> subDepartmetItemsCountDelegate;

-(void)loadItemsOfSubDepartment:(SubDepartment *)selectedSubDepartment;
-(void)loadItemsOfDepartment:(Department *)selectedDepartment;

@end