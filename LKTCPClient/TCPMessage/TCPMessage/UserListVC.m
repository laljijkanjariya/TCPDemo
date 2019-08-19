//
//  UserListVC.m
//  TCPMessage
//
//  Created by Siya9 on 29/01/18.
//  Copyright © 2018 Siya9. All rights reserved.
//

#import "UserListVC.h"
#import <CoreData/CoreData.h>
#import "TCPClientManager.h"
#import "TCPMessageUpdateManager.h"
#import "UserMessageDetailVC.h"

@interface UserListVC ()<NSFetchedResultsControllerDelegate>{
    TCPClientManager * clienManager;
    NSString * strCurrentUserId;
}

@property (nonatomic, strong) NSManagedObjectContext * managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController * userListRC;
@property (nonatomic, weak) IBOutlet UITableView * tblUserList;

@end

@implementation UserListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    clienManager = [TCPClientManager sharedTCPClientManager];
    self.managedObjectContext = [TCPMessageDBManager sharedTCPMessageDBManager].persistentContainer.viewContext;
    
    strCurrentUserId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];

    if (self.userListRC.fetchedObjects.count == 0) {
        [clienManager sendRequestData:@{@"userName":strCurrentUserId} forRequest:@"GetAllUser" withCompletionHandler:^(NSDictionary *response) {
            if (response != nil && [response[@"responseData"][@"isError"] intValue] == 0) {
                NSArray * arrUsers = response[@"responseData"][@"Data"];
                
                NSManagedObjectContext * moc = [TCPMessageUpdateManager privateConextFromParentContext:self.managedObjectContext];
                for (NSDictionary * dictUser in arrUsers) {
                    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userID == %@",dictUser[@"userID"]];
                    User * user = (User *)[TCPMessageUpdateManager fetchEntitysWithName:@"User" predicate:predicate isCreate:TRUE moc:moc];
                    user.userID = dictUser[@"userID"];
                    user.displayName = dictUser[@"displayName"];
                    user.status = [dictUser[@"status"] intValue];
                }
                [TCPMessageUpdateManager saveContext:moc];
            }
        }];
    }
    // Do any additional setup after loading the view.
}
-(IBAction)btnLogoutUser:(id)sender {
    [clienManager sendRequestData:@{@"userName":strCurrentUserId} forRequest:@"Logoff" withCompletionHandler:^(NSDictionary *response) {
        [self.navigationController popViewControllerAnimated:TRUE];
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Table view data source -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    NSArray *sections = self.userListRC.sections;
    return sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSArray *sections = self.userListRC.sections;
    id <NSFetchedResultsSectionInfo> sectionInfo = sections[section];
    return sectionInfo.numberOfObjects;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    [cell updateView:[self.userListRC objectAtIndexPath:indexPath]];
    return cell;
}
// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UserMessageDetailVC * objUserMessageDetailVC =
    [[UIStoryboard storyboardWithName:@"Main" bundle:NULL] instantiateViewControllerWithIdentifier:@"UserMessageDetailVC_sid"];
    objUserMessageDetailVC.toUser = [self.userListRC objectAtIndexPath:indexPath];
    [self.navigationController pushViewController:objUserMessageDetailVC animated:TRUE];
    [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
}

#pragma mark - CoreData Methods
- (NSFetchedResultsController *)userListRC {
    
    if (_userListRC != nil) {
        return _userListRC;
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    fetchRequest.fetchBatchSize = 20;
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userID != %@",strCurrentUserId];
    fetchRequest.predicate = predicate;

    
    NSSortDescriptor * aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:TRUE];
    NSArray *sortDescriptors = @[aSortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Create and initialize the fetch results controller.
    _userListRC = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    [_userListRC performFetch:nil];
    _userListRC.delegate = self;
    
    return _userListRC;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    if (![controller isEqual:self.userListRC]) {
        return;
    }
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tblUserList beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    if (![controller isEqual:self.userListRC]) {
        return;
    }
    
    UITableView *tableView = self.tblUserList;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate:
            if ([[tableView indexPathsForVisibleRows] indexOfObject:indexPath] != NSNotFound) {
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
    if (![controller isEqual:self.userListRC]) {
        return;
    }
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tblUserList insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tblUserList deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if (![controller isEqual:self.userListRC]) {
        return;
    }
    [self.tblUserList endUpdates];
}

@end
@interface UserListCell ()
@end

@implementation UserListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
-(void)updateView:(User*)user{
    self.lblUserName.text = user.displayName;
    self.viewStatus.backgroundColor = (user.status == 1)?[UIColor greenColor]:[UIColor redColor];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
@end
