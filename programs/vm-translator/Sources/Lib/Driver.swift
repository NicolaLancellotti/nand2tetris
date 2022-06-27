import Foundation

public class Driver {
  private let codeWriter = CodeWriter()
  
  public init() {}
  
  public func run() {
    precondition(CommandLine.argc == 2)
    let source = URL(fileURLWithPath:  CommandLine.arguments[1])
    let destination: URL
    
    let isDirectory = (try? source.resourceValues(forKeys: [.isDirectoryKey])
      .isDirectory) ?? false
    if isDirectory  {
      codeWriter.writeBootstrap()
      let urls = try! FileManager.default
        .contentsOfDirectory(at: source, includingPropertiesForKeys: nil)
      for url in urls where url.pathExtension == "vm" {
        translateFile(at: url)
      }
      destination = source.appendingPathComponent(source.lastPathComponent)
    } else {
      precondition(source.pathExtension == "vm")
      translateFile(at: source)
      destination = source.deletingPathExtension()
    }
    
    let stream = codeWriter.stream
    do {
      try stream.write(to: destination.appendingPathExtension("asm"),
                       atomically: true, encoding: .utf8)
    } catch {
      preconditionFailure(error.localizedDescription)
    }
  }
  
  private func translateFile(at source: URL) {
    let fileName = source.deletingPathExtension().lastPathComponent
    precondition(fileName.first!.isUppercase)
    let commands = Parser.parse(url: source)
    codeWriter.translate(commands: commands, to: fileName)
  }
}
