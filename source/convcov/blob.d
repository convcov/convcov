module convcov.blob;

import std.stdio : File, chunks;
import std.file : isDir;
import std.sumtype;

struct MemoryBlob
{
	string path;
	ubyte[] data;
}

struct Blob
{
	this(File f) { filesm = f; }
	this(string p) { filesm = p; }
	this(ubyte[] b) { filesm = b; }
	this(MemoryBlob mb) { filesm = mb; }
	void opAssign(MemoryBlob mb) { filesm = mb; }

	this(typeof(null) _)
	{
		filesm = (ubyte[]).init;
	}

	private ubyte[] read(string path)
	{
		import std.file : read;
		return cast(ubyte[])read(path);
	}

	private bool maybeFile(File file)
	{
		if(file.name is null)
			return true;

		return !isDir(file.name);
	}

	private bool maybeFile(string path)
	{
		if(path is null)
			return false;

		return !isDir(path);
	}

	private ubyte[] read(File file)
	{
		import std.array : appender;
		auto ret = appender!(ubyte[]);
		foreach (ubyte[] buffer; chunks(file, 4096))
			ret ~= buffer;
		return ret[];
	}

	ubyte[] read()
	{
		return filesm.match!(
			(ubyte[] b) => b,
			(MemoryBlob mb) => mb.data,
			(string path) => maybeFile(path) ? read(path) : null,
			(File file) => maybeFile(path) ? read(file) : null
		);
	}

	MemoryBlob readFile()
	{
		return filesm.match!(
			(ubyte[] b) => MemoryBlob(null, b),
			(MemoryBlob mb) => mb,
			(string path) => MemoryBlob(path, maybeFile(path) ? read(path) : null),
			(File file) => MemoryBlob(file.name, maybeFile(file) ? read(file) : null)
		);
	}

	string path()
	{
		return filesm.match!(
			(ubyte[] b) => null,
			(MemoryBlob mb) => mb.path,
			(string path) => path,
			(File file) => file.name
		);
	}

	void write(ubyte[] data)
	{
		void bufferWrite(ref ubyte[] buf)
		{
			if(data.length < buf.length)
			{
				buf[0..data.length][] = data;
				buf = buf[0..data.length];
			} else {
				buf = data.dup;
			}
		}

		filesm.match!(
			(ref ubyte[] b) => bufferWrite(b),
			(ref MemoryBlob mb) => bufferWrite(mb.data),
			(string path) => File(path).rawWrite(data),
			(File file) => file.rawWrite(data)
		);
	}

	private alias FileSM = SumType!(File, string, ubyte[], MemoryBlob);
	private FileSM filesm;
}
