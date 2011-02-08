//
//  GoogleLocalObject.m
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

#import "GoogleLocalObject.h"

@implementation GoogleLocalObject

@synthesize title, subtitle, coordinate, streetAddress, phoneNumber, city, region, country, searchTerms, fullAddressArray, fullAddressString;

- (NSString *)description
{
	NSString *desc = [NSString stringWithFormat:@"title: %@ subtitle: %@ phoneNumber: %@ lat:%f lng:%f streetAddress: %@ city: %@ region: %@ country: %@ searchTerms: %@",title,subtitle,phoneNumber,coordinate.latitude, coordinate.longitude, streetAddress, city, region, country, searchTerms];
	return desc;
}

- (id)initWithTitle:(NSString *)tit subtitle:(NSString *)sub latitude:(double)lat longitude:(double)lng streetAddress:(NSString *)strAdd city:(NSString *)cit region:(NSString *)reg phoneNumber:(NSString *)phone country:(NSString *)coun searchTerms:(NSString *)terms fullAddress:(NSArray *)fullAddrss
{
	self = [super init];
	
	if (!self)
		return nil;
	[self setTitle:tit];
	[self setSubtitle:sub];
	[self setCoordinate:CLLocationCoordinate2DMake(lat, lng)];
	[self setStreetAddress:strAdd];
	[self setCity:cit];
	[self setRegion:reg];
	[self setPhoneNumber:phone];
	[self setCountry:coun];
	[self setSearchTerms:terms];
	[self setFullAddressArray:fullAddrss];
	NSMutableString *result = [[NSMutableString alloc] init];
	for (NSObject *obj in fullAddrss)
	{
		[result appendString:[obj description]];
		if (obj != [fullAddrss lastObject]) {
			[result appendString:@", "];
		}
	}
	[self setFullAddressString:result];
	return self;
}

- (id)initWithJsonResultDict:(NSDictionary *)jsonResultDict {
	[self initWithJsonResultDict:jsonResultDict searchTerms:@""];
	return self;
}

- (id)initWithJsonResultDict:(NSDictionary *)jsonResultDict searchTerms:(NSString *)terms
{	
	
	[self initWithTitle:[jsonResultDict objectForKey:@"titleNoFormatting"] latitude:[[jsonResultDict objectForKey:@"lat"] doubleValue] longitude:[[jsonResultDict objectForKey:@"lng"] doubleValue] streetAddress:[jsonResultDict objectForKey:@"streetAddress"] city:[jsonResultDict objectForKey:@"city"] region:[jsonResultDict objectForKey:@"region"] phoneNumber:[[[jsonResultDict objectForKey:@"phoneNumbers"] objectAtIndex:0] objectForKey:@"number"] country:[jsonResultDict objectForKey:@"country"] searchTerms:terms fullAddress:[jsonResultDict objectForKey:@"addressLines"]];
	return self;
}

//the below function sets the subtitle automatically to the street address
- (id)initWithTitle:(NSString *)tit latitude:(double)lat longitude:(double)lng streetAddress:(NSString *)strAdd city:(NSString *)cit region:(NSString *)reg phoneNumber:(NSString *)phone country:(NSString *)coun searchTerms:(NSString *)terms fullAddress:(NSArray *)fullAddrss
{
	[self initWithTitle:tit subtitle:strAdd latitude:lat longitude:lng streetAddress:strAdd city:cit region:reg phoneNumber:phone country:coun searchTerms:terms fullAddress:fullAddrss];
	return self;
}


- (void) dealloc
{
	[title release];
	[subtitle release];
	[streetAddress release];
	[city release];
	[region release];
	[country release];
	[phoneNumber release];
	[searchTerms release];
	[fullAddressArray release];
	[fullAddressString release];
	[super dealloc];
}

@end
