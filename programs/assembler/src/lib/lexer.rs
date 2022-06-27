use std::io::BufReader;
use std::io::prelude::*;

use crate::token::Token;

pub struct Lexer<R: Read> {
    buffer: BufReader<R>,
    current: u8,
}

impl<R: Read> Lexer<R> {
    pub fn new(inner: R) -> Lexer<R> {
        let mut lexer = Lexer { buffer: BufReader::new(inner), current: 0 };
        if let std::io::Result::Err(e) = lexer.consume() {
            panic!("Error: {}", e.to_string());
        }
        lexer
    }

    fn consume(&mut self) -> std::io::Result<()> {
        let mut buffer = [0; 1];
        self.current = if self.buffer.read_exact(&mut buffer).is_err() {
            0
        } else {
            buffer[0]
        };
        Ok(())
    }

    pub fn lex_token(&mut self) -> Token {
        match self.lex_token_internal() {
            std::io::Result::Err(e) => panic!("Error: {}", e.to_string()),
            std::io::Result::Ok(token) => token,
        }
    }

    fn lex_token_internal(&mut self) -> std::io::Result<Token> {
        'L: loop {
            let token = if self.current == 0 {
                Token::EOF
            } else {
                match self.current as char {
                    '/' => {
                        loop {
                            self.consume()?;
                            if self.current == 0 || (self.current as char) == '\n' {
                                continue 'L;
                            }
                        }
                    }
                    ' ' | '\t' => {
                        self.consume()?;
                        continue;
                    }
                    '\r' => {
                        self.consume()?;
                        continue 'L;
                    }
                    '\n' => {
                        self.consume()?;
                        Token::NewLine
                    }
                    '@' => {
                        self.consume()?;
                        Token::At
                    }
                    '-' => {
                        self.consume()?;
                        Token::Minus
                    }
                    '+' => {
                        self.consume()?;
                        Token::Plus
                    }
                    '&' => {
                        self.consume()?;
                        Token::And
                    }
                    '|' => {
                        self.consume()?;
                        Token::Or
                    }
                    '!' => {
                        self.consume()?;
                        Token::Not
                    }
                    '=' => {
                        self.consume()?;
                        Token::Equal
                    }
                    ';' => {
                        self.consume()?;
                        Token::Semi
                    }
                    c @ '0'..='9' => {
                        self.consume()?;
                        let mut value: u16 = (c as u16) - ('0' as u16);
                        while self.current.is_ascii_digit() {
                            let digit = self.current - ('0' as u8);
                            self.consume()?;
                            value *= 10;
                            value += digit as u16;
                            if value > 32767 {
                                return Ok(Token::Error);
                            }
                        }
                        Token::Number(value)
                    }
                    '(' => {
                        self.consume()?;
                        Token::LParen
                    }
                    ')' => {
                        self.consume()?;
                        Token::RParen
                    }
                    mut c
                    if c == '_' || c == '.' || c == '$' || c == ':' || c.is_ascii_alphabetic() => {
                        self.consume()?;
                        let mut string = c.to_string();
                        loop {
                            c = self.current as char;
                            if c == '_' || c == '.' || c == '$' || c == ':' ||
                                c.is_ascii_alphabetic() || c.is_ascii_digit() {
                                self.consume()?;
                                string.push(c)
                            } else {
                                break;
                            }
                        }
                        Token::ID(string)
                    }
                    _ => Token::Error
                }
            };
            return Ok(token);
        }
    }
}
