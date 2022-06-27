use std::convert::From;

pub enum Instruction {
    A(AInstruction),
    C(CInstruction),
}

pub enum AInstruction {
    Number(u16),
    Symbol(String),
}

pub struct CInstruction {
    pub dest: Destination,
    pub comp: String,
    pub jump: Jump,
}

impl CInstruction {
    pub fn new(dest: Destination, comp: String, jump: Jump) -> CInstruction {
        CInstruction {
            dest,
            comp,
            jump,
        }
    }
}

pub enum Destination {
    NULL,
    M,
    D,
    DM,
    A,
    AM,
    AD,
    ADM,
}

impl From<&str> for Destination {
    fn from(string: &str) -> Self {
        match string {
            "M" => Destination::M,
            "D" => Destination::D,
            "DM" | "MD" => Destination::DM,
            "A" => Destination::A,
            "AM" | "MA" => Destination::AM,
            "AD" | "DA" => Destination::AD,
            "ADM" => Destination::ADM,
            _ => panic!("Error: Unexpected destination: {}", string),
        }
    }
}

pub enum Jump {
    NULL,
    JGT,
    JEQ,
    JGE,
    JLT,
    JNE,
    JLE,
    JMP,
}

impl From<&str> for Jump {
    fn from(string: &str) -> Self {
        match string {
            "JGT" => Jump::JGT,
            "JEQ" => Jump::JEQ,
            "JGE" => Jump::JGE,
            "JLT" => Jump::JLT,
            "JNE" => Jump::JNE,
            "JLE" => Jump::JLE,
            "JMP" => Jump::JMP,
            _ => panic!("Error: Unexpected jump: {}", string),
        }
    }
}
