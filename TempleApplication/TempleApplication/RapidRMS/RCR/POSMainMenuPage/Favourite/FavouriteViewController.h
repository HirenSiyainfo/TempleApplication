//
//  FavouriteViewController.h
//  RapidRMS
//
//  Created by Siya Infotech on 28/05/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FavouriteViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,NSFetchedResultsControllerDelegate>

@property (nonatomic ,weak) IBOutlet UICollectionView *favouriteCollectionView;

@end
