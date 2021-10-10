module convcov.metadata;

import convcov.blob;
import convcov.coverage;

struct Metadata
{
	Blob blob; /// blob to read/write
	string sourcePath; /// source code path if available, null otherwise
}

struct InputMetadata
{
	Metadata _metadata; /// inherited metadata
	alias _metadata this;

	this(ref InputMetadata metadata)
	{
		blob = metadata.blob.readFile();
		sourcePath = metadata.sourcePath;
	}
}

struct OutputMetadata
{
	Metadata _metadata; /// inherited metadata
	alias _metadata this;

	enum Flags : ubyte
	{
		None = 0,
		Indexing = 1 << 0,
		Minify = 1 << 1,
		Reproducible = 1 << 2,
	}
	Flags flags; /// output flags
	Coverage coverage; /// coverage to convert into
}
