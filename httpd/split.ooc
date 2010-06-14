import structs/ArrayList

StringSplitter: class extends Iterable<String> {

    input, delim: String
    index = 0, length, maxSplits, splits: Int
    empties: Bool

    init: func~withCharWithoutMaxSplits(input: String, delim: Char) {
        init~withChar(input, delim, -1)
    }

    init: func~withStringWithoutMaxSplits(input: String, delim: String) {
        init~withString(input, delim, -1)
    }

    init: func~withChar(input: String, delim: Char, maxSplits: Int) {
        init~withString(input, String new(delim), maxSplits)
    }
    
    init: func~withString(=input, =delim, =maxSplits) {
        T = String // small fix for runtime introspection
        length = input length()
        splits = 0
        empties = false
    }
    
    iterator: func -> Iterator<String> { StringSplitterIterator<String> new(this) }
    
    hasNext: func -> Bool { index < length }
    
    /**
     * @return the next token, or null if we're at the end.
     */
    nextSplit: func() -> String {
        // at the end?
        if(!hasNext()) return null

        if(!empties) {
            // skip all delimiters
            while(index + delim length() < input length() && input substring(index, index + delim length()) == delim) index += delim length()
        } else if(index + delim length() < input length() && input substring(index, index + delim length()) == delim) {
            // skip only one delimiter
            index += delim length()
        }
        
        // save the index
        oldIndex := index

        // maximal count of splits done?
        if(splits == maxSplits) {
            index = length
            return input substring(oldIndex)
        }
         
        // skip all non-delimiters
        while(index + delim length() < input length() && input substring(index, index + delim length()) != delim) index += 1
        
        if (index + delim length() >= input length()) index = length
        
        splits += 1
        return input substring(oldIndex, index)
    }
}

StringSplitterIterator: class <T> extends Iterator<T> {

    st: StringSplitter
    index := 0
    
    init: func ~sti (=st) {}
    hasNext: func -> Bool { st hasNext() }
    next: func -> T       { st nextSplit() }
    hasPrev: func -> Bool { false }
    prev: func -> T       { null }
    remove: func -> Bool  { false }
    
}

String: cover {

    split: func~withString(s: String, maxSplits: Int) -> StringSplitter {
        StringSplitter new(this, s, maxSplits)
    }
    
    split: func~withChar(c: Char, maxSplits: Int) -> StringSplitter {
        StringSplitter new(this, c, maxSplits)
    }

    split: func~withStringWithoutMaxSplits(s: String) -> StringSplitter {
        StringSplitter new(this, s)
    }

    split: func~withCharWithoutMaxSplits(c: Char) -> StringSplitter {
        StringSplitter new(this, c)
    }

    split: func~withStringWithEmpties(s: String, empties: Bool) -> StringSplitter {
        tok := StringSplitter new(this, s)
        tok empties = empties
        tok
    }

    split: func~withCharWithEmpties(c: Char, empties: Bool) -> StringSplitter {
        tok := StringSplitter new(this, c)
        tok empties = empties
        tok
    }
    

    splits: func~withString(s: String, maxSplits: Int) -> ArrayList<String> {
        StringSplitter new(this, s, maxSplits) toArrayList()
    }
    
    splits: func~withChar(c: Char, maxSplits: Int) -> ArrayList<String> {
        StringSplitter new(this, c, maxSplits) toArrayList()
    }

    splits: func~withStringWithoutMaxSplits(s: String) -> ArrayList<String> {
        StringSplitter new(this, s) toArrayList()
    }

    splits: func~withCharWithoutMaxSplits(c: Char) -> ArrayList<String> {
        StringSplitter new(this, c) toArrayList()
    }
}
