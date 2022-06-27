use std::env;
use std::fs::File;
use std::io::{BufReader, BufWriter};
use std::path::Path;

use crate::binary_code_generator::BinaryCodeGenerator;
use crate::lexer::Lexer;
use crate::parser::Parser;

pub fn run() {
    if let Some(path_string) = env::args().nth(1) {
        let path = Path::new(&path_string);
        let destination = path.with_extension("hack");
        generate_binary(path, destination.as_path());
    } else {
        println!("error: no input file")
    }
}

fn generate_binary(source: &Path, destination: &Path) {
    let source_file = match File::open(source) {
        std::io::Result::Err(e) => panic!("Error: {}", e.to_string()),
        std::io::Result::Ok(file) => file,
    };

    let destination_file = match File::create(destination) {
        std::io::Result::Err(e) => panic!("Error: {}", e.to_string()),
        std::io::Result::Ok(file) => file,
    };

    let reader = BufReader::new(source_file);
    let lexer = Lexer::new(reader);
    let mut parser = Parser::new(lexer);
    let (instructions, symbol_table) = parser.parse();

    let writer = BufWriter::new(destination_file);
    let mut generator = BinaryCodeGenerator::new(writer, instructions, symbol_table);

    if let std::io::Result::Err(e) = generator.generate() {
        panic!("Error: {}", e.to_string());
    }
}
