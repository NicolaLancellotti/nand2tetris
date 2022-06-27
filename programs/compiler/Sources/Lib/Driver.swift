import Foundation

public class Driver {
  
  public enum Action {
    case tokenize
    case dumpAST
    case compile
  }
  
  private let action: Action
  
  public init(action: Action) {
    self.action = action
  }
  
  public func run() {
    precondition(CommandLine.argc == 2)
    let source = URL(fileURLWithPath:  CommandLine.arguments[1])
    
    let isDirectory = (try? source.resourceValues(forKeys: [.isDirectoryKey])
      .isDirectory) ?? false
    if isDirectory  {
      let urls = try! FileManager.default
        .contentsOfDirectory(at: source, includingPropertiesForKeys: nil)
      for url in urls where url.pathExtension == "jack" {
        handleFile(at: url)
      }
    } else {
      precondition(source.pathExtension == "jack")
      handleFile(at: source)
    }
  }
  
  private func handleFile(at source: URL) {
    let fileName = source.deletingPathExtension().lastPathComponent
    precondition(fileName.first!.isUppercase)
    let stream = LexerInputStream(path: source.path)
    let lexer = Lexer(stream: stream)
    
    switch action {
      case .tokenize:
        let xml = Tokenizer.tokenize(lexer)
        let destination = source.deletingLastPathComponent().appendingPathComponent(fileName + "T2.xml")
        write(string: xml, destination: destination)
      case .dumpAST:
        let parser = Parser(lexer: lexer)
        let ast = parser.parse()
        let xml = cleanXML(ASTDumper.dump(ast))
        let destination = source.deletingLastPathComponent().appendingPathComponent(fileName + "2.xml")
        write(string: xml, destination: destination)
        break
      case .compile:
        let parser = Parser(lexer: lexer)
        let ast = parser.parse()
        let codeGen = CodeGen()
        let code = codeGen.compile(ast)
        let destination = source.deletingLastPathComponent().appendingPathComponent(fileName + ".vm")
        write(string: code, destination: destination)
        break
    }
  }
  
  private func cleanXML(_ string: String) -> String {
    var filtered = ""
    string.enumerateLines { line, stop in
#if os(Linux)
      let toRemove = line.contains("<></>")
#else
      let toRemove = line.allSatisfy{ $0 == " "}
#endif
      if !toRemove {
        filtered.append(line)
        filtered.append("\n")
      }
    }
    return filtered
  }

  private func write(string: String, destination: URL) {
    do {
      try string.write(to: destination, atomically: true, encoding: .utf8)
    } catch {
      preconditionFailure(error.localizedDescription)
    }
  }
}
