//
//  MapItemsController.h
//  gMapsDataiPhone
//
//  Created by Michael Weisman on 27/07/09.
//  Copyright 2009 Michael Weisman. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MapItemsController : UITableViewController {
    NSURL *mapIDURL;
    NSString *title;
    NSMutableArray *mapItems;
    //NSDictionary *currentElementAttributeDict;
    NSMutableDictionary *currentItem;
    NSMutableString *itemName;
    NSMutableArray *itemCoordinates;
    NSString *currentElement;
    
    NSOperationQueue *operationQueue;
    
    UIActivityIndicatorView *spinner;
    UILabel *loadingLabel;
}

@property (nonatomic, retain) NSURL *mapIDURL;

@end
