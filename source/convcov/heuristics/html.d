module convcov.heuristics.html;

import convcov.heuristics.utils;

import convcov.blob;
import std.algorithm;

real htmlDataHeuristic(MemoryBlob blob)
{
	ubyte[] data = blob.data;

	// check doctype and convcov signature
	if(data.startsWith(cast(ubyte[])"<!DOCTYPE html><!--CONVCOV"))
		return HEURISTIC_EXACT_MATCH;

	// not a doctype or convcov signature
	return HEURISTIC_NOT_FOUND;
}

@("HTML: data heuristic detection")
unittest
{
	immutable expected = [
		cast(ubyte[])"<!DOCTYPE html><!--CONVCOV": 1.0L, // signature
		cast(ubyte[])"                          ": 0.0L, // same size of the signature
		cast(ubyte[])"<!DOCTYPE html><!--CONVCOV{\"files\":[]}-->": 1.0L,
		null: 0.0L,
	];

	foreach(k,v; expected)
	{
		import std.math : isClose;
		assert(htmlDataHeuristic(MemoryBlob("", k.dup)).isClose(v));
	}
}
