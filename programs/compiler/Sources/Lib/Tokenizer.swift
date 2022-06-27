import Foundation
#if os(Linux)
import FoundationXML
#endif

enum Tokenizer {
  
  static func tokenize(_ lexer: Lexer) -> String {
    let root = XMLElement(name: "tokens")
    while true {
      switch lexer.nextToken() {
        case .error: preconditionFailure()
        case .eof: return root.xmlString(options: .nodePrettyPrint)
        case let token:
          let element = XMLElement(name: token.classification, stringValue:token.value)
          root.addChild(element)
      }
    }
    preconditionFailure()
  }
  
}
