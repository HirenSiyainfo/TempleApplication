//
//  ItemInfoViewController.m
//  RapidRMS
//
//  Created by siya-IOS5 on 04/17/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "DisplaySubDepartmentInfoSideVC.h"
#import "RmsDbController.h"
#import "SubDepartment+Dictionary.h"

typedef enum __SECTION_NAMES__
{
    IMAGE_SECTION,
} SECTION_NAMES;


@interface DisplaySubDepartmentInfoSideVC ()

@property (nonatomic, strong) RimsController *rimsController;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

@implementation DisplaySubDepartmentInfoSideVC
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
    [self.tblSubDepartmentInfo reloadData];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(void)didUpdateSubDepatmentInfo:(NSDictionary *)updatedSubDepatmentInfo
{
    if (!self.subDepartmentInfoDictionary) {
        self.subDepartmentInfoDictionary = [NSMutableDictionary dictionary];
    }
    [self.subDepartmentInfoDictionary addEntriesFromDictionary:updatedSubDepatmentInfo];
    [self.tblSubDepartmentInfo reloadData];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.tblSubDepartmentInfo)
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
    if (tableView == self.tblSubDepartmentInfo)
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
    if (tableView == self.tblSubDepartmentInfo) {
        
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCellStyle style =  UITableViewCellStyleDefault;
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"BaseCell"];//
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    if (tableView == self.tblSubDepartmentInfo)
    {
        if (indexPath.section==IMAGE_SECTION) {
            if (indexPath.row==0)
            {
//                UIImageView *backGroundImage = [[UIImageView alloc]initWithFrame:CGRectMake(90, 20, 120, 120)];
//                backGroundImage.image = [UIImage imageNamed:@"iteminfoimgBg.png"];
                self.subDeptImage = [[AsyncImageView alloc] initWithFrame:CGRectMake((tableView.bounds.size.width-120)/2, 40, 120, 120)];
                
                (self.subDeptImage).backgroundColor = [UIColor clearColor];
                (self.subDeptImage.layer).borderColor = [UIColor clearColor].CGColor;
                if ([(self.subDepartmentInfoDictionary)[@"SubDeptImagePath"] isKindOfClass:[UIImage class]])
                {
                    UIImage *img = (self.subDepartmentInfoDictionary)[@"SubDeptImagePath"];
                    self.subDeptImage.image = img;
                }
                else
                {
                    NSString *imageImage=(self.subDepartmentInfoDictionary)[@"SubDeptImagePath"];
                    if ([imageImage isEqualToString:@""])
                    {
                        self.subDeptImage.image = [UIImage imageNamed:@"noimage.png"];
                    }
                    else if (imageImage.length == 0)
                    {
                        self.subDeptImage.image = [UIImage imageNamed:@"noimage.png"];
                    }
                    else
                    {
                        [self.subDeptImage loadImageFromURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",imageImage]]];
                    }
                }
                self.subDeptImage.clipsToBounds = YES;
                self.subDeptImage.layer.cornerRadius = 60;
                self.subDeptImage.layer.borderWidth = 2.0f;
                self.subDeptImage.layer.borderColor = [UIColor colorWithRed:0.847 green:0.851 blue:0.855 alpha:1.000].CGColor;

                [cell.contentView addSubview:self.subDeptImage];
//                [cell.contentView addSubview:backGroundImage];
                
                UIButton *btnCameraClick = [[UIButton alloc] initWithFrame:self.subDeptImage.frame];
                btnCameraClick.backgroundColor = [UIColor clearColor];
                [btnCameraClick addTarget:self action:@selector(clickImageCaptureForSubDepartment:) forControlEvents:UIControlEventTouchUpInside];
                [cell addSubview:btnCameraClick];
                
                
            }
        }
    }
    return cell;
}

-(void)clickImageCaptureForSubDepartment:(UIButton *)sender
{
    [self.objAddSubDepartmentVC selectImageCaptureForSubDepartment:sender];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
