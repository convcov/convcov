module convcov.convert;

import convcov.filetype;
import convcov.metadata;
import convcov.blob;
import convcov.coverage;
import convcov.converters.iconverter;
import convcov.formatters.iformatter;
import convcov.logging;

import std.stdio : stdin, stdout;

struct ConvertOptions
{
	FileType from; /// input file format
	string sourcePath; /// source code path if any, null otherwise
	string inputPath; /// input file path

	FileType to = FileType.convcov; /// output file format
	string outputPath; /// output file/folder path

	bool minify; /// minify output
	bool indexing; /// indexing output folder

	void convert()
	{
		auto intermediate = convertFrom();
		convertTo(intermediate);
	}

	void convertTo(Coverage coverage)
	{
		OutputMetadata metadata;
		metadata.coverage = coverage;
		metadata.blob = outputPath is null
			? Blob(stdout)
			: Blob(outputPath);
		metadata.sourcePath = sourcePath;

		if(minify) metadata.flags |= OutputMetadata.Flags.Minify;
		if(indexing) metadata.flags |= OutputMetadata.Flags.Indexing;

		IFormatter.build(to, metadata).write();
	}

	Coverage convertFrom()
	{
		InputMetadata metadata;
		metadata.blob = inputPath is null
			? Blob(stdin)
			: Blob(inputPath);
		metadata.sourcePath = sourcePath;

		return IConverter.build(from, metadata).read();
	}
}


