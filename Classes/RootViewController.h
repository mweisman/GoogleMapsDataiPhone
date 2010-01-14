//
//  RootViewController.h
//  gMapsDataiPhone
//
//  Created by Michael Weisman on 09/07/09.
//  Copyright Michael Weisman 2009. All rights reserved.
//

@interface RootViewController : UITableViewController
    <UITableViewDelegate, UITableViewDataSource> {
		NSMutableArray	*appSections;
}

@property (nonatomic, retain) NSMutableArray *appSections;

@end
