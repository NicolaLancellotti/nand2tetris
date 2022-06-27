#[derive(Debug)]
pub enum Token {
    Error,
    EOF,
    NewLine,
    At,
    Minus,
    Plus,
    Not,
    And,
    Or,
    Equal,
    Semi,
    LParen,
    RParen,
    Number(u16),
    ID(String),
}
