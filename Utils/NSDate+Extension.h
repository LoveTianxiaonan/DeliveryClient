#import <Foundation/Foundation.h>

@interface NSDate (Extension)
- (NSString *) timeAgoSimple;
- (NSString *) timeAgo;
- (NSString *) timeAgoWithLimit:(NSTimeInterval)limit;
- (NSString *) timeAgoWithLimit:(NSTimeInterval)limit dateFormat:(NSDateFormatterStyle)dFormatter andTimeFormat:(NSDateFormatterStyle)tFormatter;
- (NSString *) timeAgoWithLimit:(NSTimeInterval)limit dateFormatter:(NSDateFormatter *)formatter;


// this method only returns "{value} {unit} ago" strings and no "yesterday"/"last month" strings
- (NSString *)dateTimeAgo;

- (NSString *)simplifiedTimeAgo; //MLAM

// this method gives when possible the date compared to the current calendar date: "this morning"/"yesterday"/"last week"/..
// when more precision is needed (= less than 6 hours ago) it returns the same output as dateTimeAgo
- (NSString *)dateTimeUntilNow;

- (NSString *)humanDateString;
- (NSString *)humanDateStringWithDotFormat;//2000.01.01
- (NSString *)humanDateStringWithDashFormat;//2000-01-01
- (NSString *)detailedHumanDateString;
- (NSString *)humanDateStringDetailedToMinute;
- (NSString *)humanHourMinuteDateString;
- (NSString *)humanShortDateString;

NSDate *dateFromString(NSString *dateString);
@end

