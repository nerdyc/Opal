//
//  OpalXMLEvent.h
//  Opal
//
//  Created by Christian Niles on 5/8/10.
//  Copyright 2010 Christian Niles. All rights reserved.
//

#import <Foundation/Foundation.h>

enum OpalXMLEventType {
	OPAL_START_DOCUMENT_EVENT = 1,
	OPAL_DOCTYPE_EVENT,
	OPAL_START_TAG_EVENT,
	OPAL_TEXT_EVENT,
	OPAL_END_TAG_EVENT,
	OPAL_PROCESSING_INSTRUCTION_EVENT,
	OPAL_COMMENT_EVENT,
	OPAL_END_DOCUMENT_EVENT
};
typedef enum OpalXMLEventType OpalXMLEventType;

@interface OpalXMLEvent : NSObject {
	OpalXMLEventType type;
	
	NSString *version;
	NSString *encoding;
	BOOL standalone;
	
	NSString *tagName;
	NSDictionary *attributes;
	NSString *content;
}

@property (readonly) OpalXMLEventType type;

- (BOOL)isContent;

// ===== START DOCUMENT ================================================================================================

+ (OpalXMLEvent *)startDocumentEvent;
+ (OpalXMLEvent *)startDocumentEventWithEncoding:(NSString *)encoding;
+ (OpalXMLEvent *)startDocumentEventWithVersion:(NSString *)version encoding:(NSString *)encoding standalone:(BOOL)standalone;

- (id)initStartDocumentEvent;
- (id)initStartDocumentEventWithEncoding:(NSString *)encoding;
- (id)initStartDocumentEventWithVersion:(NSString *)version encoding:(NSString *)encoding standalone:(BOOL)standalone;
- (BOOL)isStartDocument;

@property (readonly) NSString *version;
@property (readonly) NSString *encoding;
@property (readonly) BOOL standalone;

// ===== END DOCUMENT ==================================================================================================

+ (OpalXMLEvent *)endDocumentEvent;
- (id)initEndDocumentEvent;
- (BOOL)isEndDocument;

// ===== START TAG =====================================================================================================

+ (OpalXMLEvent *)startTagEventWithTagName:(NSString *)startTagName andAttributes:(NSDictionary *)attributes;
- (id)initStartTagEventWithTagName:(NSString *)startTagName andAttributes:(NSDictionary *)attributes;
- (BOOL)isStartTag;

@property (readonly) NSString *tagName;
@property (readonly) NSDictionary *attributes;

- (NSString *)valueForAttribute:(NSString *)attributeName;

// ===== END TAG =======================================================================================================

+ (OpalXMLEvent *)endTagEventWithTagName:(NSString *)endTagName;
- (id)initEndTagEventWithTagName:(NSString *)endTagName;
- (BOOL)isEndTag;

// ===== TEXT ==========================================================================================================

+ (OpalXMLEvent *)textEventWithContent:(NSString *)textContent;
- (id)initTextEventWithContent:(NSString *)textContent;
- (BOOL)isText;
- (BOOL)isWhitespace;

@property (readonly) NSString *content;

// ===== COMMENTS ======================================================================================================

+ (OpalXMLEvent *)commentEventWithContent:(NSString *)comment;
- (id)initCommentEventWithContent:(NSString *)comment;
- (BOOL)isComment;

@end
