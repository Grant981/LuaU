-- @grantwares notes; learned from Crusherfire's youtube channel about Type Annoation

-- Dynamically Typed Language: During runtime, variables can be changed from different data types. (Lua U)
-- Statically Typed Language : During runtime, variables cannot be changed from different data types. (C++, Java)

-- Creating a type x = {}, you would want to make a type if you wanted to set a variable to that corresponding type.
-- "..." in programming terms is a variadic argument

--!strict
---------------------------------------------------------------------

local function sum(a : number,b : number, ... : number): (number, string)
	local additionalArgs = table.pack(...) -- Returns an dictionary with a string ["n"] = x at the end where x equals the number of extra arguments given.
	return a+b,"CustomString";
end;

sum(1,1,5,6,7,8);
---------------------------------------------------------------------
-- The "|" means or; so it can be any of the options listed.

local function sum2(a : "Hello" | "Hi" | "Hey") -- Singleton/Literal Type; currently only supported for strings and booleans: when the type is the string.
		
end;

sum2("Hello"); -- Auto fills the string declared

local someVar : "Hello" | Humanoid | string | boolean = false;
---------------------------------------------------------------------
-- Creating a type : useful when creating something with custom attributes like a car or a gun.
type ExampleType = {
	Hello : string,
	Howdy : number,
	Hi : boolean
};

-- Referring to array by typing will display its type which is "ExampleType".
local array : ExampleType;
---------------------------------------------------------------------

type XCoord = {X : number};
type YCoord = {Y : number};
type ZCoord = {Z : number};

type Vect3 = XCoord & YCoord & ZCoord; -- Intersection Type that only works with tables.

local vec : Vect3 = {X = 1, Y = 2, Z = 2};
---------------------------------------------------------------------
 -- Function Type Annotation
local a: (number, string) -> (boolean, string) -- Useful when using generics and when you need to define a return type, look at generics at the end of the notes.
local b: (number,...string) -> (boolean, string) -- To use variadic parameters in this type annotation format you don't need a colon.

a = function(x: number, y: string): (boolean, string)
	return true, "CustomString";
end
---------------------------------------------------------------------
--Table Types

local NameList : {[string] : number} = { -- String is the index and number is the value, key value type pair
	["Among"] = 1,
}

---------------------------------------------------------------------

-- Type Casting: type over an infered type when its too generic, you refine the list to its sublist

local myTable = {
	values = {} :: {string}, 
	values1 = {} :: {string}
} -- Another example of type casting
-- "myTable.values" this will be interpreted as an table of strings 
--Type casting on table and not the index will get the type to autofill

local function typeCastFunc(a : BasePart) : BasePart
	return a
end

local e : WedgePart = nil

local v1 = typeCastFunc(e) :: WedgePart -- Type Casting refines the type of basepart to the subset of WedgePart


---------------------------------------------------------------------
-- Optional Function Parameters

local function sum4(a : number, b : number?): number
	
	if not b then
		
	end
	
	return a+b :: number; -- Iffy thing with type annotation, you have to cast the number over b to fix it even though we checked it because it can be nil with.
end;
---------------------------------------------------------------------
-- Generics

type Pair<T,G> = {key1 : T, key2 : G} -- G and T are place holders for the variable type that key1 and key2

local e : Pair<string, number>

-- K below defines the return type of the func like in java "public int fun()"

local function map<T,K>(array : {T}, mappingFunc: (T) -> K) : {K}
	local result = {}
	
	for i, v in array do
		result[i] = mappingFunc(v) -- Gets the function in the mappingFunc parameter and uses it to make change.
	end
	return result
end

print(map({1,2,3}, function(v)
	return tostring(v)
end))

---------------------------------------------------------------------
