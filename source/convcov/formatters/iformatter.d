module convcov.formatters.iformatter;

import convcov.metadata;
import convcov.filetype;

import convcov.formatters;

abstract class IFormatter
{
	this(scope ref OutputMetadata metadata) {}

	static IFormatter build(FileType ft, ref OutputMetadata metadata)
	{
		import std.format : format;
		import std.string : capitalize;
		switch(ft)
		{
		static foreach(m; [__traits(allMembers, FileType)])
			mixin(format!"case FileType.%s: return new %sFormatter(metadata);"(
				m, m.capitalize
			));
		default: assert(0, "Invalid file type to build a formatter!");
		}
	}

	void write();
	override string toString() const;
}

