//
//  PosBrowserVC.m
//  CustomerDisplayApp
//
//  Created by Siya Infotech on 02/04/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "CustomerDisplayBrowserVC.h"
#import "CustomerDisplayBrowser.h"
#import "RmsDbController.h"
#import "RcrController.h"
#define kPOS_NAME @"PosName"
#import "CustomerDisplayConnection.h"

@interface CustomerDisplayBrowserVC () <CustomerDisplayBrowserDelegate>
{
    IntercomHandler *intercomHandler;
}
@property (nonatomic, weak) IBOutlet UITableView *posTable;
// stuff for bindings
@property (nonatomic, strong) RcrController *crmController;
@property (nonatomic, strong) RmsDbController *rmsDbController;

@property (nonatomic, strong, readwrite) NSMutableArray *       services;           // of NSNetService
@property (nonatomic, strong, readwrite) NSMutableArray *       connectedServices;           // of NSNetService

// private properties
@property (nonatomic, strong, readwrite) CustomerDisplayBrowser *  customerDisplayBrowser;

@property (nonatomic, strong) NSIndexPath *selectedRowIndPath;
@end

@implementation CustomerDisplayBrowserVC

@synthesize dashCustomer;
- (void)viewDidLoad
{
    [super viewDidLoad];

    UIImage* image3 = [UIImage imageNamed:@"RmsheaderLogo.png"];
    CGRect frameimg = CGRectMake(0, 0, image3.size.width, image3.size.height);
    UIButton *someButton = [[UIButton alloc] initWithFrame:frameimg];
    [someButton setBackgroundImage:image3 forState:UIControlStateNormal];
    UIBarButtonItem *mailbutton =[[UIBarButtonItem alloc] initWithCustomView:someButton];
   
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
    UIBarButtonItem *intercom =[[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItems = @[mailbutton,intercom];
    intercomHandler = [[IntercomHandler alloc] initWithButtton:button withViewController:self];
    
    
    self.services = [[NSMutableArray alloc] init];
    self.connectedServices = [[NSMutableArray alloc]init];
    self.customerDisplayBrowser = [[CustomerDisplayBrowser alloc] initWithDelegate:self];
    self.crmController = [RcrController sharedCrmController];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didConnectToPos:) name:@"ConnectedToDisplay" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDisconnectToPos:) name:@"DisconnectedToDisplay" object:nil];
    
    if (self.crmController.displayConnected) {
        [self.connectedServices addObject:self.crmController.displayName];
    }
    else
    {
        
    }
    
    // Register nib for PosBrowserCell
    [self.posTable registerNib:[UINib nibWithNibName:@"PosBrowserCell" bundle:nil] forCellReuseIdentifier:@"PosBrowserCell"];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    
//     self.navigationItem.rightBarButtonItem = self.editButtonItem;
//    
//    [self.navigationItem.rightBarButtonItem setImage:[UIImage imageNamed:@"RmsheaderLogo.png"]];
//    UIImage *image = [UIImage imageNamed:@"RmsheaderLogo.png"];
//    [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title=@"Customer Display";
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *device =  [userDefaults valueForKey:kPOS_NAME];
    if (device.length>0)
    {
        
    }
    else
    {
        [self.connectedServices removeAllObjects];
        [self.posTable reloadData];
    }

}
#pragma mark - Table view data source
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    if (section == 0)
//    {
//        if (self.connectedServices.count >0)
//        {
//            return 25;
//        }
//        return 0.01;
//    }
//    return 25;
//}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (self.connectedServices.count >0)
    {
    return 2;
    }
    return 1;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    if (self.connectedServices.count >0)
    {
        if (section == 0) {
                return @"    Connected";
        }
        
        else if(section == 1)
        {
            return @"    DisConnected";
        }
    }
    else
    {
        if (section == 0)
        {
            return @"    DisConnected";
        }

    }
    return @"";

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    if (self.connectedServices.count >0)
    {
        if (section == 0) {
            return 1;
        }
        else  if(section == 1)
            
        {
            if (self.services.count == 0) {
                return 1;
            }
            else
            {
                return self.services.count;
            }
 
        }
    }
    
    else
    {
        if (section == 0)
        {
            if (self.services.count == 0) {
                return 1;
            }
            else
            {
                return self.services.count;
            }
        }

    }
    return 1;
}


- (void)configureDisconnect:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath
{
    if (self.services.count == 0) {
        // need to configure differently ...
        cell.textLabel.text = @"Searching for the services ...";
    }
    else
    {
        NSNetService *aService = (self.services)[indexPath.row];
        cell.textLabel.text = aService.name;
        UIButton * subQty = [UIButton buttonWithType:UIButtonTypeInfoDark];
        subQty.frame = CGRectMake(600, 9, 25, 25);
        subQty.backgroundColor = [UIColor clearColor];
        subQty.contentMode = UIViewContentModeLeft;
        [cell.contentView addSubview:subQty];

    }
  
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PosBrowserCell" forIndexPath:indexPath];
    
    // Configure the cell...
    if (self.connectedServices.count >0)
    {
        if (indexPath.section == 0)
        {
            if (self.connectedServices.count >0)
            {
                cell.textLabel.text = (self.connectedServices)[indexPath.row];
                UIButton * subQty = [UIButton buttonWithType:UIButtonTypeInfoDark];
                subQty.frame = CGRectMake(600, 9, 25, 25);
                subQty.backgroundColor = [UIColor clearColor];
                subQty.contentMode = UIViewContentModeLeft;
                [cell.contentView addSubview:subQty];
            }
            else
            {
                cell.textLabel.text = @"";
                
            }
            return cell;
            
        }
        if (indexPath.section == 1)
        {
            [self configureDisconnect:cell indexPath:indexPath];
        }
    }
    else
    {
        if (indexPath.section == 0)
        {
            [self configureDisconnect:cell indexPath:indexPath];
        }
    }
    
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableVi
 
 ewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (self.connectedServices.count >0)
    {
    
        if (indexPath.section == 0) {
            if (self.connectedServices.count >0)
            {
                [dashCustomer goToDisplayConnection];
                
//                [self.crmController.customerDisplayClient disconnectFromDisplay];
//                [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPOS_NAME];
//                [self.connectedServices removeAllObjects];
//                [self.posTable reloadData];
            }
        }
        else if (indexPath.section == 1)
        {
            if (self.services.count == 0) {
                return;
            }
            NSArray *selectedRows = self.posTable.indexPathsForSelectedRows;
            
            if (selectedRows.count > 0) {
                self.selectedRowIndPath = selectedRows.firstObject;
                NSNetService * selectedService = (self.services)[(NSUInteger) self.selectedRowIndPath.row];
                [self.crmController.customerDisplayClient openStreamsToNetService:selectedService];
            }
        }
    }
    else
    {
        if (indexPath.section == 0)
        {
            if (self.services.count == 0) {
                return;
            }
            
            NSArray *selectedRows = self.posTable.indexPathsForSelectedRows;
            
            if (selectedRows.count > 0) {
                self.selectedRowIndPath = selectedRows.firstObject;
                NSNetService * selectedService = (self.services)[(NSUInteger) self.selectedRowIndPath.row];
                [self.crmController.customerDisplayClient openStreamsToNetService:selectedService];
            }
            
        }
    }
}

- (IBAction)serviceTableClickedAction:(id)sender {
    UITableView * table = (UITableView *) sender;
    NSArray *selectedRows = table.indexPathsForSelectedRows;
    
    if (selectedRows.count > 0) {
        NSIndexPath *selectedRow = selectedRows.firstObject;
        NSNetService * selectedService = (self.services)[(NSUInteger) selectedRow.row];
//        [self openStreamsToNetService:selectedService];
        [self.browserDelegate serviceSelected:selectedService];
    }
}

#pragma mark - <PosServiceBrowserDelegate>
- (void)didFindPos:(NSNetService *)posService {
    if (![self.services containsObject:posService]) {
        [self willChangeValueForKey:@"services"];
        [self.services addObject:posService];
        [self didChangeValueForKey:@"services"];
        [self.posTable reloadData];
    }

}

- (void)didRemovePos:(NSNetService*)posService {
    if ([self.services containsObject:posService]) {
        [self willChangeValueForKey:@"services"];
        [self.services removeObject:posService];
        [self didChangeValueForKey:@"services"];
        [self.posTable reloadData];
    }
}
- (IBAction)done:(id)sender {
    if (self.services.count == 0) {
        return;
    }

    NSArray *selectedRows = self.posTable.indexPathsForSelectedRows;

    if (selectedRows.count > 0) {
        NSIndexPath *selectedRow = selectedRows.firstObject;
        NSNetService * selectedService = (self.services)[(NSUInteger) selectedRow.row];
        //        [self openStreamsToNetService:selectedService];
        [self.browserDelegate serviceSelected:selectedService];
    }

    [self dismissViewControllerAnimated:YES completion:^{}];
}
- (void)didConnectToPos:(NSNotification*)notification {
    NSDictionary *dictionary = notification.userInfo;
    NSString *posName = dictionary[@"DisplayName"];
    [self.connectedServices removeAllObjects];
    [self.connectedServices addObject:posName];
    [self.posTable reloadData];

    // Send junk data
}
- (void)didDisconnectToPos:(NSNotification*)notification {
   // NSDictionary *dictionary = notification.userInfo;
   //NSString *posName = [dictionary objectForKey:@"DisplayName"];
    [self.connectedServices removeAllObjects];
    [self.posTable reloadData];

}
- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
