pub use driver::run;

pub mod token;
pub mod lexer;
mod parser;
mod instructions;
mod binary_code_generator;
mod symbol_table;
mod driver;
