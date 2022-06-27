use std::io::prelude::*;
use std::mem;

use crate::instructions::{AInstruction, CInstruction, Destination, Instruction, Jump};
use crate::lexer::Lexer;
use crate::symbol_table::SymbolTable;
use crate::token::Token;

pub struct Parser<R: Read> {
    lexer: Lexer<R>,
    instructions: Vec<Instruction>,
}

impl<R: Read> Parser<R> {
    pub fn new(lexer: Lexer<R>) -> Parser<R> {
        Parser { lexer, instructions: Vec::new() }
    }

    pub fn parse(&mut self) -> (Vec<Instruction>, SymbolTable) {
        let mut symbol_table = SymbolTable::new();
        loop {
            match self.lexer.lex_token() {
                Token::EOF => break,
                Token::NewLine => continue,
                Token::At => self.parse_a_instruction(),
                Token::LParen => self.parse_label(&mut symbol_table),
                tok => self.try_parse_c_instruction(tok),
            }
        }
        (mem::take(&mut self.instructions), symbol_table)
    }

    fn parse_label(&mut self, symbol_table: &mut SymbolTable) {
        let mut token = self.lexer.lex_token(); // consume `(`
        if let Token::ID(symbol) = token {
            token = self.lexer.lex_token(); // consume symbol
            if let Token::RParen = token {
                token = self.lexer.lex_token(); // consume `)`
                if let Token::NewLine = token {
                    let address = self.instructions.len();
                    if symbol_table.insert(&symbol, address as u16) {
                        return;
                    } else {
                        panic!("Error: Label {} already present", symbol);
                    }
                }
            }
        }
        panic!("Error: Unexpected token: {:?}", token)
    }

    fn parse_a_instruction(&mut self) {
        let mut token = self.lexer.lex_token(); // consume `@`
        let instr = match token {
            Token::Number(value) => AInstruction::Number(value),
            Token::ID(symbol) => AInstruction::Symbol(symbol),
            _ => panic!("Error: Unexpected token: {:?}", token),
        };

        token = self.lexer.lex_token(); // consume number OR symbol
        match token {
            Token::NewLine => self.instructions.push(Instruction::A(instr)),
            _ => panic!("Error: expected new line"),
        }
    }

    fn parse_comp_dest_jump(&mut self, mut token: Token) -> (Token, String) {
        let mut string = String::new();
        loop {
            match token {
                Token::Equal => return (Token::Equal, string),
                Token::Semi => return (Token::Semi, string),
                Token::NewLine => return (Token::NewLine, string),
                Token::ID(ref value) => string.push_str(value.as_str()),
                Token::Number(value) => string.push_str(value.to_string().as_str()),
                Token::Minus => string.push_str("-"),
                Token::Plus => string.push_str("+"),
                Token::Not => string.push_str("!"),
                Token::And => string.push_str("&"),
                Token::Or => string.push_str("|"),
                _ => panic!("Error: Unexpected token {:?}|", token),
            }
            token = self.lexer.lex_token();
        }
    }

    fn parse_jump(&mut self) -> Jump {
        let jump: Jump;
        let token = self.lexer.lex_token(); // consume `;`
        match token {
            Token::ID(string) => jump = Jump::from(string.as_str()),
            _ => panic!("Error: Unexpected token: {:?}", token),
        }

        let token = self.lexer.lex_token(); // consume id
        match token {
            Token::NewLine => (),
            _ => panic!("Error: Unexpected token: {:?}", token),
        }
        return jump;
    }


    fn try_parse_c_instruction(&mut self, token: Token) {
        let dest: Destination;
        let comp: String;
        let jump: Jump;

        let (token, string) = self.parse_comp_dest_jump(token);
        match token {
            Token::Equal => {
                let token = self.lexer.lex_token(); // consume `=`
                dest = Destination::from(string.as_str());

                let (token, string) = self.parse_comp_dest_jump(token);
                match token {
                    Token::NewLine => {
                        comp = string;
                        jump = Jump::NULL;
                    }
                    Token::Semi => {
                        comp = string;
                        jump = self.parse_jump();
                    }
                    _ => unreachable!()
                }
            }
            Token::Semi => {
                dest = Destination::NULL;
                comp = string;
                jump = self.parse_jump();
            }
            Token::NewLine => {
                dest = Destination::NULL;
                comp = string;
                jump = Jump::NULL;
            }
            _ => unreachable!()
        }

        self.instructions.push(Instruction::C(CInstruction::new(dest, comp, jump)));
    }
}
