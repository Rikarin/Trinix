module ObjectManager.IStaticModule;


interface IStaticModule {
	static bool Initialize() {
		return false;
	}

	static bool Install() {
		return false;
	}

	static bool Uninstall() {
		return false;
	}

	static bool Finalize() {
		return false;
	}
}