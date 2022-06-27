use std::fs::File;
use std::io;
use std::io::BufReader;
use std::path::PathBuf;

use lib::lexer::Lexer;
use lib::token::Token;

#[test]
fn test_tokenize() -> io::Result<()> {
    let mut path = PathBuf::from(env!("CARGO_MANIFEST_DIR"));
    path.push("tests/file.asm");
    let source_file = File::open(path).unwrap();
    let reader = BufReader::new(source_file);
    let mut lexer = Lexer::new(reader);
    loop {
        match lexer.lex_token() {
            Token::Error => panic!("Error"),
            Token::EOF => {
                println!("EOF");
                break;
            }
            token => println!("{:?}", token),
        }
    }
    Ok(())
}
