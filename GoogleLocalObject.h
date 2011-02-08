//
//  GoogleLocalObject.h
//
//  Created by Victor C Van Hee on 10/13/10.
//  Copyright 2011 Victor C. Van Hee.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not
//  use this file except in compliance with the License.  You may obtain a copy
//  of the License at
// 
//  http://www.apache.org/licenses/LICENSE-2.0
// 
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
//  WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
//  License for the specific language governing permissions and limitations under
//  the License.
//
//  If you use this code, I ask that you attribute me (Victor C. Van Hee). 
//  Also, I'd appreciate it if you would provide a link / trackback to my 
//  blog post about this code (if you have a website or blog):
//  http://www.totagogo.com/2011/02/08/google-local-search-ios-code/

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
