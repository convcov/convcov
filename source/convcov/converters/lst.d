module convcov.converters.lst;

import convcov.converters.iconverter;
import convcov.utils;
import convcov.coverage;
import convcov.metadata;
import convcov.filetype;
import convcov.blob;
import convcov.logging;

import std.algorithm;
import std.exception;

final class LstConverter : IConverter
{
	this(ref InputMetadata metadata) {
		super(metadata);
		this.metadata = metadata;
	}

	override Coverage read()
	{
		MemoryBlob mb = metadata.blob.readFile();
		Coverage ret;
		if(mb.data !is null)
		{
			log!"trace"("file data present");
			appendRead(ret, mb.data);
			return ret;
		}

		log!"trace"("file data not present");
		import std.file : read;
		foreach(f; fileTypeDirRange(mb.path, FileType.lst))
		{
			logf!"info"("processing file '%s'", f);
			appendRead(ret, cast(ubyte[])read(f));

		}

		return ret;
	}

	private void appendRead(ref Coverage cov, ubyte[] data)
	{
		import std.algorithm : splitter;
		import std.string : chomp, splitLines, strip;
		import std.array : split, join;
		import std.range : empty, front, back;
		import std.conv : to;

		Coverage.File covfile;

		auto str = cast(string)data;
		auto buf = str.chomp.splitLines;
		if (buf.empty) // at the time, an empty file is generated from any empty .d file
			return;

		enforce!ParsingException(buf.length >= 2,
				"Minimum number of lines is 2. Probably not parsing .lst file");

		foreach (i, ref line; buf[0 .. $ - 1])
		{
			immutable auto splittedLine = line.split("|");
			// check if the line is from a LST file
			enforce!ParsingException(splittedLine.length >= 2,
					"'|' separator not found. Probably not parsing .lst file");

			immutable auto covered = splittedLine.front.strip;

			if(!covered.empty)
				covfile.lines[i] = Coverage.Line(covered.to!ulong);
		}

		auto finalLine = buf.back;

		if (!finalLine.endsWith(" has no code"))
		{
			auto s = finalLine.split("% covered");
			// check if it actually splits
			enforce!ParsingException(s.length >= 2,
					"The last line is not well formatted: missing '% covered'");

			auto splitted = s.front.split(" ");

			// check if lst is well formatted (has 'is' in splitted)
			enforce!ParsingException(splitted[$ - 2] == "is",
					"The last line is not well formatted: missing ' is '");
			// remove ' is ' from 'filename.d is x% covered'
			covfile.filename = splitted[0 .. $ - 2].join(" ");
		}
		else
		{
			covfile.filename = finalLine.split(" has no code").front;
		}

		cov.add(covfile);
	}

	InputMetadata metadata;
}
