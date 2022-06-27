import Foundation

enum Parser {
  
  static func parse(url: URL) -> [Command] {
    var commands = [Command]()
    let text = try! String(contentsOf: url)
    text.enumerateLines { [self] line, _ in
      let command: Command
      let splits = line.split { c in c == " " || c == "\t" }
      guard let first = splits.first else { return }
      switch first {
        case "//": return
        case "push":
          let tuple = parseSegmentAndIndex(splits)
          command = .push(segment: tuple.segment, index: tuple.index)
        case "pop":
          let tuple = parseSegmentAndIndex(splits)
          precondition(tuple.segment != .constant)
          command = .pop(segment: tuple.segment, index: tuple.index)
        case "label": command = .label(parseLabel(splits))
        case "goto": command = .goto(parseLabel(splits))
        case "if-goto": command = .ifGoto(parseLabel(splits))
        case "function":
          let tuple = parseFunctionNameAndCount(splits)
          command = .function(name: tuple.name, localVarsCount: tuple.count)
        case "call":
          let tuple = parseFunctionNameAndCount(splits)
          command = .call(name: tuple.name, argsCount: tuple.count)
        case "return": command = .return
        default:
          let commandName = String(first)
          if let c = UnaryCommand(rawValue: commandName) {
            command = .unary(c)
          } else if let c = BinaryCommand(rawValue: commandName) {
            command = .binary(c)
          } else if let c = ComparisonCommand(rawValue: commandName) {
            command = .comparison(c)
          } else {
            preconditionFailure()
          }
      }
      commands.append(command)
    }
    return commands
  }
  
  private static func parseSegmentAndIndex(_ splits: [String.SubSequence]) -> (segment: Segment, index: UInt16){
    let segment = Segment(rawValue: String(splits[1]))!
    let index = UInt16(splits[2])!
    return (segment, index)
  }
  
  private static func parseLabel(_ splits: [String.SubSequence]) -> String {
    let label = splits[1]
    let lableOK = label.allSatisfy { c in
      c == "_" || c == "." || c == ":" || (c.isASCII && (c.isLetter || c.isNumber))
    }
    precondition(lableOK)
    precondition(!label.first!.isNumber)
    return String(label)
  }
  
  private static func parseFunctionNameAndCount(_ splits: [String.SubSequence]) -> (name: String, count: Int) {
    let name = String(splits[1])
    let count = Int(splits[2])!
    return (name, count)
  }
}
