//
//  MapInfoController.h
//  gMapsDataiPhone
//
//  Created by Michael Weisman on 26/07/09.
//  Copyright 2009 Michael Weisman. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MapInfoController : UITableViewController {
    NSDictionary *mapInformation;
    NSString *published;
    NSString *modifed;
    NSString *author;
    NSString *title;
}

@property (nonatomic, retain) NSDictionary *mapInformation;

-(NSString *)formatDateFromString:(NSString *)dateAsString;


@end
