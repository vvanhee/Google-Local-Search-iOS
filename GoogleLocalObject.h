//
//  GoogleLocalObject.h
//  BabyMap
//
//  Created by Victor C Van Hee on 10/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface GoogleLocalObject : NSObject <MKAnnotation> {
	NSString *title;
	NSString *subtitle;
	CLLocationCoordinate2D coordinate;
	NSString *streetAddress;
	NSString *city;
	NSString *region;
	NSString *phoneNumber;
	NSString *country;
	NSString *searchTerms;
	NSArray *fullAddressArray;
	NSString *fullAddressString;
}

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *subtitle;
@property (nonatomic, retain) NSString *streetAddress;
@property (nonatomic, retain) NSArray *fullAddressArray;
@property (nonatomic, retain) NSString *fullAddressString;
@property (nonatomic, retain) NSString *city;
@property (nonatomic, retain) NSString *region;
@property (nonatomic, retain) NSString *phoneNumber;
@property (nonatomic, retain) NSString *country;
@property (nonatomic, retain) NSString *searchTerms;

- (id)initWithJsonResultDict:(NSDictionary *)jsonResultDict;

- (id)initWithTitle:(NSString *)tit subtitle:(NSString *)sub latitude:(double)lat longitude:(double)lng streetAddress:(NSString *)strAdd city:(NSString *)cit region:(NSString *)reg phoneNumber:(NSString *)phone country:(NSString *)coun searchTerms:(NSString *)terms fullAddress:(NSArray *)fullAddrss;

- (id)initWithTitle:(NSString *)tit latitude:(double)lat longitude:(double)lng streetAddress:(NSString *)strAdd city:(NSString *)cit region:(NSString *)reg phoneNumber:(NSString *)phone country:(NSString *)coun searchTerms:(NSString *)terms fullAddress:(NSArray *)fullAddrss;

- (id)initWithJsonResultDict:(NSDictionary *)jsonResultDict searchTerms:(NSString *)terms;

@end
