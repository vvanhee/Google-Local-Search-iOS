//
//  GoogleLocalConnection.m
//
//  Created by Victor C Van Hee on 1/24/11.
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

// define some LLVM3 macros if the code is compiled with a different compiler (ie LLVMGCC42)
#ifndef __has_feature
#define __has_feature(x) 0
#endif
#ifndef __has_extension
#define __has_extension __has_feature // Compatibility with pre-3.0 compilers.
#endif

#if __has_feature(objc_arc) && __clang_major__ >= 3
#define ARC_ENABLED 1
#endif // __has_feature(objc_arc)

#import "GoogleLocalConnection.h"
#import "GTMNSString+URLArguments.h"

@implementation GoogleLocalConnection

@synthesize delegate = _delegate;
@synthesize responseData = _responseData;
@synthesize connection = _connection;
@synthesize connectionIsActive = _connectionIsActive;
@synthesize minAccuracyValue = _minAccuracyValue;

- (id)initWithDelegate:(id <GoogleLocalConnectionDelegate>)del
{
	self = [super init];
	
	if (!self)
		return nil;
	[self setDelegate:del];	
	return self;
}

- (id) init
{
	NSLog(@"need a delegate!! use initWithDelegate!");
	return nil;
}


-(void)getGoogleObjectsWithQuery:(NSString *)query andMapRegion:(MKCoordinateRegion)region andNumberOfResults:(int)numResults addressesOnly:(BOOL)addressOnly andReferer:(NSString *)referer;
{
	if (addressOnly == YES) {
		_minAccuracyValue = 8;
	}
	else {
		_minAccuracyValue = 0;
	}
	if (numResults > 10) {
		numResults = 10;
	}
	double centerLat = region.center.latitude;
	double centerLng = region.center.longitude;
	query = [query gtm_stringByEscapingForURLArgument];
	NSString *numberOfResults = [NSString stringWithFormat:@"%d",numResults];
	double spanLat = region.span.latitudeDelta;
	double spanLng = region.span.longitudeDelta;
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://ajax.googleapis.com/ajax/services/search/local?v=1.0&mrt=localonly&q=%@&rsz=%@&start=0&sll=%f,%f&sspn=%f,%f",query,numberOfResults,centerLat,centerLng,spanLat,spanLng]];
	
    NSLog( @"Google call: %@", url );
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
	[request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
	[request setValue:referer forHTTPHeaderField:@"Referer"];

	[self cancelGetGoogleObjects];
	
	_connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
	if (_connection) {
#ifdef ARC_ENABLED
		_responseData = [NSMutableData data];
#else
		_responseData = [[NSMutableData data] retain];
#endif
		_connectionIsActive = YES;
	}		
	else {
	  NSLog(@"connection failed");
	}
}


- (void)connection:(NSURLConnection *)conn didReceiveResponse:(NSURLResponse *)response {
	[_responseData setLength:0];
}


- (void)connection:(NSURLConnection *)conn didReceiveData:(NSData *)data {
	[_responseData appendData:data];
}

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error {
#ifdef ARC_ENABLED
	_connectionIsActive = NO;
	[_delegate googleLocalConnection:self didFailWithError:error];
#else
	_connectionIsActive = NO;
	[_delegate googleLocalConnection:self didFailWithError:error];
    [_conn release];
    [responseData release];
#endif
}

- (void)connectionDidFinishLoading:(NSURLConnection *)conn 
{
	NSLog(@"did finish loading GoogleLocalConnection");

	_connectionIsActive = NO;
	NSString *responseString = [[NSString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding];	
	NSError *jsonError = nil;
#ifdef ARC_ENABLED
	SBJsonParser *json = [SBJsonParser new];
#else
	SBJsonParser *json = [[SBJsonParser new] autorelease];
#endif

	NSDictionary *parsedJSON = [json objectWithString:responseString error:&jsonError];
	if (!json.error) {
        NSString *responseStatus = [NSString stringWithFormat:@"%@",[parsedJSON objectForKey:@"responseStatus"]];
        if ([responseStatus isEqualToString:@"200"]) {
            NSDictionary *gResponseData = [NSDictionary dictionaryWithDictionary:[parsedJSON objectForKey:@"responseData"]];				
            
            NSMutableArray *googleLocalObjects = [NSMutableArray arrayWithCapacity:[[gResponseData objectForKey:@"results"] count]]; 
            for (int x=0; x<[[gResponseData objectForKey:@"results"] count]; x++) {
                if ([[[[gResponseData objectForKey:@"results"] objectAtIndex:x] objectForKey:@"accuracy"] intValue] >= _minAccuracyValue)
                {
                    [googleLocalObjects addObject:(NSDictionary *)[[gResponseData objectForKey:@"results"] objectAtIndex:x]];
                }
            }
            for (int x=0; x<[googleLocalObjects count]; x++) {
#ifdef ARC_ENABLED					
                GoogleLocalObject *object = [[GoogleLocalObject alloc] initWithJsonResultDict:[googleLocalObjects objectAtIndex:x]];
#else
                GoogleLocalObject *object = [[[GoogleLocalObject alloc] initWithJsonResultDict:[googleLocalObjects objectAtIndex:x]] autorelease];
#endif
                [googleLocalObjects replaceObjectAtIndex:x withObject:object];
                [object description];
            }
            NSDictionary *viewPort = [NSDictionary dictionaryWithDictionary:[gResponseData objectForKey:@"viewport"]];
            [_delegate googleLocalConnection:self didFinishLoadingWithGoogleLocalObjects:googleLocalObjects andViewPort:[self getViewPortForGoogleSearchResults:googleLocalObjects andGoogleViewport:viewPort]];
        }
        else {
            // no results
            NSString *responseDetails = [NSString stringWithFormat:@"%@",[parsedJSON objectForKey:@"responseDetails"]];
            NSError *responseError = [NSError errorWithDomain:@"GoogleLocalObjectDomain" code:[responseStatus intValue] userInfo:[NSDictionary dictionaryWithObjectsAndKeys:responseDetails,@"NSLocalizedDescriptionKey",nil]];
            [_delegate googleLocalConnection:self didFailWithError:responseError];
        }
	}
	else {
		
		[_delegate googleLocalConnection:self didFailWithError:jsonError];
	}

#ifndef ARC_ENABLED
    [responseString release];
    [_responseData release];
    [conn release];
#endif
}

-(MKCoordinateRegion)getViewPortForGoogleSearchResults:(NSMutableArray *)googleLocalObjectArray andGoogleViewport:(NSDictionary *)viewPort
{
	if ([googleLocalObjectArray count] == 0) { // shouldn't actually need this because 0 results will give an error
		return MKCoordinateRegionMake(CLLocationCoordinate2DMake(0.0, 0.0), MKCoordinateSpanMake(0.1, 0.1));
	}	
	if ([googleLocalObjectArray count] == 1) {
		MKCoordinateRegion searchViewPortRegion;
		
		if (_minAccuracyValue == 8) {  // single address search
			GoogleLocalObject *obj = (GoogleLocalObject *)[googleLocalObjectArray objectAtIndex:0];
			searchViewPortRegion = MKCoordinateRegionMakeWithDistance([obj coordinate], 750, 750);
		}
		else { //could be a region search
			CLLocationCoordinate2D center = CLLocationCoordinate2DMake([[[viewPort objectForKey:@"center"] objectForKey:@"lat"] doubleValue], [[[viewPort objectForKey:@"center"] objectForKey:@"lng"] doubleValue]);
			NSString *viewPortSWLat = [[viewPort objectForKey:@"sw"] objectForKey:@"lat"];
			NSString *viewPortSWLng = [[viewPort objectForKey:@"sw"] objectForKey:@"lng"];
			NSString *viewPortNELat = [[viewPort objectForKey:@"ne"] objectForKey:@"lat"];
			NSString *viewPortNELng = [[viewPort objectForKey:@"ne"] objectForKey:@"lng"];
			searchViewPortRegion = [self makeRegionFromViewportCornersAndCenter:center NELat:viewPortNELat NELng:viewPortNELng SWLat:viewPortSWLat SWLng:viewPortSWLng];	
		}
		return searchViewPortRegion;					
	}
	
    // count >1 -- make a viewport region that includes all locations found
    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;
    
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;
    
    for(GoogleLocalObject *obj in googleLocalObjectArray)
    {
        topLeftCoord.longitude = fmin(topLeftCoord.longitude, obj.coordinate.longitude);
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, obj.coordinate.latitude);
        
        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, obj.coordinate.longitude);
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, obj.coordinate.latitude);
    }
    
    MKCoordinateRegion region;
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.2; // Add a little extra space on the sides
    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.2; // Add a little extra space on the sides
	return region;
	
}

-(MKCoordinateRegion)makeRegionFromViewportCornersAndCenter:(CLLocationCoordinate2D)center NELat:(NSString *)NELat NELng:(NSString *)NELng SWLat:(NSString *)SWLat SWLng:(NSString *)SWLng
{
	double latDelta = [NELat doubleValue] - [SWLat doubleValue];
	double lonDelta = [NELng doubleValue] - [SWLng doubleValue];
	MKCoordinateSpan span = MKCoordinateSpanMake(latDelta, lonDelta);
	return MKCoordinateRegionMake(center,span);
	
}



- (void)cancelGetGoogleObjects {
	if (_connectionIsActive == YES) {
		_connectionIsActive = NO;
		[_connection cancel];
#ifndef ARC_ENABLED
        [_responseData release];
        [_connection release];
#endif
	}
}


- (void)dealloc 
{
    [self cancelGetGoogleObjects];
#ifndef ARC_ENABLED
    [super dealloc];
#endif
}





@end
