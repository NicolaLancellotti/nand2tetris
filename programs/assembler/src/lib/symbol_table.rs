use std::collections::HashMap;

pub struct SymbolTable {
    map: HashMap<String, u16>,
    index: u16,
}

impl SymbolTable {
    pub fn new() -> SymbolTable {
        let mut map = HashMap::new();
        for i in 0..=15 {
            map.insert("R".to_string() + &i.to_string(), i);
        }
        map.insert("SP".to_string(), 0);
        map.insert("LCL".to_string(), 1);
        map.insert("ARG".to_string(), 2);
        map.insert("THIS".to_string(), 3);
        map.insert("THAT".to_string(), 4);
        map.insert("SCREEN".to_string(), 16384);
        map.insert("KBD".to_string(), 24576);
        SymbolTable { map, index: 16 }
    }
}

impl SymbolTable {
    pub fn get(&mut self, symbol: &String) -> u16 {
        match self.map.get(symbol) {
            Option::Some(value) => value.clone(),
            Option::None => {
                let value = self.index;
                self.map.insert(symbol.to_string(), value);
                self.index += 1;
                value
            }
        }
    }

    pub fn insert(&mut self, symbol: &String, value: u16) -> bool {
        self.map.insert(symbol.to_string(), value).is_none()
    }
}
