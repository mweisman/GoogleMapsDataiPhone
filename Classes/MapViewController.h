//
//  MapViewController.h
//  gMapsDataiPhone
//
//  Created by Michael Weisman on 27/07/09.
//  Copyright 2009 Michael Weisman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "CSMapRouteLayerView.h"


@interface MapViewController : UIViewController <MKMapViewDelegate> {
    //MKMapView *mapView;
    
    MKMapView *mapView;
    CSMapRouteLayerView *routeView;
    UIToolbar *mapTools;
    
    NSString *viewTitle;
    NSDictionary *itemInformation;
}

@property (nonatomic, retain) NSString *viewTitle;
@property (nonatomic, retain) NSDictionary *itemInformation;
@property (nonatomic, retain) MKMapView *mapView;
-(void)swapMapType;
@end
