
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controller_rom2 is
generic
	(
		ADDR_WIDTH : integer := 15 -- Specify your actual ROM size to save LEs and unnecessary block RAM usage.
	);
port (
	clk : in std_logic;
	reset_n : in std_logic := '1';
	addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
	q : out std_logic_vector(31 downto 0);
	-- Allow writes - defaults supplied to simplify projects that don't need to write.
	d : in std_logic_vector(31 downto 0) := X"00000000";
	we : in std_logic := '0';
	bytesel : in std_logic_vector(3 downto 0) := "1111"
);
end entity;

architecture rtl of controller_rom2 is

	signal addr1 : integer range 0 to 2**ADDR_WIDTH-1;

	--  build up 2D array to hold the memory
	type word_t is array (0 to 3) of std_logic_vector(7 downto 0);
	type ram_t is array (0 to 2 ** ADDR_WIDTH - 1) of word_t;

	signal ram : ram_t:=
	(

     0 => (x"14",x"14",x"14",x"14"),
     1 => (x"22",x"00",x"00",x"14"),
     2 => (x"08",x"14",x"14",x"22"),
     3 => (x"02",x"00",x"00",x"08"),
     4 => (x"0f",x"59",x"51",x"03"),
     5 => (x"7f",x"3e",x"00",x"06"),
     6 => (x"1f",x"55",x"5d",x"41"),
     7 => (x"7e",x"00",x"00",x"1e"),
     8 => (x"7f",x"09",x"09",x"7f"),
     9 => (x"7f",x"00",x"00",x"7e"),
    10 => (x"7f",x"49",x"49",x"7f"),
    11 => (x"1c",x"00",x"00",x"36"),
    12 => (x"41",x"41",x"63",x"3e"),
    13 => (x"7f",x"00",x"00",x"41"),
    14 => (x"3e",x"63",x"41",x"7f"),
    15 => (x"7f",x"00",x"00",x"1c"),
    16 => (x"41",x"49",x"49",x"7f"),
    17 => (x"7f",x"00",x"00",x"41"),
    18 => (x"01",x"09",x"09",x"7f"),
    19 => (x"3e",x"00",x"00",x"01"),
    20 => (x"7b",x"49",x"41",x"7f"),
    21 => (x"7f",x"00",x"00",x"7a"),
    22 => (x"7f",x"08",x"08",x"7f"),
    23 => (x"00",x"00",x"00",x"7f"),
    24 => (x"41",x"7f",x"7f",x"41"),
    25 => (x"20",x"00",x"00",x"00"),
    26 => (x"7f",x"40",x"40",x"60"),
    27 => (x"7f",x"7f",x"00",x"3f"),
    28 => (x"63",x"36",x"1c",x"08"),
    29 => (x"7f",x"00",x"00",x"41"),
    30 => (x"40",x"40",x"40",x"7f"),
    31 => (x"7f",x"7f",x"00",x"40"),
    32 => (x"7f",x"06",x"0c",x"06"),
    33 => (x"7f",x"7f",x"00",x"7f"),
    34 => (x"7f",x"18",x"0c",x"06"),
    35 => (x"3e",x"00",x"00",x"7f"),
    36 => (x"7f",x"41",x"41",x"7f"),
    37 => (x"7f",x"00",x"00",x"3e"),
    38 => (x"0f",x"09",x"09",x"7f"),
    39 => (x"7f",x"3e",x"00",x"06"),
    40 => (x"7e",x"7f",x"61",x"41"),
    41 => (x"7f",x"00",x"00",x"40"),
    42 => (x"7f",x"19",x"09",x"7f"),
    43 => (x"26",x"00",x"00",x"66"),
    44 => (x"7b",x"59",x"4d",x"6f"),
    45 => (x"01",x"00",x"00",x"32"),
    46 => (x"01",x"7f",x"7f",x"01"),
    47 => (x"3f",x"00",x"00",x"01"),
    48 => (x"7f",x"40",x"40",x"7f"),
    49 => (x"0f",x"00",x"00",x"3f"),
    50 => (x"3f",x"70",x"70",x"3f"),
    51 => (x"7f",x"7f",x"00",x"0f"),
    52 => (x"7f",x"30",x"18",x"30"),
    53 => (x"63",x"41",x"00",x"7f"),
    54 => (x"36",x"1c",x"1c",x"36"),
    55 => (x"03",x"01",x"41",x"63"),
    56 => (x"06",x"7c",x"7c",x"06"),
    57 => (x"71",x"61",x"01",x"03"),
    58 => (x"43",x"47",x"4d",x"59"),
    59 => (x"00",x"00",x"00",x"41"),
    60 => (x"41",x"41",x"7f",x"7f"),
    61 => (x"03",x"01",x"00",x"00"),
    62 => (x"30",x"18",x"0c",x"06"),
    63 => (x"00",x"00",x"40",x"60"),
    64 => (x"7f",x"7f",x"41",x"41"),
    65 => (x"0c",x"08",x"00",x"00"),
    66 => (x"0c",x"06",x"03",x"06"),
    67 => (x"80",x"80",x"00",x"08"),
    68 => (x"80",x"80",x"80",x"80"),
    69 => (x"00",x"00",x"00",x"80"),
    70 => (x"04",x"07",x"03",x"00"),
    71 => (x"20",x"00",x"00",x"00"),
    72 => (x"7c",x"54",x"54",x"74"),
    73 => (x"7f",x"00",x"00",x"78"),
    74 => (x"7c",x"44",x"44",x"7f"),
    75 => (x"38",x"00",x"00",x"38"),
    76 => (x"44",x"44",x"44",x"7c"),
    77 => (x"38",x"00",x"00",x"00"),
    78 => (x"7f",x"44",x"44",x"7c"),
    79 => (x"38",x"00",x"00",x"7f"),
    80 => (x"5c",x"54",x"54",x"7c"),
    81 => (x"04",x"00",x"00",x"18"),
    82 => (x"05",x"05",x"7f",x"7e"),
    83 => (x"18",x"00",x"00",x"00"),
    84 => (x"fc",x"a4",x"a4",x"bc"),
    85 => (x"7f",x"00",x"00",x"7c"),
    86 => (x"7c",x"04",x"04",x"7f"),
    87 => (x"00",x"00",x"00",x"78"),
    88 => (x"40",x"7d",x"3d",x"00"),
    89 => (x"80",x"00",x"00",x"00"),
    90 => (x"7d",x"fd",x"80",x"80"),
    91 => (x"7f",x"00",x"00",x"00"),
    92 => (x"6c",x"38",x"10",x"7f"),
    93 => (x"00",x"00",x"00",x"44"),
    94 => (x"40",x"7f",x"3f",x"00"),
    95 => (x"7c",x"7c",x"00",x"00"),
    96 => (x"7c",x"0c",x"18",x"0c"),
    97 => (x"7c",x"00",x"00",x"78"),
    98 => (x"7c",x"04",x"04",x"7c"),
    99 => (x"38",x"00",x"00",x"78"),
   100 => (x"7c",x"44",x"44",x"7c"),
   101 => (x"fc",x"00",x"00",x"38"),
   102 => (x"3c",x"24",x"24",x"fc"),
   103 => (x"18",x"00",x"00",x"18"),
   104 => (x"fc",x"24",x"24",x"3c"),
   105 => (x"7c",x"00",x"00",x"fc"),
   106 => (x"0c",x"04",x"04",x"7c"),
   107 => (x"48",x"00",x"00",x"08"),
   108 => (x"74",x"54",x"54",x"5c"),
   109 => (x"04",x"00",x"00",x"20"),
   110 => (x"44",x"44",x"7f",x"3f"),
   111 => (x"3c",x"00",x"00",x"00"),
   112 => (x"7c",x"40",x"40",x"7c"),
   113 => (x"1c",x"00",x"00",x"7c"),
   114 => (x"3c",x"60",x"60",x"3c"),
   115 => (x"7c",x"3c",x"00",x"1c"),
   116 => (x"7c",x"60",x"30",x"60"),
   117 => (x"6c",x"44",x"00",x"3c"),
   118 => (x"6c",x"38",x"10",x"38"),
   119 => (x"1c",x"00",x"00",x"44"),
   120 => (x"3c",x"60",x"e0",x"bc"),
   121 => (x"44",x"00",x"00",x"1c"),
   122 => (x"4c",x"5c",x"74",x"64"),
   123 => (x"08",x"00",x"00",x"44"),
   124 => (x"41",x"77",x"3e",x"08"),
   125 => (x"00",x"00",x"00",x"41"),
   126 => (x"00",x"7f",x"7f",x"00"),
   127 => (x"41",x"00",x"00",x"00"),
   128 => (x"08",x"3e",x"77",x"41"),
   129 => (x"01",x"02",x"00",x"08"),
   130 => (x"02",x"02",x"03",x"01"),
   131 => (x"7f",x"7f",x"00",x"01"),
   132 => (x"7f",x"7f",x"7f",x"7f"),
   133 => (x"08",x"08",x"00",x"7f"),
   134 => (x"3e",x"3e",x"1c",x"1c"),
   135 => (x"7f",x"7f",x"7f",x"7f"),
   136 => (x"1c",x"1c",x"3e",x"3e"),
   137 => (x"10",x"00",x"08",x"08"),
   138 => (x"18",x"7c",x"7c",x"18"),
   139 => (x"10",x"00",x"00",x"10"),
   140 => (x"30",x"7c",x"7c",x"30"),
   141 => (x"30",x"10",x"00",x"10"),
   142 => (x"1e",x"78",x"60",x"60"),
   143 => (x"66",x"42",x"00",x"06"),
   144 => (x"66",x"3c",x"18",x"3c"),
   145 => (x"38",x"78",x"00",x"42"),
   146 => (x"6c",x"c6",x"c2",x"6a"),
   147 => (x"00",x"60",x"00",x"38"),
   148 => (x"00",x"00",x"60",x"00"),
   149 => (x"5e",x"0e",x"00",x"60"),
   150 => (x"0e",x"5d",x"5c",x"5b"),
   151 => (x"c2",x"4c",x"71",x"1e"),
   152 => (x"4d",x"bf",x"db",x"ec"),
   153 => (x"1e",x"c0",x"4b",x"c0"),
   154 => (x"c7",x"02",x"ab",x"74"),
   155 => (x"48",x"a6",x"c4",x"87"),
   156 => (x"87",x"c5",x"78",x"c0"),
   157 => (x"c1",x"48",x"a6",x"c4"),
   158 => (x"1e",x"66",x"c4",x"78"),
   159 => (x"df",x"ee",x"49",x"73"),
   160 => (x"c0",x"86",x"c8",x"87"),
   161 => (x"ee",x"ef",x"49",x"e0"),
   162 => (x"4a",x"a5",x"c4",x"87"),
   163 => (x"f0",x"f0",x"49",x"6a"),
   164 => (x"87",x"c6",x"f1",x"87"),
   165 => (x"83",x"c1",x"85",x"cb"),
   166 => (x"04",x"ab",x"b7",x"c8"),
   167 => (x"26",x"87",x"c7",x"ff"),
   168 => (x"4c",x"26",x"4d",x"26"),
   169 => (x"4f",x"26",x"4b",x"26"),
   170 => (x"c2",x"4a",x"71",x"1e"),
   171 => (x"c2",x"5a",x"df",x"ec"),
   172 => (x"c7",x"48",x"df",x"ec"),
   173 => (x"dd",x"fe",x"49",x"78"),
   174 => (x"1e",x"4f",x"26",x"87"),
   175 => (x"4a",x"71",x"1e",x"73"),
   176 => (x"03",x"aa",x"b7",x"c0"),
   177 => (x"d9",x"c2",x"87",x"d3"),
   178 => (x"c4",x"05",x"bf",x"c7"),
   179 => (x"c2",x"4b",x"c1",x"87"),
   180 => (x"c2",x"4b",x"c0",x"87"),
   181 => (x"c4",x"5b",x"cb",x"d9"),
   182 => (x"cb",x"d9",x"c2",x"87"),
   183 => (x"c7",x"d9",x"c2",x"5a"),
   184 => (x"9a",x"c1",x"4a",x"bf"),
   185 => (x"49",x"a2",x"c0",x"c1"),
   186 => (x"fc",x"87",x"e8",x"ec"),
   187 => (x"c7",x"d9",x"c2",x"48"),
   188 => (x"ef",x"fe",x"78",x"bf"),
   189 => (x"4a",x"71",x"1e",x"87"),
   190 => (x"72",x"1e",x"66",x"c4"),
   191 => (x"87",x"f9",x"ea",x"49"),
   192 => (x"1e",x"4f",x"26",x"26"),
   193 => (x"c3",x"48",x"d4",x"ff"),
   194 => (x"d0",x"ff",x"78",x"ff"),
   195 => (x"78",x"e1",x"c0",x"48"),
   196 => (x"c1",x"48",x"d4",x"ff"),
   197 => (x"c4",x"48",x"71",x"78"),
   198 => (x"08",x"d4",x"ff",x"30"),
   199 => (x"48",x"d0",x"ff",x"78"),
   200 => (x"26",x"78",x"e0",x"c0"),
   201 => (x"d9",x"c2",x"1e",x"4f"),
   202 => (x"ff",x"49",x"bf",x"c7"),
   203 => (x"c2",x"87",x"ea",x"df"),
   204 => (x"e8",x"48",x"d3",x"ec"),
   205 => (x"ec",x"c2",x"78",x"bf"),
   206 => (x"bf",x"ec",x"48",x"cf"),
   207 => (x"d3",x"ec",x"c2",x"78"),
   208 => (x"c3",x"49",x"4a",x"bf"),
   209 => (x"b7",x"c8",x"99",x"ff"),
   210 => (x"71",x"48",x"72",x"2a"),
   211 => (x"db",x"ec",x"c2",x"b0"),
   212 => (x"0e",x"4f",x"26",x"58"),
   213 => (x"5d",x"5c",x"5b",x"5e"),
   214 => (x"ff",x"4b",x"71",x"0e"),
   215 => (x"ec",x"c2",x"87",x"c7"),
   216 => (x"50",x"c0",x"48",x"ce"),
   217 => (x"df",x"ff",x"49",x"73"),
   218 => (x"49",x"70",x"87",x"cf"),
   219 => (x"cb",x"9c",x"c2",x"4c"),
   220 => (x"da",x"cb",x"49",x"ee"),
   221 => (x"c2",x"4d",x"70",x"87"),
   222 => (x"bf",x"97",x"ce",x"ec"),
   223 => (x"87",x"e4",x"c1",x"05"),
   224 => (x"c2",x"49",x"66",x"d0"),
   225 => (x"99",x"bf",x"d7",x"ec"),
   226 => (x"d4",x"87",x"d7",x"05"),
   227 => (x"ec",x"c2",x"49",x"66"),
   228 => (x"05",x"99",x"bf",x"cf"),
   229 => (x"49",x"73",x"87",x"cc"),
   230 => (x"87",x"dd",x"de",x"ff"),
   231 => (x"c1",x"02",x"98",x"70"),
   232 => (x"4c",x"c1",x"87",x"c2"),
   233 => (x"75",x"87",x"fe",x"fd"),
   234 => (x"87",x"ef",x"ca",x"49"),
   235 => (x"c6",x"02",x"98",x"70"),
   236 => (x"ce",x"ec",x"c2",x"87"),
   237 => (x"c2",x"50",x"c1",x"48"),
   238 => (x"bf",x"97",x"ce",x"ec"),
   239 => (x"87",x"e4",x"c0",x"05"),
   240 => (x"bf",x"d7",x"ec",x"c2"),
   241 => (x"99",x"66",x"d0",x"49"),
   242 => (x"87",x"d6",x"ff",x"05"),
   243 => (x"bf",x"cf",x"ec",x"c2"),
   244 => (x"99",x"66",x"d4",x"49"),
   245 => (x"87",x"ca",x"ff",x"05"),
   246 => (x"dd",x"ff",x"49",x"73"),
   247 => (x"98",x"70",x"87",x"db"),
   248 => (x"87",x"fe",x"fe",x"05"),
   249 => (x"f7",x"fa",x"48",x"74"),
   250 => (x"5b",x"5e",x"0e",x"87"),
   251 => (x"f8",x"0e",x"5d",x"5c"),
   252 => (x"4c",x"4d",x"c0",x"86"),
   253 => (x"c4",x"7e",x"bf",x"ec"),
   254 => (x"ec",x"c2",x"48",x"a6"),
   255 => (x"c1",x"78",x"bf",x"db"),
   256 => (x"c7",x"1e",x"c0",x"1e"),
   257 => (x"87",x"cb",x"fd",x"49"),
   258 => (x"98",x"70",x"86",x"c8"),
   259 => (x"ff",x"87",x"ce",x"02"),
   260 => (x"87",x"e7",x"fa",x"49"),
   261 => (x"ff",x"49",x"da",x"c1"),
   262 => (x"c1",x"87",x"de",x"dc"),
   263 => (x"ce",x"ec",x"c2",x"4d"),
   264 => (x"cf",x"02",x"bf",x"97"),
   265 => (x"ff",x"d8",x"c2",x"87"),
   266 => (x"b9",x"c1",x"49",x"bf"),
   267 => (x"59",x"c3",x"d9",x"c2"),
   268 => (x"87",x"cf",x"fb",x"71"),
   269 => (x"bf",x"d3",x"ec",x"c2"),
   270 => (x"c7",x"d9",x"c2",x"4b"),
   271 => (x"eb",x"c0",x"05",x"bf"),
   272 => (x"49",x"fd",x"c3",x"87"),
   273 => (x"87",x"f1",x"db",x"ff"),
   274 => (x"ff",x"49",x"fa",x"c3"),
   275 => (x"73",x"87",x"ea",x"db"),
   276 => (x"99",x"ff",x"c3",x"49"),
   277 => (x"49",x"c0",x"1e",x"71"),
   278 => (x"73",x"87",x"da",x"fa"),
   279 => (x"29",x"b7",x"c8",x"49"),
   280 => (x"49",x"c1",x"1e",x"71"),
   281 => (x"c8",x"87",x"ce",x"fa"),
   282 => (x"87",x"fd",x"c5",x"86"),
   283 => (x"bf",x"d7",x"ec",x"c2"),
   284 => (x"dd",x"02",x"9b",x"4b"),
   285 => (x"c3",x"d9",x"c2",x"87"),
   286 => (x"de",x"c7",x"49",x"bf"),
   287 => (x"05",x"98",x"70",x"87"),
   288 => (x"4b",x"c0",x"87",x"c4"),
   289 => (x"e0",x"c2",x"87",x"d2"),
   290 => (x"87",x"c3",x"c7",x"49"),
   291 => (x"58",x"c7",x"d9",x"c2"),
   292 => (x"d9",x"c2",x"87",x"c6"),
   293 => (x"78",x"c0",x"48",x"c3"),
   294 => (x"99",x"c2",x"49",x"73"),
   295 => (x"c3",x"87",x"cf",x"05"),
   296 => (x"da",x"ff",x"49",x"eb"),
   297 => (x"49",x"70",x"87",x"d3"),
   298 => (x"c0",x"02",x"99",x"c2"),
   299 => (x"4c",x"fb",x"87",x"c2"),
   300 => (x"99",x"c1",x"49",x"73"),
   301 => (x"c3",x"87",x"cf",x"05"),
   302 => (x"d9",x"ff",x"49",x"f4"),
   303 => (x"49",x"70",x"87",x"fb"),
   304 => (x"c0",x"02",x"99",x"c2"),
   305 => (x"4c",x"fa",x"87",x"c2"),
   306 => (x"99",x"c8",x"49",x"73"),
   307 => (x"c3",x"87",x"ce",x"05"),
   308 => (x"d9",x"ff",x"49",x"f5"),
   309 => (x"49",x"70",x"87",x"e3"),
   310 => (x"d6",x"02",x"99",x"c2"),
   311 => (x"df",x"ec",x"c2",x"87"),
   312 => (x"ca",x"c0",x"02",x"bf"),
   313 => (x"88",x"c1",x"48",x"87"),
   314 => (x"58",x"e3",x"ec",x"c2"),
   315 => (x"ff",x"87",x"c2",x"c0"),
   316 => (x"73",x"4d",x"c1",x"4c"),
   317 => (x"05",x"99",x"c4",x"49"),
   318 => (x"c3",x"87",x"ce",x"c0"),
   319 => (x"d8",x"ff",x"49",x"f2"),
   320 => (x"49",x"70",x"87",x"f7"),
   321 => (x"dc",x"02",x"99",x"c2"),
   322 => (x"df",x"ec",x"c2",x"87"),
   323 => (x"c7",x"48",x"7e",x"bf"),
   324 => (x"c0",x"03",x"a8",x"b7"),
   325 => (x"48",x"6e",x"87",x"cb"),
   326 => (x"ec",x"c2",x"80",x"c1"),
   327 => (x"c2",x"c0",x"58",x"e3"),
   328 => (x"c1",x"4c",x"fe",x"87"),
   329 => (x"49",x"fd",x"c3",x"4d"),
   330 => (x"87",x"cd",x"d8",x"ff"),
   331 => (x"99",x"c2",x"49",x"70"),
   332 => (x"87",x"d5",x"c0",x"02"),
   333 => (x"bf",x"df",x"ec",x"c2"),
   334 => (x"87",x"c9",x"c0",x"02"),
   335 => (x"48",x"df",x"ec",x"c2"),
   336 => (x"c2",x"c0",x"78",x"c0"),
   337 => (x"c1",x"4c",x"fd",x"87"),
   338 => (x"49",x"fa",x"c3",x"4d"),
   339 => (x"87",x"e9",x"d7",x"ff"),
   340 => (x"99",x"c2",x"49",x"70"),
   341 => (x"87",x"d9",x"c0",x"02"),
   342 => (x"bf",x"df",x"ec",x"c2"),
   343 => (x"a8",x"b7",x"c7",x"48"),
   344 => (x"87",x"c9",x"c0",x"03"),
   345 => (x"48",x"df",x"ec",x"c2"),
   346 => (x"c2",x"c0",x"78",x"c7"),
   347 => (x"c1",x"4c",x"fc",x"87"),
   348 => (x"ac",x"b7",x"c0",x"4d"),
   349 => (x"87",x"d3",x"c0",x"03"),
   350 => (x"c1",x"48",x"66",x"c4"),
   351 => (x"7e",x"70",x"80",x"d8"),
   352 => (x"c0",x"02",x"bf",x"6e"),
   353 => (x"74",x"4b",x"87",x"c5"),
   354 => (x"c0",x"0f",x"73",x"49"),
   355 => (x"1e",x"f0",x"c3",x"1e"),
   356 => (x"f6",x"49",x"da",x"c1"),
   357 => (x"86",x"c8",x"87",x"fd"),
   358 => (x"c0",x"02",x"98",x"70"),
   359 => (x"ec",x"c2",x"87",x"d8"),
   360 => (x"6e",x"7e",x"bf",x"df"),
   361 => (x"c4",x"91",x"cb",x"49"),
   362 => (x"82",x"71",x"4a",x"66"),
   363 => (x"c5",x"c0",x"02",x"6a"),
   364 => (x"49",x"6e",x"4b",x"87"),
   365 => (x"9d",x"75",x"0f",x"73"),
   366 => (x"87",x"c8",x"c0",x"02"),
   367 => (x"bf",x"df",x"ec",x"c2"),
   368 => (x"87",x"d2",x"f2",x"49"),
   369 => (x"bf",x"cb",x"d9",x"c2"),
   370 => (x"87",x"dd",x"c0",x"02"),
   371 => (x"87",x"cb",x"c2",x"49"),
   372 => (x"c0",x"02",x"98",x"70"),
   373 => (x"ec",x"c2",x"87",x"d3"),
   374 => (x"f1",x"49",x"bf",x"df"),
   375 => (x"49",x"c0",x"87",x"f8"),
   376 => (x"c2",x"87",x"d8",x"f3"),
   377 => (x"c0",x"48",x"cb",x"d9"),
   378 => (x"f2",x"8e",x"f8",x"78"),
   379 => (x"5e",x"0e",x"87",x"f2"),
   380 => (x"0e",x"5d",x"5c",x"5b"),
   381 => (x"c2",x"4c",x"71",x"1e"),
   382 => (x"49",x"bf",x"db",x"ec"),
   383 => (x"4d",x"a1",x"cd",x"c1"),
   384 => (x"69",x"81",x"d1",x"c1"),
   385 => (x"02",x"9c",x"74",x"7e"),
   386 => (x"a5",x"c4",x"87",x"cf"),
   387 => (x"c2",x"7b",x"74",x"4b"),
   388 => (x"49",x"bf",x"db",x"ec"),
   389 => (x"6e",x"87",x"d1",x"f2"),
   390 => (x"05",x"9c",x"74",x"7b"),
   391 => (x"4b",x"c0",x"87",x"c4"),
   392 => (x"4b",x"c1",x"87",x"c2"),
   393 => (x"d2",x"f2",x"49",x"73"),
   394 => (x"02",x"66",x"d4",x"87"),
   395 => (x"de",x"49",x"87",x"c7"),
   396 => (x"c2",x"4a",x"70",x"87"),
   397 => (x"c2",x"4a",x"c0",x"87"),
   398 => (x"26",x"5a",x"cf",x"d9"),
   399 => (x"00",x"87",x"e1",x"f1"),
   400 => (x"00",x"00",x"00",x"00"),
   401 => (x"00",x"00",x"00",x"00"),
   402 => (x"00",x"00",x"00",x"00"),
   403 => (x"1e",x"00",x"00",x"00"),
   404 => (x"c8",x"ff",x"4a",x"71"),
   405 => (x"a1",x"72",x"49",x"bf"),
   406 => (x"1e",x"4f",x"26",x"48"),
   407 => (x"89",x"bf",x"c8",x"ff"),
   408 => (x"c0",x"c0",x"c0",x"fe"),
   409 => (x"01",x"a9",x"c0",x"c0"),
   410 => (x"4a",x"c0",x"87",x"c4"),
   411 => (x"4a",x"c1",x"87",x"c2"),
   412 => (x"4f",x"26",x"48",x"72"),
		others => (others => x"00")
	);
	signal q1_local : word_t;

	-- Altera Quartus attributes
	attribute ramstyle: string;
	attribute ramstyle of ram: signal is "no_rw_check";

begin  -- rtl

	addr1 <= to_integer(unsigned(addr(ADDR_WIDTH-1 downto 0)));

	-- Reorganize the read data from the RAM to match the output
	q(7 downto 0) <= q1_local(3);
	q(15 downto 8) <= q1_local(2);
	q(23 downto 16) <= q1_local(1);
	q(31 downto 24) <= q1_local(0);

	process(clk)
	begin
		if(rising_edge(clk)) then 
			if(we = '1') then
				-- edit this code if using other than four bytes per word
				if (bytesel(3) = '1') then
					ram(addr1)(3) <= d(7 downto 0);
				end if;
				if (bytesel(2) = '1') then
					ram(addr1)(2) <= d(15 downto 8);
				end if;
				if (bytesel(1) = '1') then
					ram(addr1)(1) <= d(23 downto 16);
				end if;
				if (bytesel(0) = '1') then
					ram(addr1)(0) <= d(31 downto 24);
				end if;
			end if;
			q1_local <= ram(addr1);
		end if;
	end process;
  
end rtl;

