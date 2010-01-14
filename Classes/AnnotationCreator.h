//
//  AnnotationCreator.h
//  gMapsDataiPhone
//
//  Created by Michael Weisman on 01/08/09.
//  Copyright 2009 Michael Weisman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MKAnnotation.h>

@interface AnnotationCreator : NSObject <MKAnnotation> {
    CLLocationCoordinate2D coordinate;
    NSString *subtitle;
    NSString *title;
}
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, copy) NSString *title;
-(id)initWithCoordinate:(CLLocationCoordinate2D)annotationCoordinate Title:(NSString *)annotationTitle Subtitle:(NSString *)annotationSubtitle;
+(id)annotationWithCoordinate:(CLLocationCoordinate2D)annotationCoordinate Title:(NSString *)annotationTitle Subtitle:(NSString *)annotationSubtitle;
@end
