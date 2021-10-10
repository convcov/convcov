module convcov.formatters.convcov;

import convcov.formatters.iformatter;
import convcov.utils;
import convcov.coverage;
import convcov.metadata;

final class ConvcovFormatter : IFormatter
{
	this(scope ref OutputMetadata metadata) {
		super(metadata);
		this.metadata = &metadata;
	}

	override void write()
	{
		metadata.blob.write(cast(ubyte[])toString());
	}

	override string toString() const
	{
		import asdf : serializeToJson, serializeToJsonPretty;

		auto cov = metadata.coverage;
		return (metadata.flags & OutputMetadata.Flags.Minify)
			? cov.serializeToJson()
			: cov.serializeToJsonPretty();
	}

	OutputMetadata* metadata;
}
