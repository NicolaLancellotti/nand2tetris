use std::io::BufWriter;
use std::io::prelude::*;

use crate::instructions::{AInstruction, CInstruction, Destination, Instruction, Jump};
use crate::symbol_table::SymbolTable;

pub struct BinaryCodeGenerator<W: Write> {
    buffer: BufWriter<W>,
    instructions: Vec<Instruction>,
    symbol_table: SymbolTable,
}

impl<W: Write> BinaryCodeGenerator<W> {
    pub fn new(buffer: BufWriter<W>,
               instructions: Vec<Instruction>,
               symbol_table: SymbolTable) -> BinaryCodeGenerator<W> {
        BinaryCodeGenerator { buffer, instructions, symbol_table }
    }
}

impl<W: Write> BinaryCodeGenerator<W> {
    pub fn generate(&mut self) -> std::io::Result<()> {
        for instruction in self.instructions.iter() {
            match instruction {
                Instruction::A(instr) =>
                    generate_a_instruction(&mut self.buffer, &mut self.symbol_table, instr)?,
                Instruction::C(instr) =>
                    generate_c_instruction(&mut self.buffer, instr)?,
            };
            self.buffer.write(b"\n")?;
        }
        Ok(())
    }
}

fn generate_a_instruction<W: Write>(buffer: &mut BufWriter<W>, symbol_table: &mut SymbolTable, instr: &AInstruction) -> std::io::Result<()> {
    buffer.write(b"0")?;
    let number = match instr {
        AInstruction::Number(number) => number.clone(),
        AInstruction::Symbol(symbol) => symbol_table.get(symbol),
    };
    let binary = format!("{:015b}", number);
    buffer.write(binary.as_bytes())?;
    Ok(())
}

fn generate_c_instruction<W: Write>(buffer: &mut BufWriter<W>, instr: &CInstruction) -> std::io::Result<()> {
    buffer.write(b"111")?;
    match instr.comp.as_str() {
        "0" => buffer.write(b"0101010")?,
        "1" => buffer.write(b"0111111")?,
        "-1" => buffer.write(b"0111010")?,
        "D" => buffer.write(b"0001100")?,
        "A" => buffer.write(b"0110000")?,
        "!D" => buffer.write(b"0001101")?,
        "!A" => buffer.write(b"0110001")?,
        "-D" => buffer.write(b"0001111")?,
        "-A" => buffer.write(b"0110011")?,
        "D+1" => buffer.write(b"0011111")?,
        "A+1" => buffer.write(b"0110111")?,
        "D-1" => buffer.write(b"0001110")?,
        "A-1" => buffer.write(b"0110010")?,
        "D+A" => buffer.write(b"0000010")?,
        "D-A" => buffer.write(b"0010011")?,
        "A-D" => buffer.write(b"0000111")?,
        "D&A" => buffer.write(b"0000000")?,
        "D|A" => buffer.write(b"0010101")?,
        "M" => buffer.write(b"1110000")?,
        "!M" => buffer.write(b"1110001")?,
        "-M" => buffer.write(b"1110011")?,
        "M+1" => buffer.write(b"1110111")?,
        "M-1" => buffer.write(b"1110010")?,
        "D+M" => buffer.write(b"1000010")?,
        "D-M" => buffer.write(b"1010011")?,
        "M-D" => buffer.write(b"1000111")?,
        "D&M" => buffer.write(b"1000000")?,
        "D|M" => buffer.write(b"1010101")?,
        _ => panic!("Error"),
    };

    match instr.dest {
        Destination::NULL => buffer.write(b"000")?,
        Destination::M => buffer.write(b"001")?,
        Destination::D => buffer.write(b"010")?,
        Destination::DM => buffer.write(b"011")?,
        Destination::A => buffer.write(b"100")?,
        Destination::AM => buffer.write(b"101")?,
        Destination::AD => buffer.write(b"110")?,
        Destination::ADM => buffer.write(b"111")?,
    };

    match instr.jump {
        Jump::NULL => buffer.write(b"000")?,
        Jump::JGT => buffer.write(b"001")?,
        Jump::JEQ => buffer.write(b"010")?,
        Jump::JGE => buffer.write(b"011")?,
        Jump::JLT => buffer.write(b"100")?,
        Jump::JNE => buffer.write(b"101")?,
        Jump::JLE => buffer.write(b"110")?,
        Jump::JMP => buffer.write(b"111")?,
    };
    Ok(())
}
