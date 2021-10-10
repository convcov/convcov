module convcov.filetype;

import convcov.heuristics;
import convcov.blob;
import std.array;
import std.file;

enum FileType {
	automatic,
	lst,
	convcov,
	html
}

FileType detect()(auto ref Blob blob, bool extensive = true)
{
	auto heuristics = detectHeuristic(blob, extensive);
	if(heuristics !is null)
	{
		import std.algorithm.sorting : sort;
		import std.math : isClose;
		auto heuristic = heuristics
			.byKeyValue().array
			.sort!"a.value > b.value"
			.front;
		if(!heuristic.value.isClose(0.0L))
			return heuristic.key;
	}

	// can't detect
	return FileType.automatic;
}

real[FileType] detectHeuristic()(auto ref Blob blob, bool extensive = true)
{
	// Number of steps to auto detect:
	// 1. Compare the entire filename
	// 2. Compare the file extension
	// 3. Read the file content

	// enum HEURISTICS_NUMBER = 3;
	// enum HEURISTIC_STEP_VAL = 1 / HEURISTICS_NUMBER;

	import std.path : extension, baseName;
	switch(baseName(blob.path)) with(FileType)
	{
		case "convcov.json":
			return [convcov: 1.0L];

		default: break;
	}

	switch(extension(blob.path)) with(FileType)
	{
		case ".lst":
			return [lst: 1.0L];
		case ".html":
		case ".htm":
			return [html: 1.0L];
		case ".json":
			return [convcov: 1.0L];

		default: break;
	}

	if(!extensive)
		// no heuristic for no extensive detection
		return null;

	auto mb = blob.readFile();
	blob = mb;

	import std.math : isClose;
	real[FileType] heuristics;
	real heuristic;

	// lst files
	heuristic = lstDataHeuristic(mb);
	if(heuristic.isClose(1.0L)) return [FileType.lst : 1.0L];
	heuristics[FileType.lst] = heuristic;

	// html files
	heuristic = htmlDataHeuristic(mb);
	if(heuristic.isClose(1.0L)) return [FileType.lst : 1.0L];
	heuristics[FileType.lst] = heuristic;

	return heuristics;
}

auto fileTypeDirRange(string path, FileType type)
	in(isDir(path))
	in(type != FileType.automatic)
{
	import std.algorithm : filter, map;
	return dirEntries(path, SpanMode.depth)
		.filter!(f => f.isFile)
		.filter!(f => detect(Blob(f.name), false) == type)
		.map!(f => f.name);
}
