module convcov.converters.iconverter;

import convcov.metadata;
import convcov.coverage;
import convcov.filetype;

import convcov.converters;

abstract class IConverter
{
	this(scope ref InputMetadata metadata) {}

	static IConverter build(FileType ft, ref InputMetadata metadata)
	{
		import std.format : format;
		import std.string : capitalize;
		switch(ft)
		{
		static foreach(m; [__traits(allMembers, FileType)])
			mixin(format!"case FileType.%s: return new %sConverter(metadata);"(
				m, m.capitalize
			));
		default: assert(0, "Invalid file type to build a converter!");
		}
	}

	Coverage read();
}

