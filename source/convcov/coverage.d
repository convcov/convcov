module convcov.coverage;

import convcov.utils.serialization;

import std.typecons;
import std.algorithm;
import std.array;
import asdf;

/// Convcov coverage format version
enum CONVCOV_COVERAGE_VERSION = 1UL;

struct Coverage
{
	/**
	 * Describe the status of an entry
	 */
	enum Status
	{
		full, /// Entry is fully covered
		partial, /// Entry is partially covered
		uncovered, /// Entry is totally uncovered
		unknown, /// Entry has inconsistent values
	}

	/**
	 * Coverage details of a branch entry
	 */
	struct Branch
	{
		/**
		 * Branch column range
		 */
		struct Range
		{
			ulong start; /// start column index
			ulong end; /// end column index
		}
		Nullable!Range range; /// range of the branch in columns
		bool covered; /// whether the branch is covered or not
	}

	/**
	 * Coverage details of a file entry
	 */
	struct File
	{
		Line[ulong] lines; /// coverable lines
		string filename; /// source file name

		@property Status status() const
		{
			// number of fully covered lines
			bool full;
			foreach(l; lines.byValue())
			{
				switch(l.status)
				{
				case Status.unknown: return Status.unknown;
				case Status.partial: return Status.partial;
				case Status.full: full = true; break;
				default: break;
				}
			}

			return full ? Status.full : Status.uncovered;
		}

		@property real percentage() const
		{
			return lines.length
				? lines.byValue().map!(l => l.percentage)
					.sum / lines.length
				: 0.0L;
		}

		void merge(File file)
		{
			foreach (k, v; file.lines)
			{
				Line* p = (k in lines);
				if (p !is null)
				{
					(*p).hits += v.hits;
				} else {
					lines[k] = v;
				}

			}
		}
	}

	/**
	 * Coverage details of a line entry
	 */
	struct Line
	{
		ulong hits; /// number of hits on this line
		@serdeIgnoreDefault SerializableArray!Branch branches; /// branches for branch coverage

		@property Status status() const
		{
			if(branches.length)
			{
				// number of covered branches
				ulong n;
				foreach(b; branches)
					if(b.covered) n++;

				if (n == branches.length)
				{
					if(hits >= n)
						return Status.full;
					// hits lower than covered branches
					return Status.unknown;
				}
				// consistently uncovered
				if (!n && !hits)
					return Status.uncovered;

				if (hits >= n)
					return Status.partial;

				// hits and covered branches doesn't match
				return Status.unknown;
			} else {
				// simple coverage status
				return hits
					? Status.full
					: Status.uncovered;
			}
		}

		@property real percentage() const
		{
			if(branches.length)
			{
				// number of covered branches
				ulong n;
				foreach(b; branches)
					if(b.covered) n++;

				return real(min(hits, n)) / branches.length;
			}

			return hits ? 1.0L : 0.0L;
		}
	}

	@serdeIgnore private size_t[string] filesLookup;
	SerializableAppender!(File[]) files; /// files with coverage

	void add(File file)
	{
		if(file.filename is null)
		{
			files ~= file;
			return;
		}

		size_t* p = (file.filename in filesLookup);
		if (p !is null)
			files[][*p].merge(file);
		else files ~= file;
	}

	@serdeKeyOut("version")
	@property ulong version_() const { return CONVCOV_COVERAGE_VERSION; }

	@property Status status() const
	{
		// number of fully covered lines
		bool full;
		foreach(f; files)
		{
			switch(f.status)
			{
			case Status.unknown: return Status.unknown;
			case Status.partial: return Status.partial;
			case Status.full: full = true; break;
			default: break;
			}
		}

		return full ? Status.full : Status.uncovered;
	}

	@property real percentage() const
	{
		return files[].map!(f => f.percentage)
			.sum / files[].length;
	}
}
