#import <Foundation/Foundation.h>
#import <libxml/tree.h>

@class DDXMLDocument;

/**
 * Welcome to KissXML.
 * 
 * The project page has documentation if you have questions.
 * https://github.com/robbiehanson/KissXML
 * 
 * If you're new to the project you may wish to read the "Getting Started" wiki.
 * https://github.com/robbiehanson/KissXML/wiki/GettingStarted
 * 
 * KissXML provides a drop-in replacement for Apple's NSXML class cluster.
 * The goal is to get the exact same behavior as the NSXML classes.
 * 
 * For API Reference, see Apple's excellent documentation,
 * either via Xcode's Mac OS X documentation, or via the web:
 * 
 * https://github.com/robbiehanson/KissXML/wiki/Reference
**/

typedef NS_ENUM(NSUInteger, DDXMLNodeKind) {
	DDXMLInvalidKind                = 0,
	DDXMLDocumentKind               = XML_DOCUMENT_NODE,
	DDXMLElementKind                = XML_ELEMENT_NODE,
	DDXMLAttributeKind              = XML_ATTRIBUTE_NODE,
	DDXMLNamespaceKind              = XML_NAMESPACE_DECL,
	DDXMLProcessingInstructionKind  = XML_PI_NODE,
	DDXMLCommentKind                = XML_COMMENT_NODE,
	DDXMLTextKind                   = XML_TEXT_NODE,
	DDXMLDTDKind                    = XML_DTD_NODE,
	DDXMLEntityDeclarationKind      = XML_ENTITY_DECL,
	DDXMLAttributeDeclarationKind   = XML_ATTRIBUTE_DECL,
	DDXMLElementDeclarationKind     = XML_ELEMENT_DECL,
	DDXMLNotationDeclarationKind    = XML_NOTATION_NODE
};

enum {
	DDXMLNodeOptionsNone            = 0,
	DDXMLNodeExpandEmptyElement     = 1 << 1,
	DDXMLNodeCompactEmptyElement    = 1 << 2,
	DDXMLNodePrettyPrint            = 1 << 17,
};


//extern struct _xmlKind;


@interface DDXMLNode : NSObject <NSCopying>
{
	// Every DDXML object is simply a wrapper around an underlying libxml node
	struct _xmlKind *genericPtr;
	
	// Every libxml node resides somewhere within an xml tree heirarchy.
	// We cannot free the tree heirarchy until all referencing nodes have been released.
	// So all nodes retain a reference to the node that created them,
	// and when the last reference is released the tree gets freed.
	DDXMLNode *owner;
}

//- (id)initWithKind:(DDXMLNodeKind)kind;

//- (id)initWithKind:(DDXMLNodeKind)kind options:(NSUInteger)options;

//+ (id)document;

//+ (id)documentWithRootElement:(DDXMLElement *)element;

+ (id)elementWithName:(NSString *)name;

+ (id)elementWithName:(NSString *)name URI:(NSString *)URI;

+ (id)elementWithName:(NSString *)name stringValue:(NSString *)string;

+ (id)elementWithName:(NSString *)name children:(NSArray *)children attributes:(NSArray *)attributes;

+ (id)attributeWithName:(NSString *)name stringValue:(NSString *)stringValue;

+ (id)attributeWithName:(NSString *)name URI:(NSString *)URI stringValue:(NSString *)stringValue;

+ (id)namespaceWithName:(NSString *)name stringValue:(NSString *)stringValue;

+ (id)processingInstructionWithName:(NSString *)name stringValue:(NSString *)stringValue;

+ (id)commentWithStringValue:(NSString *)stringValue;

+ (id)textWithStringValue:(NSString *)stringValue;

//+ (id)DTDNodeWithXMLString:(NSString *)string;

#pragma mark --- Properties ---

@property (NS_NONATOMIC_IOSONLY, readonly) DDXMLNodeKind kind;

@property (NS_NONATOMIC_IOSONLY, copy) NSString *name;

//- (void)setObjectValue:(id)value;
//- (id)objectValue;

//- (void)setStringValue:(NSString *)string resolvingEntities:(BOOL)resolve;
@property (NS_NONATOMIC_IOSONLY, copy) NSString *stringValue;

#pragma mark --- Tree Navigation ---

@property (NS_NONATOMIC_IOSONLY, readonly) NSUInteger index;

@property (NS_NONATOMIC_IOSONLY, readonly) NSUInteger level;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) DDXMLDocument *rootDocument;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) DDXMLNode *parent;
@property (NS_NONATOMIC_IOSONLY, readonly) NSUInteger childCount;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *children;
- (DDXMLNode *)childAtIndex:(NSUInteger)index;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) DDXMLNode *previousSibling;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) DDXMLNode *nextSibling;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) DDXMLNode *previousNode;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) DDXMLNode *nextNode;

- (void)detach;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *XPath;

#pragma mark --- QNames ---

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *localName;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *prefix;

@property (NS_NONATOMIC_IOSONLY, copy) NSString *URI;

+ (NSString *)localNameForName:(NSString *)name;
+ (NSString *)prefixForName:(NSString *)name;
//+ (DDXMLNode *)predefinedNamespaceForPrefix:(NSString *)name;

#pragma mark --- Output ---

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *description;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *XMLString;
- (NSString *)XMLStringWithOptions:(NSUInteger)options;
//- (NSString *)canonicalXMLStringPreservingComments:(BOOL)comments;

#pragma mark --- XPath/XQuery ---

- (NSArray *)nodesForXPath:(NSString *)xpath error:(NSError **)error;
//- (NSArray *)objectsForXQuery:(NSString *)xquery constants:(NSDictionary *)constants error:(NSError **)error;
//- (NSArray *)objectsForXQuery:(NSString *)xquery error:(NSError **)error;

@end
