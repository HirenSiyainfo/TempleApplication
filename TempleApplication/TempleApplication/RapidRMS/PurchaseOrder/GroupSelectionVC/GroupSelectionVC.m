//
//  GroupSelectionVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 04/04/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "GroupSelectionVC.h"
#import "RmsDbController.h"
#import "GroupMaster+Dictionary.h"

@interface GroupSelectionVC ()<UITableViewDataSource,UITableViewDelegate>

{
    MICheckBox *taxCheckBox;
    IntercomHandler *intercomHandler;

    UIAlertController *customerAlert;

    NSMutableArray *arrayCheckedGroup;
}

@property (nonatomic, weak) IBOutlet UITableView * tblGroupSelection;
@property (nonatomic, weak) IBOutlet UIButton *btnIntercom;

@property (nonatomic, strong) RmsDbController *rmsDbController;

@property (nonatomic, strong) NSMutableArray *responseGroupArray;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation GroupSelectionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    self.responseGroupArray = [[NSMutableArray alloc]init];
    [self getGroupDetails];
    intercomHandler = [[IntercomHandler alloc] initWithButtton:_btnIntercom withViewController:self];
    // Do any additional setup after loading the view from its nib.
}

- (void)getGroupDetails
{
    self.responseGroupArray = [[NSMutableArray alloc] init];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"GroupMaster" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"groupName" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortDescriptors = @[aSortDescriptor];
    fetchRequest.sortDescriptors = sortDescriptors;
    
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    
    if (resultSet.count > 0)
    {
        for (GroupMaster *groupmst in resultSet) {
            NSMutableDictionary *supplierDict=[[NSMutableDictionary alloc]init];
            supplierDict[@"groupName"] = groupmst.groupName;
            supplierDict[@"groupId"] = groupmst.groupId;
            supplierDict[@"Disc_Id"] = groupmst.disc_Id;
            [self.responseGroupArray addObject:supplierDict];
        }
    }
//    NSMutableDictionary *customDict=[[NSMutableDictionary alloc]init];
//    [customDict setObject:@"Custom" forKey:@"groupName"];
//    [customDict setObject:@"-1" forKey:@"groupId"];
//    [self.resposeGroupArray addObject:customDict];
    NSMutableDictionary *groupDict=[[NSMutableDictionary alloc]init];
    groupDict[@"groupName"] = @"None";
    groupDict[@"groupId"] = @"0";
    [self.responseGroupArray insertObject:groupDict atIndex:0];
    [_tblGroupSelection reloadData];
}

- (IBAction)btnBackClicked:(id)sender
{
    arrayCheckedGroup=[[NSMutableArray alloc]init];
    for(int i=0;i<self.responseGroupArray.count;i++)
    {
        NSMutableDictionary *dict = (self.responseGroupArray)[i];
        if(dict[@"Checked"]){
            [arrayCheckedGroup addObject:dict];
        }
        else
        {
            [arrayCheckedGroup removeObject:dict];
        }
    }
    if([self.callingFunction isEqualToString:@"GenerateOrderView"])
    {
        [self.groupSelectionVCDelegate didselectGroupSelection:[arrayCheckedGroup mutableCopy]];
//        self.generateOrderView.arrSelectedGroup = [arrayCheckedGroup mutableCopy];
//        [self.generateOrderView displaySelectedGroup];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark TableView Delegate & Data Source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.responseGroupArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCellStyle style =  UITableViewCellStyleDefault;
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"BaseCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    CGRect groupNameFrame;
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        taxCheckBox = [[MICheckBox alloc] initWithFrame:CGRectMake(280, 14, 22, 16)];
        groupNameFrame = CGRectMake(15, 7, 250, 30);
        
    }
    else
    {
        taxCheckBox = [[MICheckBox alloc] initWithFrame:CGRectMake(640, 14, 22, 16)];
        groupNameFrame = CGRectMake(15, 7, 350, 30);
    }
    
    [taxCheckBox setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [taxCheckBox setTitle:@"" forState:UIControlStateNormal];
    taxCheckBox.tag = indexPath.row;
    taxCheckBox.indexPath = [indexPath copy];
    taxCheckBox.delegate = self;
    taxCheckBox.isChecked = NO;
    [taxCheckBox setDefault];
    
    UILabel * lblGroupName = [[UILabel alloc] initWithFrame:groupNameFrame];
    lblGroupName.text = [NSString stringWithFormat:@"%@",[(self.responseGroupArray)[indexPath.row] valueForKey:@"groupName"]];
    lblGroupName.numberOfLines = 0;
    lblGroupName.textAlignment = NSTextAlignmentLeft;
    lblGroupName.backgroundColor = [UIColor clearColor];
    lblGroupName.textColor = [UIColor blackColor];
    lblGroupName.font = [UIFont fontWithName:@"Helvetica Neue" size:14];
    [cell.contentView addSubview:lblGroupName];
    
    NSMutableDictionary *dictTemp2 = (self.responseGroupArray)[indexPath.row];
    
    if([dictTemp2[@"Checked"]intValue]==1)
    {
        dictTemp2[@"Checked"] = @"1";
        taxCheckBox.isChecked = YES;
        [taxCheckBox setImage:[UIImage imageNamed:@"soundCheckMark.png"] forState:UIControlStateNormal];
        lblGroupName.textColor = [UIColor colorWithRed:0.0/255.0 green:117.0/255.0 blue:180.0/255.0 alpha:1.0];
    }
    
    for(int i = 0;i<self.checkedGroup.count;i++)
    {
        NSMutableDictionary *dictTemp = (self.checkedGroup)[i];
        if([dictTemp[@"groupId"]intValue] == [dictTemp2[@"groupId"]intValue])
        {
            dictTemp2[@"Checked"] = @"1";
            taxCheckBox.isChecked = YES;
            [taxCheckBox setImage:[UIImage imageNamed:@"soundCheckMark.png"] forState:UIControlStateNormal];
            lblGroupName.textColor = [UIColor colorWithRed:0.0/255.0 green:117.0/255.0 blue:180.0/255.0 alpha:1.0];
        }
    }
    [cell addSubview:taxCheckBox];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    taxCheckBox.indexPath = [indexPath copy];
    [taxCheckBox checkBoxClicked];
    [tableView reloadData];
}

#pragma mark -
#pragma mark Logic Implement

- (void) taxCheckBoxClickedAtIndex:(NSString *)index withValue:(BOOL)checked withIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *dictTemp = (self.responseGroupArray)[indexPath.row];
    //    if ([dictTemp [@"groupId"]  isEqual:@"-1"]) {
    //        [self customCategoryName];
    //        return;
    //    }
    if([dictTemp [@"groupId"]  isEqual:@"0"])
    {
        if(dictTemp[@"Checked"]){
            [dictTemp removeObjectForKey:@"Checked"];
            NSMutableDictionary *dictTemp2 = (self.responseGroupArray)[indexPath.row];
            for(int i = 0;i<self.checkedGroup.count;i++)
            {
                NSMutableDictionary *dictTemp = (self.checkedGroup)[i];
                if([dictTemp [@"groupId"] isEqual:dictTemp2 [@"groupId"]])
                {
                    [self.checkedGroup removeObjectAtIndex:i];
                }
            }
        }
        else
        {
            [self.checkedGroup removeAllObjects];
            for(int i = 0;i<self.responseGroupArray.count;i++)
            {
                NSMutableDictionary *dict = (self.responseGroupArray)[i];
                [dict removeObjectForKey:@"Checked"];
            }
            dictTemp[@"Checked"] = @"1";
            (self.responseGroupArray)[indexPath.row] = dictTemp;
        }
        [_tblGroupSelection reloadData];
    }
    
    else if(dictTemp[@"Checked"])
    {
        [dictTemp removeObjectForKey:@"Checked"];
        NSMutableDictionary *dictTemp2 = (self.responseGroupArray)[indexPath.row];
        for(int i = 0;i<self.checkedGroup.count;i++)
        {
            NSMutableDictionary *dictTemp = (self.checkedGroup)[i];
            if([dictTemp [@"groupId"] isEqualToNumber:dictTemp2 [@"groupId"]])
            {
                [self.checkedGroup removeObjectAtIndex:i];
            }
        }
    }
    
    else
    {
        for(int i = 0;i<self.responseGroupArray.count;i++)
        {
            NSMutableDictionary *dict = (self.responseGroupArray)[i];
            if ([dict [@"groupId"]  isEqual:@"0"]) {
                if (dict[@"Checked"]) {
                    [dict removeObjectForKey:@"Checked"];
                    (self.responseGroupArray)[i] = dict;
                }
            }
        }
        for(int i = 0;i<self.checkedGroup.count;i++)
        {
            NSMutableDictionary *dict = (self.checkedGroup)[i];
            if ([dict [@"groupId"]  isEqual:@"0"]) {
                if (dict[@"Checked"]) {
                    [self.checkedGroup removeObjectAtIndex:i];
                }
            }
        }
        dictTemp[@"Checked"] = @"1";
    }
    (self.responseGroupArray)[indexPath.row] = dictTemp;
    [_tblGroupSelection reloadData];
}

-(void)customCategoryName
{
    customerAlert = [UIAlertController alertControllerWithTitle:@"Group Master" message:@"Enter custom group name"
                                                 preferredStyle:UIAlertControllerStyleAlert];
    
    [customerAlert addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"Username";
     }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action)
                             {
                                 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                     [self getGroupDetails];
                                 });
                             }];
    UIAlertAction *done = [UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction * action)
                           {
                               if(customerAlert.textFields[0].text.length == 0)
                               {
                                   UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                                   {
                                       dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                           [self customCategoryName];
                                       });
                                   };
                                   [self.rmsDbController popupAlertFromVC:self title:@"Purchase Order" message:@"Please enter custom group name" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
                               }
                               else
                               {
                                   if([self.callingFunction isEqualToString:@"GenerateOrderView"])
                                   {
                                       NSMutableDictionary *customDict=[[NSMutableDictionary alloc]init];
                                       customDict[@"groupName"] = customerAlert.textFields[0].text;
                                       customDict[@"groupId"] = @"-1";
                                       customDict[@"Checked"] = @"1";
                                       NSArray *customeArray = @[customDict];
                                       [self.groupSelectionVCDelegate didselectGroupSelection:(NSMutableArray *)customeArray];
//                                       if (self.generateOrderView.arrSelectedGroup == nil) {
//                                           self.generateOrderView.arrSelectedGroup = [[NSMutableArray alloc] init];
//                                           [self.generateOrderView.arrSelectedGroup addObject:customDict];
//                                       }
//                                       else
//                                       {
//                                           self.generateOrderView.arrSelectedGroup = [customeArray mutableCopy];
//                                       }
//                                       [self.generateOrderView displaySelectedGroup];
                                       [_tblGroupSelection reloadData];
                                       [self.navigationController popViewControllerAnimated:YES];
                                   }
                               }
                           }];
    
    [customerAlert addAction:done];
    [customerAlert addAction:cancel];
    [self presentViewController:customerAlert animated:YES completion:nil];
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
