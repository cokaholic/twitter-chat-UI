//
//  ChatRoomViewController.m
//  TwitChat
//
//  Created by Keisuke_Tatsumi on 2014/08/19.
//  Copyright (c) 2014年 Keisuke Tatsumi. All rights reserved.
//

#import "ChatRoomViewController.h"

static NSString * const kJSQDemoAvatarNameCook = @"Tim Cook";
static NSString * const kJSQDemoAvatarNameJobs = @"Jobs";
static NSString * const kJSQDemoAvatarNameWoz = @"Steve Wozniak";


@implementation ChatRoomViewController

#pragma mark - Demo setup

- (void)setupTestModel
{
    /**
     *  Create avatar images once.
     *
     *  Be sure to create your avatars one time and reuse them for good performance.
     *
     *  If you are not using avatars, ignore this.
     */
    CGFloat outgoingDiameter = self.collectionView.collectionViewLayout.outgoingAvatarViewSize.width;

    CGFloat incomingDiameter = self.collectionView.collectionViewLayout.incomingAvatarViewSize.width;
    
    UIImage *jsqImage = [JSQMessagesAvatarFactory avatarWithImage:[UIImage imageNamed:@"icon_hana"]
                                                         diameter:outgoingDiameter];


    UIImage *cookImage = [JSQMessagesAvatarFactory avatarWithImage:[UIImage imageNamed:@"icon_hana"]
                                                          diameter:incomingDiameter];
    
    UIImage *jobsImage = [JSQMessagesAvatarFactory avatarWithImage:[UIImage imageNamed:@"icon_naru"]
                                                          diameter:incomingDiameter];
    
    UIImage *wozImage = [JSQMessagesAvatarFactory avatarWithImage:[UIImage imageNamed:@"icon_yaya"]
                                                         diameter:incomingDiameter];
    self.avatars = @{ self.sender : jsqImage,
                      kJSQDemoAvatarNameCook : cookImage,
                      kJSQDemoAvatarNameJobs : jobsImage,
                      kJSQDemoAvatarNameWoz : wozImage };
}



#pragma mark - View lifecycle

- (id)initWithGroupID:(int)groupID {
    if ([self init]) {
        _groupID = groupID;
        _memberIDs = [NSMutableArray array];
        _member = [NSMutableDictionary dictionary];
        _images = [NSMutableDictionary dictionary];
    }
    return self;
}
                   
/**
 *  Override point for customization.
 *
 *  Customize your view.
 *  Look at the properties on `JSQMessagesViewController` to see what is possible.
 *
 *  Customize your layout.
 *  Look at the properties on `JSQMessagesCollectionViewFlowLayout` to see what is possible.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //self.title = @"JSQMessages";
    NSDictionary* param = @{};
    NSString* api = [NSString stringWithFormat:@"groups/%d", _groupID];
    [ServerManager serverRequest:@"GET" api:api param:param completionHandler:^(NSURLResponse *response, NSDictionary *dict) {
        
        NSNumber* numStatus = dict[@"status"];
        int status = [numStatus intValue];
        if (status == 200) {
            NSDictionary* group = dict[@"group"];
            NSArray* users = group[@"users"];
            for (NSDictionary* user in users) {
                NSString* twitter_id = user[@"twitter_id"];
                [_memberIDs addObject:twitter_id];
            }
            _groupName = group[@"name"];
            [self setTitleByGroupName];
            [self fetchUserInfo];
        }
    }];
    
    NSUserDefaults* ud = [[NSUserDefaults alloc] init];
    self.sender = [ud stringForKey:@"twitter_id"];
    
    [self setupTestModel];
    [self fetchTalk];
    
    /**
     *  Remove camera button since media messages are not yet implemented
     *
     *   self.inputToolbar.contentView.leftBarButtonItem = nil;
     *
     *  Or, you can set a custom `leftBarButtonItem` and a custom `rightBarButtonItem`
     */
    
    /**
     *  Create bubble images.
     *
     *  Be sure to create your avatars one time and reuse them for good performance.
     *
     */
    self.outgoingBubbleImageView = [JSQMessagesBubbleImageFactory
                                    outgoingMessageBubbleImageViewWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    
    self.incomingBubbleImageView = [JSQMessagesBubbleImageFactory
                                    incomingMessageBubbleImageViewWithColor:[UIColor jsq_messageBubbleGreenColor]];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"typing"]
                                                                              style:UIBarButtonItemStyleBordered
                                                                             target:self
                                                                             action:@selector(receiveMessagePressed:)];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                                          target:self
                                                                                          action:@selector(closePressed:)];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    /**
     *  Enable/disable springy bubbles, default is NO.
     *  You must set this from `viewDidAppear:`
     *  Note: this feature is mostly stable, but still experimental
     */
    self.collectionView.collectionViewLayout.springinessEnabled = YES;
}



#pragma mark - Actions

- (void)receiveMessagePressed:(UIBarButtonItem *)sender
{
    
    [self fetchTalk];
    return;
    /**
     *  The following is simply to simulate received messages for the demo.
     *  Do not actually do this.
     */
    
    
    /**
     *  Set the typing indicator to be shown
     */
    self.showTypingIndicator = !self.showTypingIndicator;
    
    /**
     *  Scroll to actually view the indicator
     */
    [self scrollToBottomAnimated:YES];
    
    
    JSQMessage *copyMessage = [[self.messages lastObject] copy];
    
    if (!copyMessage) {
        copyMessage = [JSQMessage messageWithText:@"First received!" sender:kJSQDemoAvatarNameJobs];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        NSMutableArray *copyAvatars = [[self.avatars allKeys] mutableCopy];
        [copyAvatars removeObject:self.sender];
        copyMessage.sender = [copyAvatars objectAtIndex:arc4random_uniform((int)[copyAvatars count])];
        
        /**
         *  This you should do upon receiving a message:
         *
         *  1. Play sound (optional)
         *  2. Add new id<JSQMessageData> object to your data source
         *  3. Call `finishReceivingMessage`
         */
        [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
        [self.messages addObject:copyMessage];
        [self finishReceivingMessage];
    });
}

- (void)closePressed:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - JSQMessagesViewController method overrides

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                    sender:(NSString *)sender
                      date:(NSDate *)date
{
    /**
     *  Sending a message. Your implementation of this method should do *at least* the following:
     *
     *  1. Play sound (optional)
     *  2. Add new id<JSQMessageData> object to your data source
     *  3. Call `finishSendingMessage`
     */
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    JSQMessage *message = [[JSQMessage alloc] initWithText:text sender:sender date:date];
    [self.messages addObject:message];
     
    NSString* api = [NSString stringWithFormat:@"groups/%d/messages", _groupID];
    NSDictionary* param = @{@"content": message.text};
    NSLog(@"messege send : %@", message.text);
    [ServerManager serverRequest:@"POST" api:api param:param completionHandler:^(NSURLResponse *response, NSDictionary *dict) {
        NSLog(@"message sended : %@", message.text);
    }];
    
    
    [self finishSendingMessage];
}

- (void)didPressAccessoryButton:(UIButton *)sender
{
    NSLog(@"Camera pressed!");
    /**
     *  Accessory button has no default functionality, yet.
     */
}



#pragma mark - JSQMessages CollectionView DataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.messages objectAtIndex:indexPath.item];
}

- (UIImageView *)collectionView:(JSQMessagesCollectionView *)collectionView bubbleImageViewForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  You may return nil here if you do not want bubbles.
     *  In this case, you should set the background color of your collection view cell's textView.
     */
    
    /**
     *  Reuse created bubble images, but create new imageView to add to each cell
     *  Otherwise, each cell would be referencing the same imageView and bubbles would disappear from cells
     */
    
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    
    if ([message.sender isEqualToString:self.sender]) {
        return [[UIImageView alloc] initWithImage:self.outgoingBubbleImageView.image
                                 highlightedImage:self.outgoingBubbleImageView.highlightedImage];
    }
    
    return [[UIImageView alloc] initWithImage:self.incomingBubbleImageView.image
                             highlightedImage:self.incomingBubbleImageView.highlightedImage];
}

- (UIImageView *)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageViewForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Return `nil` here if you do not want avatars.
     *  If you do return `nil`, be sure to do the following in `viewDidLoad`:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
     *
     *  It is possible to have only outgoing avatars or only incoming avatars, too.
     */
    
    /**
     *  Reuse created avatar images, but create new imageView to add to each cell
     *  Otherwise, each cell would be referencing the same imageView and avatars would disappear from cells
     *
     *  Note: these images will be sized according to these values:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize
     *
     *  Override the defaults in `viewDidLoad`
     */
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    
    UIImage *avatarImage = [self.avatars objectForKey:message.sender];
    return [[UIImageView alloc] initWithImage:avatarImage];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
     *  The other label text delegate methods should follow a similar pattern.
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    
    /**
     *  iOS7-style sender name labels
     */
    if ([message.sender isEqualToString:self.sender]) {
        return nil;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage sender] isEqualToString:message.sender]) {
            return nil;
        }
    }
    
    /**
     *  Don't specify attributes to use the defaults.
     */
    return [[NSAttributedString alloc] initWithString:message.sender];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.messages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Override point for customizing cells
     */
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    /**
     *  Configure almost *anything* on the cell
     *
     *  Text colors, label text, label colors, etc.
     *
     *
     *  DO NOT set `cell.textView.font` !
     *  Instead, you need to set `self.collectionView.collectionViewLayout.messageBubbleFont` to the font you want in `viewDidLoad`
     *
     *
     *  DO NOT manipulate cell layout information!
     *  Instead, override the properties you want on `self.collectionView.collectionViewLayout` from `viewDidLoad`
     */
    
    JSQMessage *msg = [self.messages objectAtIndex:indexPath.item];
    
    if ([msg.sender isEqualToString:self.sender]) {
        cell.textView.textColor = [UIColor blackColor];
    }
    else {
        cell.textView.textColor = [UIColor whiteColor];
    }
    
    cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                          NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    
    return cell;
}



#pragma mark - JSQMessages collection view flow layout delegate

#pragma mark - Adjusting cell label heights

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
     */
    
    /**
     *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
     *  The other label height delegate methods should follow similarly
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  iOS7-style sender name labels
     */
    JSQMessage *currentMessage = [self.messages objectAtIndex:indexPath.item];
    if ([[currentMessage sender] isEqualToString:self.sender]) {
        return 0.0f;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage sender] isEqualToString:[currentMessage sender]]) {
            return 0.0f;
        }
    }
    
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
}

#pragma mark - Responding to collection view tap events

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
    NSLog(@"Load earlier messages!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped avatar!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped message bubble!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
{
    NSLog(@"Tapped cell at %@!", NSStringFromCGPoint(touchLocation));
}

#pragma mark - Mine

- (void) setTitleByGroupName
{
    if (![_groupName isEqualToString:@""]) {
        self.title = _groupName;
    } else {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        NSString* myID = [ud stringForKey:@"twitter_id"];
        
        NSMutableArray* userNames = [NSMutableArray array];
        for (NSString* userID in _memberIDs) {
            if ([userID isEqualToString:myID]) continue;
            NSDictionary* userInfo = _member[userID];
            NSString* userName;
            if (userInfo) {
                userName = userInfo[@"screen_name"];
            } else {
                userName = userID;
            }
            [userNames addObject:userName];
        }
        self.title = [userNames componentsJoinedByString:@","];
    }
    
}
- (void) fetchTalk
{
    NSLog(@"fetch talk");
    NSDictionary* param = @{};
    NSString* api = [NSString stringWithFormat:@"groups/%d/messages", _groupID];
    [ServerManager serverRequest:@"GET" api:api param:param completionHandler:^(NSURLResponse *response, NSDictionary *dict) {
        NSNumber* numStatus = dict[@"status"];
        int status = [numStatus intValue];
        if (status == 200) {
            NSLog(@"fetch talk finished");
            NSNumber* numCount = dict[@"count"];
            int count = [numCount intValue];
            self.messages = [[NSMutableArray alloc] init];

            if (count) {
                NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
                formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
                NSArray* messages = dict[@"messages"];
                for (NSDictionary* message in messages) {
                    NSLog(@"message : %@", message[@"content"]);
                    NSDate* date = [formatter dateFromString:message[@"created_at"]];
                    JSQMessage *msg = [[JSQMessage alloc] initWithText:message[@"content"] sender:message[@"user"][@"twitter_id"] date:date];
                    [self.messages addObject: msg];
                }

            }
            self.messages = [NSMutableArray arrayWithArray:[[self.messages reverseObjectEnumerator] allObjects]];
            [self performSelectorOnMainThread:@selector(finishReceivingMessage) withObject:nil waitUntilDone:NO];
            // [self.collectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        }
    }];
}

- (void)fetchUserInfo
{
    [AuthManager fetchUserInfo:_memberIDs withHandler:^(NSArray *userInfos) {
        NSLog(@"fetch user info finish");
        for (NSDictionary* userInfo in userInfos) {
            _member[userInfo[@"id"]] = userInfo;
            NSString* imageURL = userInfo[@"profile_image_url"];
            
            NSLog(@"%@", imageURL);
            
            UIImageView* tmpView = [[UIImageView alloc] init];
            
            [tmpView sd_setImageWithURL:[NSURL URLWithString:imageURL]
                              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                  NSString* twitter_id = userInfo[@"id"];
                                  CGFloat diameter;
                                  if (self.sender == twitter_id) {
                                      diameter = self.collectionView.collectionViewLayout.outgoingAvatarViewSize.width;
                                  } else {
                                      diameter = self.collectionView.collectionViewLayout.incomingAvatarViewSize.width;
                                  }
                                  UIImage* avator = [JSQMessagesAvatarFactory avatarWithImage:image
                                                                                     diameter:diameter];
                                  
                                  _images[twitter_id] = avator;
                                  
                                  self.avatars = [NSDictionary dictionaryWithDictionary:_images];
                                  [self.collectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];

                                  
            }];
            
            [self.view addSubview:tmpView];
        }
        [self setTitleByGroupName];
    }];
}

@end
