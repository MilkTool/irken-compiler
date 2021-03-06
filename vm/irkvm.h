// generated by vm/genopcodes - do not edit

typedef struct {
  char * name;
  int nargs;
  int varargs;
  int target;
} opcode_info_t;

opcode_info_t irk_opcodes[95] = {
  {"lit",         2, 0, 1},
  {"litc",        2, 0, 1},
  {"ret",         1, 0, 0},
  {"add",         3, 0, 1},
  {"sub",         3, 0, 1},
  {"mul",         3, 0, 1},
  {"div",         3, 0, 1},
  {"srem",        3, 0, 1},
  {"shl",         3, 0, 1},
  {"ashr",        3, 0, 1},
  {"or",          3, 0, 1},
  {"xor",         3, 0, 1},
  {"and",         3, 0, 1},
  {"eq",          3, 0, 1},
  {"lt",          3, 0, 1},
  {"gt",          3, 0, 1},
  {"le",          3, 0, 1},
  {"ge",          3, 0, 1},
  {"cmp",         3, 0, 1},
  {"tst",         2, 0, 0},
  {"jmp",         1, 0, 0},
  {"fun",         2, 0, 1},
  {"tail",        2, 0, 0},
  {"tail0",       1, 0, 0},
  {"env",         2, 0, 1},
  {"stor",        3, 0, 0},
  {"ref",         3, 0, 1},
  {"mov",         2, 0, 0},
  {"epush",       1, 0, 0},
  {"trcall",      3, 1, 0},
  {"trcall0",     2, 0, 0},
  {"ref0",        2, 0, 1},
  {"call",        3, 0, 0},
  {"call0",       2, 0, 0},
  {"pop",         1, 0, 1},
  {"printo",      1, 0, 0},
  {"prints",      1, 0, 0},
  {"topis",       1, 0, 0},
  {"topref",      2, 0, 1},
  {"topset",      2, 0, 0},
  {"set",         3, 0, 0},
  {"set0",        2, 0, 0},
  {"pop0",        0, 0, 0},
  {"epop",        0, 0, 0},
  {"tron",        0, 0, 0},
  {"troff",       0, 0, 0},
  {"gc",          0, 0, 0},
  {"imm",         2, 0, 1},
  {"make",        4, 1, 1},
  {"makei",       3, 0, 1},
  {"exit",        1, 0, 0},
  {"nvcase",      5, 1, 0},
  {"tupref",      3, 0, 1},
  {"vlen",        2, 0, 1},
  {"vref",        3, 0, 1},
  {"vset",        3, 0, 0},
  {"vmake",       3, 0, 1},
  {"alloc",       3, 0, 1},
  {"rref",        3, 0, 1},
  {"rset",        3, 0, 0},
  {"getcc",       1, 0, 1},
  {"putcc",       3, 0, 1},
  {"ffi",         4, 1, 1},
  {"smake",       2, 0, 1},
  {"sfromc",      3, 0, 1},
  {"slen",        2, 0, 1},
  {"sref",        3, 0, 1},
  {"sset",        3, 0, 0},
  {"scopy",       5, 0, 0},
  {"unchar",      2, 0, 1},
  {"gist",        1, 0, 1},
  {"argv",        1, 0, 1},
  {"quiet",       1, 0, 0},
  {"heap",        2, 0, 0},
  {"readf",       2, 0, 1},
  {"malloc",      3, 0, 1},
  {"halloc",      3, 0, 1},
  {"cget",        3, 0, 1},
  {"cset",        3, 0, 0},
  {"free",        1, 0, 0},
  {"sizeoff",     2, 0, 0},
  {"sgetp",       2, 0, 1},
  {"caref",       4, 0, 1},
  {"csref",       3, 0, 1},
  {"dlopen",      2, 0, 1},
  {"dlsym0",      2, 0, 1},
  {"dlsym",       3, 0, 1},
  {"csize",       2, 0, 1},
  {"cref2int",    2, 0, 1},
  {"int2cref",    2, 0, 1},
  {"ob2int",      2, 0, 1},
  {"obptr2int",   2, 0, 1},
  {"errno",       1, 0, 1},
  {"meta",        1, 0, 1},
  {"hash",        4, 0, 1}
};
#define IRK_OP_LIT        0
#define IRK_OP_LITC       1
#define IRK_OP_RET        2
#define IRK_OP_ADD        3
#define IRK_OP_SUB        4
#define IRK_OP_MUL        5
#define IRK_OP_DIV        6
#define IRK_OP_SREM       7
#define IRK_OP_SHL        8
#define IRK_OP_ASHR       9
#define IRK_OP_OR         10
#define IRK_OP_XOR        11
#define IRK_OP_AND        12
#define IRK_OP_EQ         13
#define IRK_OP_LT         14
#define IRK_OP_GT         15
#define IRK_OP_LE         16
#define IRK_OP_GE         17
#define IRK_OP_CMP        18
#define IRK_OP_TST        19
#define IRK_OP_JMP        20
#define IRK_OP_FUN        21
#define IRK_OP_TAIL       22
#define IRK_OP_TAIL0      23
#define IRK_OP_ENV        24
#define IRK_OP_STOR       25
#define IRK_OP_REF        26
#define IRK_OP_MOV        27
#define IRK_OP_EPUSH      28
#define IRK_OP_TRCALL     29
#define IRK_OP_TRCALL0    30
#define IRK_OP_REF0       31
#define IRK_OP_CALL       32
#define IRK_OP_CALL0      33
#define IRK_OP_POP        34
#define IRK_OP_PRINTO     35
#define IRK_OP_PRINTS     36
#define IRK_OP_TOPIS      37
#define IRK_OP_TOPREF     38
#define IRK_OP_TOPSET     39
#define IRK_OP_SET        40
#define IRK_OP_SET0       41
#define IRK_OP_POP0       42
#define IRK_OP_EPOP       43
#define IRK_OP_TRON       44
#define IRK_OP_TROFF      45
#define IRK_OP_GC         46
#define IRK_OP_IMM        47
#define IRK_OP_MAKE       48
#define IRK_OP_MAKEI      49
#define IRK_OP_EXIT       50
#define IRK_OP_NVCASE     51
#define IRK_OP_TUPREF     52
#define IRK_OP_VLEN       53
#define IRK_OP_VREF       54
#define IRK_OP_VSET       55
#define IRK_OP_VMAKE      56
#define IRK_OP_ALLOC      57
#define IRK_OP_RREF       58
#define IRK_OP_RSET       59
#define IRK_OP_GETCC      60
#define IRK_OP_PUTCC      61
#define IRK_OP_FFI        62
#define IRK_OP_SMAKE      63
#define IRK_OP_SFROMC     64
#define IRK_OP_SLEN       65
#define IRK_OP_SREF       66
#define IRK_OP_SSET       67
#define IRK_OP_SCOPY      68
#define IRK_OP_UNCHAR     69
#define IRK_OP_GIST       70
#define IRK_OP_ARGV       71
#define IRK_OP_QUIET      72
#define IRK_OP_HEAP       73
#define IRK_OP_READF      74
#define IRK_OP_MALLOC     75
#define IRK_OP_HALLOC     76
#define IRK_OP_CGET       77
#define IRK_OP_CSET       78
#define IRK_OP_FREE       79
#define IRK_OP_SIZEOFF    80
#define IRK_OP_SGETP      81
#define IRK_OP_CAREF      82
#define IRK_OP_CSREF      83
#define IRK_OP_DLOPEN     84
#define IRK_OP_DLSYM0     85
#define IRK_OP_DLSYM      86
#define IRK_OP_CSIZE      87
#define IRK_OP_CREF2INT   88
#define IRK_OP_INT2CREF   89
#define IRK_OP_OB2INT     90
#define IRK_OP_OBPTR2INT  91
#define IRK_OP_ERRNO      92
#define IRK_OP_META       93
#define IRK_OP_HASH       94
#define IRK_NUM_OPCODES 95
