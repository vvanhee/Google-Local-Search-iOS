//
//  GoogleLocalConnection.h
//
//  Created by Victor C Van Hee on 1/24/11.
//  Copyright 2011 Victor C. Van Hee. All rights reserved.
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
#import "JSON.h"
#import "GoogleLocalObject.h"

@protocol GoogleLocalConnectionDelegate;

@interface GoogleLocalConnection : NSObject {
	id <GoogleLocalConnectionDelegate> delegate;
	NSMutableData *responseData;
	NSURLConnection *connection;
	BOOL connectionIsActive;
	int minAccuracyValue;
}

@property (nonatomic, assign) id <GoogleLocalConnectionDelegate> delegate;
@property (nonatomic, retain) NSMutableData *responseData;
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, assign) BOOL connectionIsActive;
@property (nonatomic, assign) int minAccuracyValue;

// useful functions
-(id)initWithDelegate:(id)del;
-(void)getGoogleObjectsWithQuery:(NSString *)query andMapRegion:(MKCoordinateRegion)region andNumberOfResults:(int)numResults addressesOnly:(BOOL)addressOnly andReferer:(NSString *)referer;
-(void)cancelGetGoogleObjects;

// local functions
-(MKCoordinateRegion)getViewPortForGoogleSearchResults:(NSMutableArray *)googleLocalObjectArray andGoogleViewport:(NSDictionary *)googleViewPort;
-(MKCoordinateRegion)makeRegionFromViewportCornersAndCenter:(CLLocationCoordinate2D)center NELat:(NSString *)NELat NELng:(NSString *)NELng SWLat:(NSString *)SWLat SWLng:(NSString *)SWLng;

@end

@protocol GoogleLocalConnectionDelegate

- (void) googleLocalConnection:(GoogleLocalConnection *)conn didFinishLoadingWithGoogleLocalObjects:(NSMutableArray *)objects andViewPort:(MKCoordinateRegion)region;
- (void) googleLocalConnection:(GoogleLocalConnection *)conn didFailWithError:(NSError *)error;


@end
