import Foundation

public class LexerInputStream {
  
  private let file: UnsafeMutablePointer<FILE>
  private var index = 0
  
  public init?(string: String) {
    guard let file = tmpfile() else {
      return nil
    }
    
    string.withCString { string in
      let _ = fputs(string, file)
    }
    rewind(file)
    
    self.file = file
  }
  
  public init(path: String) {
    file = path.withCString { path in
      "r".withCString() { mode in
        fopen(path, mode)
      }
    }
  }
  
  deinit {
    if file != stdin {
      fclose(file)
    }
  }
  
  func next() -> Character? {
    index += 1
    let c = getc(file)
    if c == EOF {
      return nil
    } else {
      let char = Unicode.Scalar(UInt32(c)).map(Character.init)
      return char
    }
  }
  
  
  func retract() {
    assert(index > 0, "retract error")
    
    index -= 1
    if fseek(file, index, SEEK_SET) != 0 {
      assertionFailure("retract error")
    }
  }
}
