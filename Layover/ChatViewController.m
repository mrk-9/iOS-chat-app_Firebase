//
//  ChatViewController.m
//  Layovr
//
//  Created by Daniel Drescher on 08/06/16.
//  Copyright © 2016 griebel. All rights reserved.
//

#import "ChatViewController.h"
#import "AppDelegate.h"

@interface ChatViewController() < UIActionSheetDelegate >
{
    NSString *roomname;
//    Firebase *firebase;
    
    NSString *lastdate;
    NSString *messageType;
    NSDate *messageDate;
    NSString *messageStr;
    UIImage *messageImg;
    
    BOOL isLoading;
    
    NSMutableArray *users;
    NSMutableArray *messages;
    
    JSQMessagesBubbleImage *outgoingBubbleImageData;
    JSQMessagesBubbleImage *incomingBubbleImageData;
    
    JSQMessagesAvatarImage *avatar2ImageData;
    
    NSString *otherUID;// Other user uid
    NSMutableDictionary *otherInfo;// Other User Information
    UIImage *otherImage;// Other User Profile Image
    
    UIImageView *peerImageV;// Peer Avatar Image View
    FXBlurView *blurOverlayView;// For Peer Avatar Image View
    UILabel *peerLabel;
    
    NSInteger blurRadius;
    
    NSTimer *departTimer;// Monitoring the peer's depart time;(with me)
    BOOL isDeparted;
}

@end

@implementation ChatViewController

#pragma mark - Class methods
+ (UINib *)nib{
    return [UINib nibWithNibName:NSStringFromClass([JSQMessagesViewController class]) bundle:[NSBundle mainBundle]];
}
+ (instancetype)messagesViewController{
    return [[[self class] alloc] initWithNibName:NSStringFromClass([JSQMessagesViewController class]) bundle:[NSBundle mainBundle]];
}

//

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title =@"CHATS";
    
//    blurRadius = 20;
    
    // Set the background Image("app_bg.png") in Main View
//    [self setBackgroundImage];
    
    // Display the peer avatar image and other data in center-top of the View
//    [self displayPeerInfo];
//    isDeparted = NO;
    
    UIBarButtonItem *OKBarItem = [[UIBarButtonItem alloc] initWithTitle:@"Report" style:UIBarButtonItemStylePlain target:self action:@selector(clickReport)];
    self.navigationItem.rightBarButtonItem = OKBarItem;
    
    UILabel* label=[[UILabel alloc] initWithFrame:CGRectMake(0,0, self.navigationItem.titleView.frame.size.width, 40)];
    label.text=self.navigationItem.title;
    label.textColor=[UIColor whiteColor];
    label.backgroundColor =[UIColor clearColor];
    label.adjustsFontSizeToFitWidth=YES;
    label.font = [UIFont systemFontOfSize:15.f];
    label.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView=label;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navBackIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(BackPressed)];
    
    //----
    self.senderId = [FIRAuth auth].currentUser.uid;//[PFUser currentUser].objectId;
    self.senderDisplayName = [FIRAuth auth].currentUser.displayName;//[PFUser currentUser][@"name"];
    
    roomname = [Utils generateChatRoom:[FIRAuth auth].currentUser.uid second:otherUID];
    
    messages = [[NSMutableArray alloc] init];
    
    [[[[[FIRDatabase database] reference] child:MESSAGES_REF] child:roomname] observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        JSQMessage *msg = [[JSQMessage alloc] initWithSenderId:snapshot.value[@"user1"]
                                             senderDisplayName:snapshot.value[@"user2"]
                                                          date:[Utils dateFromString:snapshot.value[@"date"] format:@"yyyy-MM-dd HH:mm:ss" timezone:@"UTC"]
                                                          text:snapshot.value[@"message"]];
        [messages addObject:msg];
        [self finishSendingMessageAnimated:YES];
        
        [[[[[[[FIRDatabase database] reference] child:CONTACTS_REF] child:[FIRAuth auth].currentUser.uid] child:[self getPeerKeyInContactList]] child:LAST_MESSAGE] setValue:msg.text];
//        if (![self.senderId isEqualToString:msg.senderId] ) {
//            blurRadius -= 5;
//            if (blurRadius < 0) {
//                blurRadius = 0;
//            }
//            
//            [self setBlurTagWithIndex:(blurRadius / 5)];// Set Blur Level
//            
//            if (blurOverlayView) {
//                [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//                   [blurOverlayView setBlurRadius:blurRadius]; 
//                } completion:^(BOOL finished) {
//                    if (blurRadius == 0) {
//                        [blurOverlayView removeFromSuperview];
//                    }
//                }];
//            }
//        }
    }];
    
//    firebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/%@", FIREBASE_MESSAGE_URL, roomname]];
//    [firebase observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
//        JSQMessage *msg = [[JSQMessage alloc] initWithSenderId:snapshot.value[@"user1"]
//                                             senderDisplayName:@"user2"
//                                                          date:[Utils dateFromString:snapshot.value[@"date"] format:@"yyyy-MM-dd HH:mm:ss" timezone:@"UTC"]
//                                                          text:snapshot.value[@"message"]];
//        [messages addObject:msg];
//        [self finishSendingMessageAnimated:YES];
//    }];
    
    self.inputToolbar.contentView.leftBarButtonItem = nil;
    //    /**
    //     *  You can set custom avatar sizes
    //     */
    //    if (![NSUserDefaults incomingAvatarSetting]) {
    //        self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    //    }
    //
    //    if (![NSUserDefaults outgoingAvatarSetting]) {
    //        self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    //    }
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleBlueColor]];
    incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    
    avatar2ImageData = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:@"dollar"]
                                                                  diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.collectionView.collectionViewLayout.springinessEnabled = NO;
    
//    departTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(checkDepartTime) userInfo:nil repeats:YES];
}

-(void)viewDidDisappear:(BOOL)animated
{

}
-(void)viewWillDisappear:(BOOL)animated
{
    if ([departTimer isValid]) {
        [departTimer invalidate];
    }
    departTimer = nil;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

-(void)clickReport{
    NSString * manStr = [NSString stringWithFormat:@"Report %@", @"Second User"];//self.secondUser[@"name"]
    
    UIActionSheet *modeMenu = [[UIActionSheet alloc]
                               initWithTitle: nil
                               delegate:self
                               cancelButtonTitle:@"Cancel"
                               destructiveButtonTitle:nil
                               otherButtonTitles:manStr,
                               nil];
    [modeMenu showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        // Report man
        
    }else{
        //
    }
    [ProgressHUD showSuccess:@"Report sent!" Interaction:NO];
    [actionSheet isHidden];
}

- (void)BackPressed{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Custom Method

- (void)setBlurTagWithIndex: (NSInteger)ind {
    BlurTag blurTag;
    
    switch (ind) {
        case 0:
            blurTag = BlurLevel1;
            break;
        case 1:
            blurTag = BlurLevel2;
            break;
        case 2:
            blurTag = BlurLevel3;
            break;
        case 3:
            blurTag = BlurLevel4;
            break;
        case 4:
            blurTag = BlurLevel5;
            break;
            
        default:
            blurTag = BlurLevel5;
            break;
    }
    
    if ([self getPeerKeyInContactList]) {
        [[[[[[[FIRDatabase database] reference] child:CONTACTS_REF] child:[FIRAuth auth].currentUser.uid] child:[self getPeerKeyInContactList]] child:STATUS] setValue:[NSNumber numberWithInteger:blurTag]];
    }
}

- (NSString *)getPeerKeyInContactList {
    NSString *peerKey;
    for (id key in [[UserInfo sharedInstance] userContactList]) {
        NSMutableDictionary *itemDic = [[[UserInfo sharedInstance] userContactList] objectForKey:key];
        if ([[itemDic objectForKey:USERID] isEqualToString:otherUID]) {
            peerKey = key;
            break;
        }
    }
    
    return peerKey;
}

- (void)checkDepartTime {
    [peerLabel setAttributedText:[self departureTimeForPeerWith:otherInfo[DEPART_TIME]]];
    
    if (isDeparted) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)setOtherInfoWithUID: (NSString *)uid andDictionary: (NSDictionary *)otherDic andImage: (UIImage *)image {
    otherUID = uid;
    otherInfo = [otherDic mutableCopy];
    otherImage = image;
}

// Display the peer avatar image in center-top of the view
- (void)displayPeerInfo {
    CGFloat w = [[UIScreen mainScreen] bounds].size.width;
    CGFloat h = [[UIScreen mainScreen] bounds].size.height;
    
    // Avatar Image View
    peerImageV = [[UIImageView alloc] initWithFrame:CGRectMake(w * 3 / 8, 20, w / 4, w / 4)];
    [peerImageV.layer setBorderColor:[UIColor whiteColor].CGColor];
    [peerImageV.layer setBorderWidth:2];
    [peerImageV.layer setCornerRadius:10];
    [peerImageV setClipsToBounds:YES];
    [peerImageV setImage:otherImage];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAvatarImage:)];
    [peerImageV addGestureRecognizer:tapGesture];
    [peerImageV setUserInteractionEnabled:YES];
    
    // Set Blur Overlay View
    blurOverlayView = [[FXBlurView alloc] initWithFrame:CGRectMake(0, 0, w, w)];
    [blurOverlayView setBackgroundColor:[UIColor whiteColor]];
    [blurOverlayView setBlurRadius:blurRadius];
    
    [peerImageV addSubview:blurOverlayView];
    
    // Username and Departing Time
    peerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20 + w / 4, w, w / 6)];
    [peerLabel setTextAlignment:NSTextAlignmentCenter];
    [peerLabel setFont:[UIFont systemFontOfSize:w / 20]];
    [peerLabel setNumberOfLines:2];
    
    [peerLabel setAttributedText:[self departureTimeForPeerWith:otherInfo[DEPART_TIME]]];
    
    [self.view addSubview:peerImageV];
    [self.view addSubview:peerLabel];
    
    
//    [self.collectionView setFrame:CGRectMake(0, peerLabel.frame.origin.y + peerLabel.frame.size.height, w, h - (peerLabel.frame.origin.y + peerLabel.frame.size.height))];
    
    NSLog(@"%f, %f", h, self.collectionView.frame.size.height);
}

- (NSMutableAttributedString *)departureTimeForPeerWith: (NSString *)intervalTime {
    // Get Time interval since 1970
    NSTimeInterval peerTime;
    if (intervalTime == nil || [intervalTime isEqualToString:EMPTY_STRING]) {
        peerTime = 0;
    }else{
        peerTime = [intervalTime doubleValue];
    }
    
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    
    NSInteger interval = (NSInteger)peerTime - (NSInteger)now;
    
    NSString *departText;
    NSString *timeText;
    
    //--
    departText = [NSString stringWithFormat:@"%@\n", otherInfo[USERNAME]];
    
    UIColor *departColor;
    UIColor *timeColor;
    if (interval <= 0) {
        departColor = [UIColor redColor];
        departText = [NSString stringWithFormat:@"%@Departed", departText];
        timeColor = [UIColor clearColor];
        timeText = @"";
        isDeparted = YES;
    }else{
        departColor = [UIColor whiteColor];
        departText = [NSString stringWithFormat:@"%@Departing in ", departText];
        
        interval = interval / 60; // Get the time with Miniute
        if (interval < 15) { // less than 15 mins
            
            timeColor = [UIColor redColor];
            timeText = [NSString stringWithFormat:@"%ld miuntes", (long)interval];
        }else if (interval <= 60) {// less than 1 hr
            
            timeColor = [UIColor yellowColor];
            if (interval == 60) {
                timeText = [NSString stringWithFormat:@"1 hour"];
            }else {
                if (interval == 1) {
                    timeText = [NSString stringWithFormat:@"%ld miunte", (long)interval];
                }else {
                    timeText = [NSString stringWithFormat:@"%ld miuntes", (long)interval];
                }
            }
        }else {// Greater than 1 hr
            
            timeColor = [UIColor greenColor];
            NSInteger m = interval % 60;
            NSInteger h = interval / 60;
            if (h == 1) {
                timeText = [NSString stringWithFormat:@"%ld hour", (long)h];
            }else {
                timeText = [NSString stringWithFormat:@"%ld hours", (long)h];
            }
            if (m == 1) {
                timeText = [NSString stringWithFormat:@"%@ %ld minute", timeText, (long)m];
            }else if (m != 0) {
                timeText = [NSString stringWithFormat:@"%@ %ld minutes", timeText, (long)m];
            }
        }
        
    }
    
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] init];
    NSDictionary *attDepart = @{NSForegroundColorAttributeName : departColor};
    NSDictionary *attTime = @{NSForegroundColorAttributeName : timeColor};
    NSAttributedString *departStr = [[NSAttributedString alloc] initWithString:departText attributes:attDepart];
    NSAttributedString *timeStr = [[NSAttributedString alloc] initWithString:timeText attributes:attTime];
    [attStr appendAttributedString:departStr];
    [attStr appendAttributedString:timeStr];
    
    return attStr;
}

// Tap the avatar Image

- (void)tapAvatarImage: (UITapGestureRecognizer *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

// Set the background Image in Main View
- (void)setBackgroundImage {
    UIImageView *bgImageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
    [bgImageV setImage:[UIImage imageNamed:@"app_bg.png"]];
    [self.view insertSubview:bgImageV atIndex:0];
}

#pragma mark - UINavigationController Delegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

#pragma mark - UIImagePicker
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:@"public.image"]){
        UIImage *img = [info objectForKey:UIImagePickerControllerEditedImage];
        if (img == nil) {
            img = [info objectForKey:UIImagePickerControllerOriginalImage];
        }
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - JSQMessagesViewController method overrides
- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date
{
    /**
     *  Sending a message. Your implementation of this method should do *at least* the following:
     *
     *  1. Play sound (optional)
     *  2. Add new id<JSQMessageData> object to your data source
     *  3. Call `finishSendingMessage`
     */
    
    NSDictionary *dict = @{@"user1" : [FIRAuth auth].currentUser.uid,//[PFUser currentUser].objectId,
                           @"user2" : otherUID,//self.secondUser.objectId,
                           @"message" : text,
                           @"date" : [Utils dateToString:[NSDate date] format:@"yyyy-MM-dd HH:mm:ss" timezone:@"UTC"]};
//    [[firebase childByAutoId] setValue:dict];
//    [[[[[[FIRDatabase database] reference] child:MESSAGES_REF] child:roomname] childByAutoId] setValue:dict];
    
    [[[[[[FIRDatabase database] reference] child:MESSAGES_REF] child:roomname] childByAutoId] setValue:dict withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {

        if (error == nil) {// Sending message completely
            if ([otherInfo objectForKey:ONESIGNAL_USERID]) {
                AppDelegate *myDel = [UIApplication sharedApplication].delegate;
                [myDel.oneSignal postNotification:@{
                                                    @"contents" : @{@"en": text},//, @"SenderUID":[FIRAuth auth].currentUser.uid
                                                    @"data" : @{@"sender": [FIRAuth auth].currentUser.displayName, @"senderID": [FIRAuth auth].currentUser.uid},
                                                    @"include_player_ids": @[[otherInfo objectForKey:ONESIGNAL_USERID]],
                                                    @"ios_badgeType" : @"Increase",
                                                    @"ios_badgeCount" : [NSNumber numberWithInteger:1]
                                                    }];
            }
            
            [[[[[[FIRDatabase database] reference] child:NOTIFICATIONS_REF] child:otherUID] child:[FIRAuth auth].currentUser.uid] setValue:@{BADGENUMBER: @"1"}];
        }
    }];
}

- (void)didPressAccessoryButton:(UIButton *)sender{
//        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Photo"
//                                                           delegate:self
//                                                  cancelButtonTitle:@"Cancel"
//                                             destructiveButtonTitle:nil
//                                                  otherButtonTitles:@"Take Photo", @"Camera Roll", nil];
//        [sheet showFromToolbar:self.inputToolbar];
//        imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
//        NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil];
//        imagePicker.navigationBar.titleTextAttributes = textAttributes;
//    
//        [self presentViewController:imagePicker animated:YES completion:NULL];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    
}

#pragma mark - JSQMessages CollectionView DataSource
- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath{
    return [messages objectAtIndex:indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath{
    /**
     *  You may return nil here if you do not want bubbles.
     *  In this case, you should set the background color of your collection view cell's textView.
     *
     *  Otherwise, return your previously created bubble image data objects.
     */
    
    JSQMessage *message = [messages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return outgoingBubbleImageData;
    }
    
    return incomingBubbleImageData;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
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
     *  Return your previously created avatar image data objects.
     *
     *  Note: these the avatars will be sized according to these values:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize
     *
     *  Override the defaults in `viewDidLoad`
     */
    JSQMessage *message = [messages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }
    else {
        return avatar2ImageData;
    }
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
        JSQMessage *message = [messages objectAtIndex:indexPath.item];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    
    //    JSQMessage *currentmsg = [messages objectAtIndex:indexPath.item];
    //    if (indexPath.item > 0) {
    //        JSQMessage *prevmsg = [messages objectAtIndex:indexPath.item - 1];
    //        if (![currentmsg.senderId isEqualToString:prevmsg.senderId]) {
    //            return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:currentmsg.date];
    //        } else{
    //            NSTimeInterval secs = [currentmsg.date timeIntervalSinceDate:prevmsg.date];
    //            if (secs > 60) {
    //                return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:currentmsg.date];
    //            }
    //        }
    //    } else{
    //        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:currentmsg.date];
    //    }
    
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [messages objectAtIndex:indexPath.item];
    
    /**
     *  iOS7-style sender name labels
     */
    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:message.senderId]) {
            return nil;
        }
    }
    
    /**
     *  Don't specify attributes to use the defaults.
     */
    return nil;//[[NSAttributedString alloc] initWithString:message.senderDisplayName];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [messages count];
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
    
    JSQMessage *msg = [messages objectAtIndex:indexPath.item];
    
    if (!msg.isMediaMessage) {
        
        if ([msg.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor = [UIColor whiteColor];
        }
        else {
            cell.textView.textColor = [UIColor blackColor];
        }
        
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }
    
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
    JSQMessage *currentMessage = [messages objectAtIndex:indexPath.item];
    if ([[currentMessage senderId] isEqualToString:self.senderId]) {
        return 0.0f;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:[currentMessage senderId]]) {
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


@end
