//
//  Parser.m
//  Uni Saar
//
//  Created by Daniel on 02/12/15.
//  Copyright © 2015 Universität des Saarlandes. All rights reserved.
//

#import "Parser.h"
#import "TFHpple.h"

@implementation Parser


+ (NSMutableArray*)parseWithURL:(NSString*)urll andWithPath:(NSString*)path {
    
    NSURL *url = [NSURL URLWithString:urll];
    NSMutableArray *NewsElements = [[NSMutableArray alloc] initWithCapacity:0];
    NSData *data;
    data = [NSData dataWithContentsOfURL:url];

    
 
    NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    html = [html stringByReplacingOccurrencesOfString:@"<br />" withString:@"\r"]; 
    html = [html stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    html = [html stringByReplacingOccurrencesOfString:@"<description></description>" withString:@"<description> </description>"];
    html = [html stringByReplacingOccurrencesOfString:@"<preis1></preis1>" withString:@"<preis1> </preis1>"];
    html = [html stringByReplacingOccurrencesOfString:@"<preis2></preis2>" withString:@"<preis2> </preis2>"];
    html = [html stringByReplacingOccurrencesOfString:@"<preis3></preis3>" withString:@"<preis3> </preis3>"];
    data = [html dataUsingEncoding:NSUTF8StringEncoding];
    
    TFHpple *Parser = [TFHpple hppleWithHTMLData:data];
    NSArray *Nodes = [Parser searchWithXPathQuery:path];
    
    for (TFHppleElement * elem in Nodes) {
        if (!([[elem content] isEqual:@""])) {
            [NewsElements addObject:[elem content]];
        }
    }
   
    return NewsElements;
}

@end

/*
 var html = NSString(data: data!, encoding: NSUTF8StringEncoding)!
 
 html = html.stringByReplacingOccurrencesOfString("<br />", withString: "\r").stringByReplacingOccurrencesOfString("\t", withString: "")
 
 
 let data2 = html.dataUsingEncoding(NSUTF8StringEncoding)
*/