use io;
use memio;
use os;
use encoding::hex;
use strings;

def TEST1_EXPECT = `TAG_Compound('hello world'): 
{
  TAG_String('name'): 'Bananrama'
}
`;

@test fn test1() void = {
	const src = os::open("nbt/test1.nbt")!;
	defer io::close(src)!;
	const rd = read(src);
	const sink = memio::dynamic();
	dump(&sink, &rd)!;
	hex::dump(os::stdout, memio::buffer(&sink))!;
	hex::dump(os::stdout, strings::toutf8(TEST1_EXPECT))!;
	assert(memio::string(&sink)! == TEST1_EXPECT);
};

def TEST2_EXPECT = `TAG_Compound('Level'): 
{
  TAG_Long('longTest'): 9223372036854775807
  TAG_Short('shortTest'): 32767
  TAG_String('stringTest'): 'HELLO WORLD THIS IS A TEST STRING ÅÄÖ!'
  TAG_Float('floatTest'): 0.49823147
  TAG_Int('intTest'): 2147483647
  TAG_Compound('nested compound test'): 
  {
    TAG_Compound('ham'): 
    {
      TAG_String('name'): 'Hampus'
      TAG_Float('value'): 0.75
    }
    TAG_Compound('egg'): 
    {
      TAG_String('name'): 'Eggbert'
      TAG_Float('value'): 0.5
    }
  }
  TAG_List('listTest (long)'): 5 entries
  {
    TAG_Long(None): 11
    TAG_Long(None): 12
    TAG_Long(None): 13
    TAG_Long(None): 14
    TAG_Long(None): 15
  }
  TAG_List('listTest (compound)'): 2 entries
  {
    TAG_Compound(None): 
    {
      TAG_String('name'): 'Compound tag #0'
      TAG_Long('created-on'): 1264099775885
    }
    TAG_Compound(None): 
    {
      TAG_String('name'): 'Compound tag #1'
      TAG_Long('created-on'): 1264099775885
    }
  }
  TAG_Byte('byteTest'): 127
  TAG_Byte_Array('byteArrayTest (the first 1000 values of (n*n*255+n*7)%100, starting with n=0 (0, 62, 34, 16, 8, ...))'): [1000 bytes]
  TAG_Double('doubleTest'): 0.4931287132182315
}
`;

@test fn test2() void = {
	const src = os::open("nbt/test2.nbt")!;
	defer io::close(src)!;
	const rd = read(src);
	const sink = memio::dynamic();
	dump(&sink, &rd)!;
	hex::dump(os::stdout, memio::buffer(&sink))!;
	hex::dump(os::stdout, strings::toutf8(TEST2_EXPECT))!;
	assert(memio::string(&sink)! == TEST2_EXPECT);
};
