//
//  DepartmetCollectionVC.h
//  RapidRMS
//
//  Created by siya-IOS5 on 27/11/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SubDepartment, Department;

@protocol SubDepartmetCollectionVcDelegate <NSObject>

-(void)didSelectSubDepartment:(SubDepartment *)selectedSubDepartment;
-(void)didSelectDepartmentFromSubDepartment:(Department *)selectedDepartment;

@end

@protocol SubDepartmetCollectionCountDelegate <NSObject>
-(void)didChangeSubDepartmentCount:(NSInteger )count;
@end


@interface SubDepartmetCollectionVC : UIViewController <NSFetchedResultsControllerDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UIScrollViewDelegate>//DepartmetCollectionVcDelegate

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, weak) id<SubDepartmetCollectionVcDelegate> subDepartmetCollectionVcDelegate;
@property (nonatomic, weak) id<SubDepartmetCollectionCountDelegate> subDepartmetCollectionCountDelegate;

@property (assign) CGFloat numerOfItemPerPage;

-(void)loadSubDepartmentsOfDepartment:(Department *)selectedDepartment;

@end