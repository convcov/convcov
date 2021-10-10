module convcov.heuristics.lst;

import convcov.heuristics.utils;
import convcov.blob;

real lstDataHeuristic(MemoryBlob blob)
{
	import std.ascii : newline, isDigit;
	import std.algorithm : splitter, all;
	import std.string : strip, stripRight, endsWith;
	import std.array : array;

	string buf = cast(string)blob.data;

	auto sl = buf.splitter(newline);

	// if no lines at all
	if(sl.empty) return HEURISTIC_NOT_FOUND;

	buf = stripRight(buf);
	if(buf.endsWith(" has no code"))
		return HEURISTIC_EXACT_MATCH;

	// at least two lines to be valid
	import std.range : drop;
	if(sl.drop(1).empty)
		return HEURISTIC_NOT_FOUND;

	// at least a line with code
	auto ls = sl.front.splitter('|');
	// possibly a number
	auto pn = ls.front.array;
	auto spn = strip(pn);
	// not empty and not a number
	if(spn && !spn.all!isDigit)
		return HEURISTIC_NOT_FOUND;

	buf = stripRight(buf);
	if(buf.endsWith("% covered"))
		return HEURISTIC_EXACT_MATCH;

	return HEURISTIC_NOT_FOUND;
}


@("LST: data heuristic detection")
unittest
{
	immutable expected = [
		cast(ubyte[])"       |\n% covered": 1.0L,
		cast(ubyte[])"0000000|\n% covered": 1.0L,
		cast(ubyte[])"0000000|": 0.0L,
		cast(ubyte[])"0000000|butno": 0.0L,
		cast(ubyte[])"0000000|\nbut no": 0.0L,
		cast(ubyte[])"     11|\n% covered": 1.0L,
		cast(ubyte[])"     11|\n|\n% covered": 1.0L,
		cast(ubyte[])"000000-|": 0.0L,
		cast(ubyte[])"000000-|\n": 0.0L,
		cast(ubyte[])"|\n% covered": 1.0L,
		cast(ubyte[])"|\n has no code": 1.0L,
		cast(ubyte[])" has no code": 1.0L,
		cast(ubyte[])"this is not an lst": 0.0L,
		null: 0.0L,
	];

	foreach(k,v; expected)
	{
		import std.math : isClose;
		assert(lstDataHeuristic(MemoryBlob("", k.dup)).isClose(v));
	}
}
