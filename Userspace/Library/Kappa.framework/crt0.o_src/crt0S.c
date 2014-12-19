typedef	void (*exithandler_t)(void);
typedef	void (*constructor_t)(void);

extern void	_SysDebug(const char *, ...);
extern void	_init(void);
extern void	_fini(void);
extern int	SoMain(void *Base, int argc, char *argv[], char **envp) __attribute__((weak));

int SoStart(void *Base, int argc, char *argv[], char **envp)
{
	//_SysDebug("SoStart(%p,%i,%p)", Base, argc, argv);
	_init();

	if (SoMain)
		return SoMain(Base, argc, argv, envp);
	return 0;
}
