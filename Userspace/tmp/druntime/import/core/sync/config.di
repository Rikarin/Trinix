// D import file generated from 'src/core/sync/config.d'
module core.sync.config;
version (Posix)
{
	private import core.sys.posix.time;

	private import core.sys.posix.sys.time;

	private import core.time;

	void mktspec(ref timespec t);
	void mktspec(ref timespec t, Duration delta);
	void mvtspec(ref timespec t, Duration delta);
}
