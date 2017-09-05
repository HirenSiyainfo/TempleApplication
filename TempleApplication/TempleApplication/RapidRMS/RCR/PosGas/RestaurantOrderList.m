//
//  RestaurantOrderList.m
//  RapidRMS
//
//  Created by siya-IOS5 on 4/7/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "RestaurantOrderList.h"
#import "RmsDbController.h"
#import "AddRestaurantOrder.h"
#import "RestaurantOrderListCell.h"
#import "RestaurantOrder+Dictionary.h"
#import "RcrPosVC.h"

@interface RestaurantOrderList () <UpdateDelegate,AddRestaurantOrderDelegate,UIPopoverPresentationControllerDelegate>
{
    AddRestaurantOrder *addRestaurantOrder;
    UIPopoverPresentationController *addRestaurantPopOverViewController;
    
}
@property (nonatomic, weak) IBOutlet UILabel *registerNameLabel;
@property (nonatomic, weak) IBOutlet UITableView *restaurantOrderListTable;

@property (nonatomic, strong) NSFetchedResultsController *restaurantOrderListResultContoller;

@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) UpdateManager *updateManager;

@end

@implementation RestaurantOrderList

@synthesize restaurantOrderListResultContoller = _restaurantOrderListResultContoller;
@synthesize managedObjectContext = _managedObjectContext;

- (void)viewDidLoad
{
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    _registerNameLabel.text = (self.rmsDbController.globalDict)[@"RegisterName"];
    self.updateManager = [[UpdateManager alloc] initWithManagedObjectContext:self.managedObjectContext delegate:self];
    self.navigationController.navigationBarHidden = YES;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _restaurantOrderListResultContoller = nil;
//    [self restaurantOrderListResultContoller];
    [_restaurantOrderListTable reloadData];

}

-(IBAction)logOut:(id)sender
{
    [self.navigationController popViewControllerAnimated:TRUE];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSFetchedResultsController *)restaurantOrderListResultContoller
{
    if (_restaurantOrderListResultContoller != nil) {
        return _restaurantOrderListResultContoller;
    }
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"RestaurantOrder" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    NSPredicate *restaurantOrderPredicate = [NSPredicate predicateWithFormat:@"state = %d",OPEN_ORDER];
    fetchRequest.predicate = restaurantOrderPredicate;
    
    NSSortDescriptor *aSortDescriptor   = [[NSSortDescriptor alloc] initWithKey:@"order_id" ascending:YES];
    NSArray *sortDescriptors = @[aSortDescriptor];
    fetchRequest.sortDescriptors = sortDescriptors;
    
    // Create and initialize the fetch results controller.
    _restaurantOrderListResultContoller = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:_managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    [_restaurantOrderListResultContoller performFetch:nil];
    _restaurantOrderListResultContoller.delegate = self;
    return _restaurantOrderListResultContoller;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sections = self.restaurantOrderListResultContoller.sections;
    id <NSFetchedResultsSectionInfo> sectionInfo = sections[section];
    return sectionInfo.numberOfObjects;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RestaurantOrderListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RestaurantOrderListCell"];

    
    cell.tableNo.text = [[self.restaurantOrderListResultContoller objectAtIndexPath:indexPath] valueForKey:@"tabelName"];
    cell.noOfGuest.text = [NSString stringWithFormat:@"%@",[[self.restaurantOrderListResultContoller objectAtIndexPath:indexPath] valueForKey:@"noOfGuest"]] ;
    cell.totalAmount.text = [NSString stringWithFormat:@"%@",[[self.restaurantOrderListResultContoller objectAtIndexPath:indexPath] valueForKey:@"totalAmount"]];
    cell.backgroundColor = [cell restaurantItemForRestaurantOrder:[self.restaurantOrderListResultContoller objectAtIndexPath:indexPath]];
    
    NSDate * date = [[self.restaurantOrderListResultContoller objectAtIndexPath:indexPath] valueForKey:@"startTime"];
    //Create the dateformatter object
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM/dd/yyyy hh:mm a";
    NSString *printDateTime = [dateFormatter stringFromDate:date];
    cell.dateTime.text = [NSString stringWithFormat:@"%@",printDateTime];
    cell.duration.text = [cell durationForOrderStartDate:[[self.restaurantOrderListResultContoller objectAtIndexPath:indexPath] valueForKey:@"startTime"]];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RestaurantOrder *restaurantOrder = [self.restaurantOrderListResultContoller objectAtIndexPath:indexPath];
//    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"RcrStoryboard" bundle:nil];
    RcrPosVC *dashboardVC = [storyBoard instantiateViewControllerWithIdentifier:@"RcrPosRestaurantVC"];
    dashboardVC.managedObjectContext = self.rmsDbController.managedObjectContext;
    dashboardVC.restaurantOrderObjectId = restaurantOrder.objectID;
    dashboardVC.shiftInRequire = self.shiftRequire;
    dashboardVC.orderId = restaurantOrder.order_id;
    dashboardVC.moduleIdentifierString = @"RcrPosRestaurantVC";
    [self.navigationController pushViewController:dashboardVC animated:YES];
    self.shiftRequire = @"";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        RestaurantOrder *restaurantOrder = [self.restaurantOrderListResultContoller objectAtIndexPath:indexPath];
        NSManagedObjectContext *privateManageobjectContext = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
        [UpdateManager deleteFromContext:privateManageobjectContext objectId:restaurantOrder.objectID];
        [UpdateManager saveContext:privateManageobjectContext];
    }
}

-(void)didInsertRestaurantOrder:(NSDictionary *)orderDetail
{
  /*  NSMutableDictionary *restaurantOrderDictionary = [[NSMutableDictionary alloc]init];
    [restaurantOrderDictionary setObject:nOfGuest forKey:@"noOfGuest"];
    [restaurantOrderDictionary setObject:tableName forKey:@"tableName"];
    [addRestaurantPopOverViewController dismissPopoverAnimated:TRUE];*/
    
    NSManagedObjectContext *privateContextObject = [UpdateManager privateConextFromParentContext:self.managedObjectContext];
    NSMutableDictionary *restaurantOrderDetail = [[NSMutableDictionary alloc]init];
    restaurantOrderDetail[@"noOfGuest"] = orderDetail[@"NoOfGuest"];
    restaurantOrderDetail[@"tableName"] = orderDetail[@"TabelName"];
    restaurantOrderDetail[@"orderid"] = @(0);
    restaurantOrderDetail[@"orderState"] = @(OPEN_ORDER);
    restaurantOrderDetail[@"isDineIn"] = orderDetail[@"isDineIn"];
    restaurantOrderDetail[@"UserId"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
    
    RestaurantOrder *restaurantOrder = [self.updateManager insertRestaurantOrderListInLocalDataBase:restaurantOrderDetail withContext:privateContextObject];
    
    [addRestaurantOrder dismissViewControllerAnimated:YES completion:nil];

    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"RcrStoryboard" bundle:nil];
    RcrPosVC *dashboardVC = [storyBoard instantiateViewControllerWithIdentifier:@"RcrPosRestaurantVC"];
    dashboardVC.managedObjectContext = self.rmsDbController.managedObjectContext;
    dashboardVC.shiftInRequire = self.shiftRequire;
//    dashboardVC.restaurantOrderDictionary = restaurantOrderDetail;
    dashboardVC.restaurantOrderObjectId = restaurantOrder.objectID;
    dashboardVC.moduleIdentifierString = @"RcrPosRestaurantVC";

    [self.navigationController pushViewController:dashboardVC animated:YES];
    self.shiftRequire = @"";
    
}
-(void)didCancelRestaurantOrder
{
    [addRestaurantOrder dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)newRestaurantOrder:(id)sender
{
    addRestaurantOrder = [self.storyboard instantiateViewControllerWithIdentifier:@"AddRestaurantOrder"];
    addRestaurantOrder.addRestaurantOrderDelegate = self;
    // Present the view controller using the popover style.
    addRestaurantOrder.modalPresentationStyle = UIModalPresentationPopover;
    [self presentViewController:addRestaurantOrder animated:YES completion:nil];
    
    // Get the popover presentation controller and configure it.
    addRestaurantPopOverViewController = [addRestaurantOrder popoverPresentationController];
    addRestaurantPopOverViewController.delegate = self;
    addRestaurantOrder.preferredContentSize = CGSizeMake(275, 275);
    addRestaurantPopOverViewController.permittedArrowDirections = NO;
    addRestaurantPopOverViewController.sourceView = self.view;
    addRestaurantPopOverViewController.sourceRect = CGRectMake(90, 170, 275, 90);
}


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    if (![controller isEqual:self.restaurantOrderListResultContoller]) {
        return;
    }
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [_restaurantOrderListTable beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    if (![controller isEqual:self.restaurantOrderListResultContoller]) {
        return;
    }
    
    UITableView *tableView = _restaurantOrderListTable;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate:
            if ([tableView.indexPathsForVisibleRows indexOfObject:indexPath] != NSNotFound) {
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    if (![controller isEqual:self.restaurantOrderListResultContoller]) {
        return;
    }
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [_restaurantOrderListTable insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [_restaurantOrderListTable deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if (![controller isEqual:self.restaurantOrderListResultContoller]) {
        return;
    }
    [_restaurantOrderListTable endUpdates];
}




@end
