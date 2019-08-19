//
//  TCPUserListVC.m
//  TCPMessageServer
//
//  Created by Siya9 on 26/01/18.
//  Copyright © 2018 Siya9. All rights reserved.
//

#import "TCPUserListVC.h"
#import "TCPMessageUpdateManager.h"
#import "User+CoreDataClass.h"
#import "TCPServerManager.h"

@interface TCPUserListVC () <NSFetchedResultsControllerDelegate>
@property (nonatomic, strong) NSManagedObjectContext * managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController * userListRC;
@property (nonatomic, weak) IBOutlet UITableView * tblUserList;
@property (nonatomic, weak) IBOutlet UITextField * txtServerPort;

@property (nonatomic, strong) TCPServerManager * objTCPServerManager;
@end

@implementation TCPUserListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.managedObjectContext = [TCPMessageDBManager sharedTCPMessageDBManager].persistentContainer.viewContext;
    
    self.txtServerPort.userInteractionEnabled = FALSE;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction)startTCPServer:(UIButton *)sender {
    if (sender.selected) {
        [self.objTCPServerManager stopServer];
    }
    else{
        if (self.objTCPServerManager==nil) {
            self.objTCPServerManager = [[TCPServerManager alloc]initWithPort:self.txtServerPort.text.intValue];
        }
        [self.objTCPServerManager stratServer];
    }
    sender.selected = !sender.selected;
}

-(IBAction)demoLoginRequest:(UIButton *)sender {
    NSMutableDictionary * dictLogin = [NSMutableDictionary new];
    dictLogin[@"requestType"] = @"Login";
    dictLogin[@"requestID"] = @(1);
    
    dictLogin[@"requestData"] = @{@"userName":@"lalji",@"userPassword":@"lalji"};
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictLogin
                                                       options:0
                                                         error:nil];
    NSString * request = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString * respose = [self.objTCPServerManager processesClientRequest:request withSocketId:0];
    NSLog(@"%@",respose);
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
    
}

#pragma mark - CoreData Methods
- (NSFetchedResultsController *)userListRC {
    
    if (_userListRC != nil) {
        return _userListRC;
    }
    
    // Create and configure a fetch request with the Book entity.
    //   NSString *sortColumn=@"item_Desc";
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    fetchRequest.fetchBatchSize = 20;
    
    NSSortDescriptor * aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"updatedInfo" ascending:FALSE];
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
