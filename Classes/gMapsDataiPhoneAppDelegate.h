//
//  gMapsDataiPhoneAppDelegate.h
//  gMapsDataiPhone
//
//  Created by Michael Weisman on 09/07/09.
//  Copyright Michael Weisman 2009. All rights reserved.
//

@interface gMapsDataiPhoneAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end

