module convcov.converters.automatic;

import convcov.converters.iconverter;
import convcov.utils;
import convcov.coverage;
import convcov.metadata;
import convcov.filetype;
import convcov.blob;
import convcov.logging;

final class AutomaticConverter : IConverter
{
	this(ref InputMetadata metadata) {
		super(metadata);
		this.metadata = metadata;
		from = detect(this.metadata.blob);
		if (from == FileType.automatic)
			throw new UnsupportedException("Can't automatically detect coverage type!");
	}

	override Coverage read()
	{
		return IConverter.build(from, metadata).read();
	}

	InputMetadata metadata;
	FileType from;
}
