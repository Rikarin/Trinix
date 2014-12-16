typedef	void (*exithandler_t)(void);
typedef	void (*constructor_t)(void);

constructor_t	_crtbegin_ctors[0] __attribute__((section(".ctors")));
exithandler_t	_crt0_exit_handler;

extern void	_init(void);
extern void	_fini(void);
//extern void	_exit(int status) __attribute__((noreturn));
extern int	main(int argc, char *argv[], char **envp);

void _start(int argc, char *argv[], char **envp)
{
	// TODO: isn't this handled by _init?
	/*for( int i = 0; _crtbegin_ctors[i]; i ++ )
		_crtbegin_ctors[i]();*/
	
	_init();

	int rv = main(argc, argv, envp);
	
	if( _crt0_exit_handler )
		_crt0_exit_handler();
	_fini();
	//_exit(rv); TODO
}
