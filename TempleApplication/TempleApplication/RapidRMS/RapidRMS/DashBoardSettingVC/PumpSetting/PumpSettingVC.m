//
//  PumpSettingVC.m
//  RapidRMS
//
//  Created by CI INFOTECH on 18/11/15.
//  Copyright © 2015 Siya Infotech. All rights reserved.
//

#import "PumpSettingVC.h"

@interface PumpSettingVC ()<UpdateDelegate,UICollectionViewDataSource,UICollectionViewDelegate>

{
//    GasPumpCountListVC *gasPumpcountList;
}
@property (nonatomic, weak) IBOutlet UITableView *tblPumpList;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionPumpList;
@property (nonatomic, strong) UpdateManager *updateManager;
@property (nonatomic, strong) NSMutableArray *fuelCount;

@property (nonatomic, strong) NSMutableArray *pumpCount;
@property(nonatomic,strong)NSMutableArray *pumpList;

@end

@implementation PumpSettingVC
@synthesize gasPumpManagedObjectContext = _gasPumpManagedObjectContext;


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title=@"Pump Setting";
    UIImage *image3 = [UIImage imageNamed:@"RmsheaderLogo.png"];
    CGRect frameimg = CGRectMake(0, 0, image3.size.width, image3.size.height);
    UIButton *someButton = [[UIButton alloc] initWithFrame:frameimg];
    [someButton setBackgroundImage:image3 forState:UIControlStateNormal];
    UIBarButtonItem *mailbutton =[[UIBarButtonItem alloc] initWithCustomView:someButton];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
    UIBarButtonItem *intercom =[[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItems = @[mailbutton,intercom];
    self.pumpCount = [[NSMutableArray alloc]init];
    self.collectionPumpList.delegate = self;
    self.collectionPumpList.dataSource = self;
    [self makeFuelandPumpList];
    [self.collectionPumpList reloadData];
    //self.pumpList = (NSMutableArray *)[self checkForPumpList];
}

-(void)makeFuelandPumpList{
    
        
    NSMutableDictionary *fuel1 = [@{
                                   @"Name":@"Fuel 1",
                                   @"Price":@"10.00",
                                   @"Case Full":@"$12.20",
                                   @"Case Self":@"$13.11",
                                   @"Credit Full":@"$12.20",
                                   @"Credit Self":@"$14.20",
                                   } mutableCopy ];
    NSMutableDictionary *fuel2 = [@{
                                   @"Name":@"Fuel 2",
                                   @"Price":@"12.00",
                                   @"Case Full":@"$14.10",
                                   @"Case Self":@"$17.30",
                                   @"Credit Full":@"$13.20",
                                   @"Credit Self":@"$15.20",
                                   } mutableCopy ];
    
    NSMutableDictionary *fuel3 = [@{
                                    @"Name":@"Fuel 3",
                                    @"Price":@"12.00",
                                    @"Case Full":@"$14.10",
                                    @"Case Self":@"$17.30",
                                    @"Credit Full":@"$13.20",
                                    @"Credit Self":@"$15.20",
                                    } mutableCopy ];
    
    [self.fuelCount addObject:fuel1];
    [self.fuelCount addObject:fuel2];
    [self.fuelCount addObject:fuel3];
    
    
    
    NSMutableDictionary *pump1 = [@{
                                    @"Name":@"Pump 1",
                                    @"Price":@"8.00",
                                    @"Case Full":@"7.90",
                                    @"Case Self":@"8.80",
                                    } mutableCopy ];
    NSMutableDictionary *pump2 = [@{
                                    @"Name":@"Pump 2",
                                    @"Price":@"9.00",
                                    @"Case Full":@"10.10",
                                    @"Case Self":@"9.10",
                                    } mutableCopy ];
    
    NSMutableDictionary *pump3 = [@{
                                    @"Name":@"Pump 3",
                                    @"Price":@"2.00",
                                    @"Case Full":@"3.80",
                                    @"Case Self":@"3.00",
                                    } mutableCopy ];

    
    [self.pumpCount addObject:pump1];
    [self.pumpCount addObject:pump2];
    [self.pumpCount addObject:pump3];
    
}
-(NSArray *)checkForPumpList
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"FuelPump" inManagedObjectContext:self.gasPumpManagedObjectContext];
    fetchRequest.entity = entity;
    
    NSArray *resultSet = [UpdateManager executeForContext:self.gasPumpManagedObjectContext FetchRequest:fetchRequest];
    
    return resultSet;
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 2;

}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{

//    PumpListCell *cell = (UICollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"PumpListCell" forIndexPath:indexPath];
//
//    return cell;
    UICollectionViewCell *cell=(UICollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
 
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"GasPump" bundle:nil];
//    gasPumpcountList = [storyBoard instantiateViewControllerWithIdentifier:@"GasPumpCountListVC"];
    
//    [self.navigationController pushViewController:gasPumpcountList animated:YES];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.updateManager = [[UpdateManager alloc] initWithManagedObjectContext:self.gasPumpManagedObjectContext delegate:self];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
