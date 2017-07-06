//
//  AppDelegate.m
//  Layover
//
//  Created by Daniel Drescher on 31/05/16.
//  Copyright © 2016 griebel. All rights reserved.
//

#import "AppDelegate.h"
#import "RootViewController.h"
#import "ViewController.h"
#import "MessageViewController.h"

@interface AppDelegate () {
    BOOL isLoadedUserData;
    BOOL isLoadedUserBlockList;
    BOOL isLoadedUserContactList;
    BOOL isLoadedUserNotifications;
//    BOOL isLoadedUserContactList;
    
    NSTimer *waitTimer; // keep the splash screen for about 3 seconds
    
    id messageViewController;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Override point for customization after application launch.
    [[UITextField appearance] setTintColor:[UIColor whiteColor]];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:ISDOWNLOADED_USERDATA];
    
    [[UserInfo sharedInstance] initUserInfo];
    [FIRApp configure];
    
//    BOOL status = [[FIRAuth auth] signOut:nil];
//    [self setRootViewController];
    
    UIUserNotificationType allNotificationTypes =
    (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
    UIUserNotificationSettings *settings =
    [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    // Add observer for InstanceID token refresh callback.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tokenRefreshNotification:)
                                                 name:kFIRInstanceIDTokenRefreshNotification object:nil];
    
    self.oneSignal = [[OneSignal alloc]
                      initWithLaunchOptions:launchOptions
                      appId:ONESIGNAL_APPID
                      handleNotification:^(NSString* message, NSDictionary* additionalData, BOOL isActive) {
                          NSLog(@"OneSignal Notification opened:\nMessage: %@", message);
                          
                          if (additionalData) {
                              NSLog(@"additionalData: %@", additionalData);
                              
                              // Check for and read any custom values you added to the notification
                              // This done with the "Additonal Data" section the dashbaord.
                              // OR setting the 'data' field on our REST API.
                              NSString* customKey = additionalData[@"customKey"];
                              if (customKey)
                                  NSLog(@"customKey: %@", customKey);
                          }
                      }];
    
//    self.oneSignal = [[OneSignal alloc] initWithLaunchOptions:launchOptions handleNotification:^(NSString *message, NSDictionary *additionalData, BOOL isActive) {
//        NSLog(@"OneSignal Notification opened:\nMessage: %@", message);
//        
//        if (additionalData) {
//            NSLog(@"additionalData: %@", additionalData);
//            
//            // Check for and read any custom values you added to the notification
//            // This done with the "Additonal Data" section the dashbaord.
//            // OR setting the 'data' field on our REST API.
//            NSString* customKey = additionalData[@"customKey"];
//            if (customKey)
//                NSLog(@"customKey: %@", customKey);
//        }
//    } autoRegister:false];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCurrentViewController:) name:@"CurrentViewController" object:nil];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[FIRMessaging messaging] disconnect];
    NSLog(@"Disconnected from FCM");
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [self connectToFcm];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[FIRInstanceID instanceID] setAPNSToken:deviceToken type:FIRInstanceIDAPNSTokenTypeSandbox];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    if(application.applicationState == UIApplicationStateInactive) {
        
        NSLog(@"Inactive");
        
        //Show the view with the content of the push
        
        completionHandler(UIBackgroundFetchResultNewData);
        
    } else if (application.applicationState == UIApplicationStateBackground) {
        
        NSLog(@"Background");
        
        //Refresh the local model
        
        completionHandler(UIBackgroundFetchResultNewData);
        
    } else {
        
        NSLog(@"Active");
        
        //Show an in-app banner
        
        completionHandler(UIBackgroundFetchResultNewData);
        
    }
    
    if ([userInfo objectForKey:@"aps"]) {
        NSDictionary *notificationDic = [userInfo objectForKey:@"aps"];
        if ([notificationDic objectForKey:@"badge"]) {
            NSInteger badgeNumber = [[notificationDic objectForKey:@"badge"] integerValue];
            [UIApplication sharedApplication].applicationIconBadgeNumber = badgeNumber;
        }
    }
    
    // Message ID
    NSLog(@"Message ID: %@", userInfo[@"gcm.message_id"]);
    
    // Print full userinfo
    NSLog(@"UserInfo: %@", userInfo);
    
    // let FCM know about the message for analytics etc
    [[FIRMessaging messaging] appDidReceiveMessage:userInfo];
    // Handle your message
}

#pragma mark - Custom Method

// [START refresh_token]
- (void)tokenRefreshNotification:(NSNotification *)notification {
    // Note that this callback will be fired everytime a new token is generated, including the first
    // time. So if you need to retrieve the token as soon as it is available this is where that
    // should be done.
    NSString *refreshedToken = [[FIRInstanceID instanceID] token];
    NSLog(@"InstanceID token: %@", refreshedToken);
    
    // Connect to FCM since connection may have failed when attempted before having a token.
    [self connectToFcm];
    
    // TODO: If necessary send token to appliation server.
}

// [START connect_to_fcm]
- (void)connectToFcm {
    [[FIRMessaging messaging] connectWithCompletion:^(NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Unable to connect to FCM. %@", error);
        } else {
            NSLog(@"Connected to FCM.");
        }
    }];
}
// [END connect_to_fcm]

- (void)handleCurrentViewController:(NSNotification *)notification {
    if([[notification userInfo] objectForKey:@"lastViewController"]) {
        messageViewController = [[notification userInfo] objectForKey:@"lastViewController"];
    }
}

- (void)getCurrentUserData {
    
    // Get the current user avatar image from Firebase
    if ([FIRAuth auth].currentUser.photoURL != nil) {// PhotoURL is generated
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:AVATAR_ISEXISTED];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:AVATAR_ISDOWNLOADED];
        
        FIRStorageReference *httpRef = [[FIRStorage storage] referenceForURL:[FIRAuth auth].currentUser.photoURL.absoluteString];
        [httpRef dataWithMaxSize:1 * 1024 * 1024 completion:^(NSData * _Nullable data, NSError * _Nullable error) {
            
            if (error) {
                
            }else {
                [[NSUserDefaults standardUserDefaults] setObject:data forKey:AVATARIMAGE];
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:AVATAR_ISDOWNLOADED];
            }
        }];
        
    }else {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:AVATAR_ISEXISTED];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:AVATAR_ISDOWNLOADED];
    }
    
    isLoadedUserData = NO;
    isLoadedUserBlockList = NO;
    isLoadedUserContactList = NO;
    
    // Get user Data
    [[[[[FIRDatabase database] reference] child:USERS_REF] child:[FIRAuth auth].currentUser.uid] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        NSDictionary *myDic = snapshot.value;
        if (![myDic isEqual:[NSNull null]]) {
            
            [[UserInfo sharedInstance] setUserInfo:myDic];
            
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:ISDOWNLOADED_USERDATA];
        }
        isLoadedUserData = YES;
        if (isLoadedUserBlockList && isLoadedUserContactList && isLoadedUserNotifications) {
            [ProgressHUD dismiss];
        }
    }];
    
    //Get block list of the current user
    [[[[[FIRDatabase database] reference] child:BLOCKLIST_REF] child:[FIRAuth auth].currentUser.uid] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        NSMutableDictionary *results = snapshot.value;
        [[[UserInfo sharedInstance] userBlockList] removeAllObjects];
        
        if (![results isEqual:[NSNull null]]) {
            [[[UserInfo sharedInstance] userBlockList] addEntriesFromDictionary:results];
//            [[[UserInfo sharedInstance] userBlockList] removeObjectForKey:[FIRAuth auth].currentUser.uid];
        }
        isLoadedUserBlockList = YES;
        if (isLoadedUserData && isLoadedUserData && isLoadedUserNotifications) {
            [ProgressHUD dismiss];
        }
        
        [self updateContactListWithNotifications];
    }];
    
    //Get contact list of the current Uesr
    [[[[[FIRDatabase database] reference] child:CONTACTS_REF] child:[FIRAuth auth].currentUser.uid] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        [[[UserInfo sharedInstance] userContactList] removeAllObjects];
        
        NSMutableDictionary *results = snapshot.value;
        if (![results isEqual:[NSNull null]]) {
//            NSMutableDictionary *contactsList = [NSMutableDictionary new];
//            [contactsList addEntriesFromDictionary:results];
            [[[UserInfo sharedInstance] userContactList] addEntriesFromDictionary:results];
        }
        
        isLoadedUserContactList = YES;
        if (isLoadedUserData && isLoadedUserBlockList && isLoadedUserNotifications) {
            [ProgressHUD dismiss];
        }
        
//        [[NSNotificationCenter defaultCenter] postNotificationName:UPDATEDCONTACTLIST_NOTIFICATION object:nil];
        
//        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//        MessageViewController *messageVC = [storyboard instantiateViewControllerWithIdentifier:@"MessageViewController"];
        
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:ISSHOWED_MESSAGEVIEWCONTROLLER] boolValue] == YES) {
            MessageViewController *messageVC = (MessageViewController *)messageViewController;
            [messageVC refreshTableView];
        }
        
        [self updateContactListWithNotifications];
    }];
    
    //Get notifications of the current Uesr
    [[[[[FIRDatabase database] reference] child:NOTIFICATIONS_REF] child:[FIRAuth auth].currentUser.uid] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        BOOL isChatting = NO;
        NSInteger badgeNumber = 0;
        [[[UserInfo sharedInstance] userNotifications] removeAllObjects];
        
        NSMutableDictionary *results = snapshot.value;
        if (![results isEqual:[NSNull null]]) {
            //            NSMutableDictionary *contactsList = [NSMutableDictionary new];
            //            [contactsList addEntriesFromDictionary:results];
            [[[UserInfo sharedInstance] userNotifications] addEntriesFromDictionary:results];
            
            badgeNumber = [results.allKeys count];
            
            //-- Add the peer related to notification in Contact List
            if ([[[NSUserDefaults standardUserDefaults] objectForKey:ISSHOWED_CHATVIEWCONTROLLER] boolValue] == YES &&
                [[NSUserDefaults standardUserDefaults] objectForKey:CHAT_PEERUID] &&
                ![[[NSUserDefaults standardUserDefaults] objectForKey:CHAT_PEERUID] isEqualToString:EMPTY_STRING]) {
                for (id key in results.allKeys) {
                    if ([key isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:CHAT_PEERUID]]) {
                        isChatting = YES;
                        [[[[[[FIRDatabase database] reference] child:NOTIFICATIONS_REF] child:[FIRAuth auth].currentUser.uid] child:key] removeValue];
                        return;
                    }
                }
            }
        }
        
        isLoadedUserNotifications = YES;
        if (isLoadedUserData && isLoadedUserBlockList && isLoadedUserContactList) {
            [ProgressHUD dismiss];
        }
        
        [UIApplication sharedApplication].applicationIconBadgeNumber = badgeNumber;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            RootViewController *rootVC = [storyboard instantiateViewControllerWithIdentifier:@"RootViewController"];
            
            if ([rootVC.restorationIdentifier isEqualToString:self.window.rootViewController.restorationIdentifier]) {
                RootViewController *currentVC = (RootViewController *)self.window.rootViewController;
                [currentVC setBadgeNumberInMessage: badgeNumber];
            }
        });
        
//        [[NSNotificationCenter defaultCenter] postNotificationName:UPDATEDNOTIFICATIONS_NOTIFICATION object:nil];
        
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:ISSHOWED_MESSAGEVIEWCONTROLLER] boolValue] == YES) {
//            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            MessageViewController *messageVC = (MessageViewController *)messageViewController;
            [messageVC reloadTableView];
        }
        
        [self updateContactListWithNotifications];
    }];
}

- (void)updateContactListWithNotifications {
    
    BOOL isExitedInContactList = NO;
    
    NSMutableDictionary *notifications = [[UserInfo sharedInstance] userNotifications];
    
    if (![notifications isEqual:[NSNull null]]) {
        
        for (id notiKey in notifications) {
            NSMutableDictionary *blockList = [[UserInfo sharedInstance] userBlockList];
            if (![blockList isEqual:[NSNull null]]) {
                for (id blockKey in blockList) {
                    NSMutableDictionary *itemDic = [blockList objectForKey:blockKey];
                    if ([[itemDic objectForKey:USERID] isEqualToString:notiKey]) {
                        [[[[[[FIRDatabase database] reference] child:NOTIFICATIONS_REF] child:[FIRAuth auth].currentUser.uid] child:notiKey] removeValue];
                    }
                }
            }
            NSMutableDictionary *contactList = [[UserInfo sharedInstance] userContactList];
            if (![contactList isEqual:[NSNull null]]) {
                for (id contactKey in contactList) {
                    NSMutableDictionary *itemDic = [contactList objectForKey:contactKey];
                    if ([[itemDic objectForKey:USERID] isEqualToString:notiKey]) {
                        isExitedInContactList = YES;
                    }
                }
            }
            if (isExitedInContactList == NO) {
                // Add to contact list
                NSDictionary *dict = @{USERID : notiKey//[PFUser currentUser].objectId,
                                       };
                [[[[[[FIRDatabase database] reference] child:CONTACTS_REF] child:[FIRAuth auth].currentUser.uid] childByAutoId] setValue:dict];
            }else{
                isExitedInContactList = NO;
            }
        }
    }
}

- (void)setRootViewController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    NSLog(@"%@", [FIRAuth auth].currentUser.uid);
    if ([FIRAuth auth].currentUser) {
        
        [self.oneSignal IdsAvailable:^(NSString *userId, NSString *pushToken) {
            NSLog(@"User ID: %@", userId);
            NSLog(@"Push Token: %@", pushToken);
            
            if (userId != nil) {
                [[NSUserDefaults standardUserDefaults] setObject:userId forKey:ONESIGNAL_USERID];
                
                [[[UserInfo sharedInstance] userData] setObject:userId forKey:ONESIGNAL_USERID];
                
                [[[[[[FIRDatabase database] reference] child:USERS_REF] child:[FIRAuth auth].currentUser.uid] child:ONESIGNAL_USERID] setValue:userId];
            }
        }];
        
        [self getCurrentUserData];
        
        //        UINavigationController *naviRootC = [[UINavigationController alloc] init];
        
        RootViewController *rootVC = [storyboard instantiateViewControllerWithIdentifier:@"RootViewController"];
        [rootVC setIsFromCameraView:NO];
        
        self.window.rootViewController = rootVC;
        
    }else{
        ViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"naviViewController"];
        self.window.rootViewController = vc;
    }
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.griebel.chat.Layover" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Layover" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Layover.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
