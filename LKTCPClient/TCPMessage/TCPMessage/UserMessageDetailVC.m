//
//  UserMessageDetailVC.m
//  TCPMessage
//
//  Created by Siya9 on 30/01/18.
//  Copyright © 2018 Siya9. All rights reserved.
//

#import "UserMessageDetailVC.h"
#import "TCPClientManager.h"
#import "TCPMessageUpdateManager.h"
#import "User+CoreDataClass.h"
#import "Message+CoreDataClass.h"

@interface UserMessageDetailVC ()<NSFetchedResultsControllerDelegate>{
    TCPClientManager * clienManager;
    NSString * strCurrentUserId;
}

@property (nonatomic, strong) NSManagedObjectContext * managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController * userMessageListRC;
@property (nonatomic, weak) IBOutlet UITableView * tblUserMessageList;
@property (nonatomic, weak) IBOutlet UITextField * txtMessage;
@property (nonatomic, weak) IBOutlet UILabel * lblUsername;

@end

@implementation UserMessageDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    clienManager = [TCPClientManager sharedTCPClientManager];
    self.managedObjectContext = [TCPMessageDBManager sharedTCPMessageDBManager].persistentContainer.viewContext;
    strCurrentUserId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];

    self.lblUsername.text = self.toUser.displayName;
    self.tblUserMessageList.rowHeight = UITableViewAutomaticDimension;
    self.tblUserMessageList.estimatedRowHeight = 100.0f;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)btnBackToUserList:(id)sender {
    [self.navigationController popViewControllerAnimated:TRUE];
}
-(IBAction)btnSendMessasge:(id)sender {
    if (self.txtMessage.text.length > 0) {
        NSMutableDictionary * distSentMessage = [NSMutableDictionary new];
        distSentMessage[@"fromUserID"] = strCurrentUserId;
        distSentMessage[@"toUserID"] = self.toUser.userID;
        distSentMessage[@"message"] = self.txtMessage.text;
        distSentMessage[@"messageTime"] = [TCPMessageUpdateManager getStringDateFrom:[NSDate date]];
        
        NSManagedObjectContext * moc = [TCPMessageUpdateManager privateConextFromParentContext:self.managedObjectContext];
        Message * newMessages = (Message *)[NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:moc];
        
        User * fromUser = [TCPMessageUpdateManager getUserFromUserID:strCurrentUserId fromMOC:moc];
        User * toUser = [TCPMessageUpdateManager getUserFromUserID:self.toUser.userID fromMOC:moc];
        
        newMessages.serverID = @"";
        newMessages.message = self.txtMessage.text;
        newMessages.fromUser = fromUser;
        newMessages.toUser = toUser;
        newMessages.created = [NSDate date];
        newMessages.updated = [NSDate date];
        newMessages.status = -1;
        [fromUser addSentMessagesObject:newMessages];
        [toUser addRecievedMessageObject:newMessages];
        
        [TCPMessageUpdateManager saveContext:moc];

        
        [clienManager sendRequestData:distSentMessage.copy forRequest:@"SentMessage" withCompletionHandler:^(NSDictionary *response) {
            NSLog(@" SentMessage Response \n%@",response);
            if (response != nil && [response[@"IsError"] intValue] == 0) {
                NSManagedObjectContext * mocUID = [TCPMessageUpdateManager privateConextFromParentContext:self.managedObjectContext];
                Message * messageUID = [mocUID objectWithID:newMessages.objectID];
                messageUID.serverID = response[@"responseData"][@"Data"];
                messageUID.status = 0;
                [TCPMessageUpdateManager saveContext:mocUID];
                NSLog(@"New message ID %@",response[@"responseData"][@"Data"]);
            }
        }];
        self.txtMessage.text = @"";
    }
}
#pragma mark - Table view data source -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    NSArray *sections = self.userMessageListRC.sections;
    return sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSArray *sections = self.userMessageListRC.sections;
    id <NSFetchedResultsSectionInfo> sectionInfo = sections[section];
    return sectionInfo.numberOfObjects;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Message * objMessage = [self.userMessageListRC objectAtIndexPath:indexPath];
    
    if (objMessage.status < 2 && objMessage.serverID != nil && ![objMessage.fromUser.userID isEqualToString:strCurrentUserId]) {
        NSString * strTime = [TCPMessageUpdateManager getStringDateFrom:[NSDate date]];
        [clienManager sendRequestData:@{@"msgUID":objMessage.serverID,@"newStatus":@(2),@"time":strTime} forRequest:@"UpdateMsgStatus" withCompletionHandler:^(NSDictionary *response) {
            NSLog(@"%@",response);
        }];
    }
    
    if ([objMessage.fromUser.userID isEqualToString:strCurrentUserId]) {
        UserMessageListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"current" forIndexPath:indexPath];
        [cell updateViewWithCurrentUserMessage:objMessage];
        return cell;
    }
    else{
        UserMessageListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"other" forIndexPath:indexPath];
        [cell updateViewWithOtherUserMessage:objMessage];
        return cell;
    }
}
// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
}

#pragma mark - CoreData Methods
- (NSFetchedResultsController *)userMessageListRC {
    
    if (_userMessageListRC != nil) {
        return _userMessageListRC;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    fetchRequest.fetchBatchSize = 20;
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"(fromUser.userID == %@ OR fromUser.userID == %@) AND (toUser.userID == %@ OR toUser.userID == %@)",strCurrentUserId,self.toUser.userID,strCurrentUserId,self.toUser.userID];
    fetchRequest.predicate = predicate;
    
    NSSortDescriptor * aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"created" ascending:TRUE];
    NSArray *sortDescriptors = @[aSortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Create and initialize the fetch results controller.
    _userMessageListRC = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    [_userMessageListRC performFetch:nil];
    _userMessageListRC.delegate = self;
    
    return _userMessageListRC;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    if (![controller isEqual:self.userMessageListRC]) {
        return;
    }
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tblUserMessageList beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    if (![controller isEqual:self.userMessageListRC]) {
        return;
    }
    
    UITableView *tableView = self.tblUserMessageList;
    
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
    if (![controller isEqual:self.userMessageListRC]) {
        return;
    }
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tblUserMessageList insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tblUserMessageList deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if (![controller isEqual:self.userMessageListRC]) {
        return;
    }
    [self.tblUserMessageList endUpdates];
}

@end
@interface UserMessageListCell ()
@end

@implementation UserMessageListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
-(void)updateViewWithOtherUserMessage:(Message *)objMessage {
    self.lblUserName.text = objMessage.fromUser.displayName;
    [self updateMessage:objMessage];
}
-(void)updateViewWithCurrentUserMessage:(Message *)objMessage {
    [self updateMessage:objMessage];
}
-(void)updateMessage:(Message *)objMessage {
    self.lblMessage.text = objMessage.message;
    self.lblMessageTime.text = [TCPMessageUpdateManager getStringDateFrom:objMessage.created];
    if (objMessage.status == -1) {
        self.viewStatus.backgroundColor = [UIColor orangeColor];
    }
    else if (objMessage.status == 0) {
        self.viewStatus.backgroundColor = [UIColor greenColor];
    }
    else if (objMessage.status == 1) {
        self.viewStatus.backgroundColor = [UIColor blueColor];
    }
    else if (objMessage.status == 2) {
        self.viewStatus.backgroundColor = [UIColor purpleColor];
    }
    else{
        self.viewStatus.backgroundColor = [UIColor redColor];
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
@end
