//
//  ItemInfoViewController.m
//  RapidRMS
//
//  Created by siya-IOS5 on 04/17/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "DisplayDepartmentInfoSideVC.h"
#import "RmsDbController.h"
#import "Department+Dictionary.h"

typedef enum __SECTION_NAMES__
{
    IMAGE_SECTION,
} SECTION_NAMES;


@interface DisplayDepartmentInfoSideVC () 

@property (nonatomic, strong) RimsController * rimsController;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

@implementation DisplayDepartmentInfoSideVC
//@synthesize itemInfoDictionary,objAddItem,tblItemInfo;
//@synthesize itemImage_Item;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    self.rimsController = [RimsController sharedrimController];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.managedObjectContext=self.rmsDbController.managedObjectContext;
    [self.tblDepartmentInfo reloadData];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(void)didUpdateDepatmentInfo:(NSDictionary *)updatedDepatmentInfo
{
    if (!self.departmentInfoDictionary) {
        self.departmentInfoDictionary = [NSMutableDictionary dictionary];
    }
    [self.departmentInfoDictionary addEntriesFromDictionary:updatedDepatmentInfo];
    [self.tblDepartmentInfo reloadData];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView==self.tblDepartmentInfo)
    {
        return 1;
    }
    else
    {
        return 1;
    }
    return 1;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView==self.tblDepartmentInfo)
    {
        if (section==IMAGE_SECTION)
        {
            return 1;
        }
    }
  
	return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView==self.tblDepartmentInfo) {
        
        if (indexPath.section==IMAGE_SECTION)
        {
            return 153;
        }
    }
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat headeHieght = 0;
    return headeHieght ;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *lable1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 300, 25)];
    lable1.textAlignment=NSTextAlignmentCenter;
    lable1.textColor = [UIColor colorWithRed:(0/255.f) green:(115/255.f) blue:(170/255.f) alpha:1.0];
    lable1.backgroundColor=[UIColor clearColor];
    lable1.font = [UIFont fontWithName:@"Helvetica" size:17.00];
    return lable1;
}
// custom view for header. will be adjusted to default or specified header height


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCellStyle style =  UITableViewCellStyleDefault;
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"BaseCell"];//
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    if (tableView==self.tblDepartmentInfo)
    {
        if (indexPath.section==IMAGE_SECTION) {
            if (indexPath.row==0)
            {
//                UIImageView *backGroundImage = [[UIImageView alloc]initWithFrame:CGRectMake(90, 20, 120, 120)];
//                backGroundImage.image = [UIImage imageNamed:@"iteminfoimgBg.png"];
                self.deptImage = [[AsyncImageView alloc] initWithFrame:CGRectMake((tableView.bounds.size.width-120)/2, 40, 120, 120)];
                (self.deptImage).backgroundColor = [UIColor clearColor];
                (self.deptImage.layer).borderColor = [UIColor clearColor].CGColor;
                if ([(self.departmentInfoDictionary)[@"imagePath"] isKindOfClass:[UIImage class]])
                {
                    UIImage *img = (self.departmentInfoDictionary)[@"imagePath"];
                    self.deptImage.image = img;
                }
                else
                {
                    NSString *imageImage=(self.departmentInfoDictionary)[@"imagePath"];
                    if ([imageImage isEqualToString:@""])
                    {
                        self.deptImage.image = [UIImage imageNamed:@"noimage.png"];
                    }
                    else if (imageImage.length == 0)
                    {
                        self.deptImage.image = [UIImage imageNamed:@"noimage.png"];
                    }
                    else
                    {
                        [self.deptImage loadImageFromURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",imageImage]]];
                    }
                }
                self.deptImage.clipsToBounds = YES;
                self.deptImage.layer.cornerRadius = 60;
                self.deptImage.layer.borderWidth = 2.0f;
                self.deptImage.layer.borderColor = [UIColor colorWithRed:0.847 green:0.851 blue:0.855 alpha:1.000].CGColor;

                [cell.contentView addSubview:self.deptImage];
                
                UIButton *btnCameraClick = [[UIButton alloc] initWithFrame:self.deptImage.frame];
                btnCameraClick.backgroundColor = [UIColor clearColor];
                [btnCameraClick addTarget:self action:@selector(clickImageCaptureForDepartment:) forControlEvents:UIControlEventTouchUpInside];
                [cell addSubview:btnCameraClick];
                
                
            }
        }
    }
    return cell;
}

-(void)clickImageCaptureForDepartment:(UIButton *)sender
{
    [self.objAddDepartment selectImageCaptureForDepartment:sender];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
